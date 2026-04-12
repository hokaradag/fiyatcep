"""Scrape cycle orchestrator — runs all market scrapers sequentially.

Per D-11: Failed scrapers do not crash the cycle — exceptions caught per-market,
logged, and execution continues with the next scraper.

Per D-09: This module is called both by the APScheduler daily job and by the
POST /admin/scrape/run manual trigger endpoint.
"""
import logging

from sqlalchemy import text

from app.database import SessionLocal
from app.notifier import detect_and_notify_price_drops
from scraper.logger import write_scrape_log
from scraper.migros import MigrosScraper

logger = logging.getLogger(__name__)

# Registry of all active scrapers. Add new market scrapers here.
SCRAPERS = [MigrosScraper()]


def run_scrape_cycle() -> list[dict]:
    """Run all scrapers sequentially. Returns list of scrape log dicts.

    Per D-11: Failed scrapes do not crash the cycle — exceptions caught per-market.
    Each scraper gets its own DB session to ensure isolation between markets.

    Returns:
        List of scrape log dicts, one per scraper (even for failed ones).
        Each dict contains: market, products_found, products_inserted,
        products_updated, prices_inserted, errors, duration_ms.
    """
    results = []

    for scraper in SCRAPERS:
        db = SessionLocal()
        try:
            log_entry = scraper.scrape(db)
            # Per DB-SCHEMA.sql Notes: update denormalized discount counter per market
            _update_discount_counts(db)
            db.commit()
            # NOTIF-03: Check for price drops and notify subscribed devices
            try:
                notifications_sent = detect_and_notify_price_drops(db)
                log_entry["notifications_sent"] = notifications_sent
            except Exception as exc:
                logger.error("Price-drop notification check failed: %s", exc)
                log_entry["notifications_sent"] = 0
            results.append(log_entry)
            write_scrape_log(log_entry)
            logger.info(
                "Scrape complete: %s — %d products found, %d prices inserted",
                log_entry.get("market", "unknown"),
                log_entry.get("products_found", 0),
                log_entry.get("prices_inserted", 0),
            )
        except Exception as e:
            logger.error("Scraper %s failed: %s", type(scraper).__name__, e)
            db.rollback()
            error_entry = {
                "market": getattr(scraper, "MARKET_ID", "unknown"),
                "error": str(e),
                "products_found": 0,
                "products_inserted": 0,
                "products_updated": 0,
                "prices_inserted": 0,
                "errors": [str(e)],
                "duration_ms": 0,
            }
            results.append(error_entry)
            write_scrape_log(error_entry)
        finally:
            db.close()

    return results


def _update_discount_counts(db) -> None:
    """Update markets.active_discount_count from current discounts table.

    Per DB-SCHEMA.sql Notes: active_discount_count is a denormalized counter
    maintained by the scraper (not a DB trigger). Must be refreshed after each
    scrape cycle to keep the market list endpoint accurate.

    SQL per DB-SCHEMA.sql Notes section:
        UPDATE markets SET active_discount_count = (
            SELECT COUNT(*) FROM discounts d
            JOIN market_products mp ON d.market_product_id = mp.id
            WHERE mp.market_id = markets.id AND d.is_active = 1
        )
    """
    db.execute(
        text(
            "UPDATE markets SET active_discount_count = ("
            "  SELECT COUNT(*) FROM discounts d"
            "  JOIN market_products mp ON d.market_product_id = mp.id"
            "  WHERE mp.market_id = markets.id AND d.is_active = 1"
            ")"
        )
    )
