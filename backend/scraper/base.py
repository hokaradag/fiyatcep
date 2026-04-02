"""Base scraper utilities: Turkish text normalizer, canonical product upsert, abstract BaseScraper.

Turkish normalization strategy (per Phase 01 decision):
- Uppercase Turkish replacements happen BEFORE .lower() to avoid platform-inconsistent
  Unicode folding (e.g., İ.lower() may not yield 'i' on all platforms).
- Uses str.maketrans() for explicit character-level mapping of all 12 Turkish diacritics.
- Do NOT use unicodedata.normalize('NFKD', ...) — it does not handle ı→i correctly.
"""
import re
from abc import ABC, abstractmethod
from datetime import datetime, timezone
from uuid import uuid4

from sqlalchemy.orm import Session

from app.models import MarketProduct, Product

# Explicit translate table for all 12 Turkish diacritical characters.
# CRITICAL: Uppercase replacements (Ğ->G, Ş->S, İ->I, Ö->O, Ü->U, Ç->C) happen here,
# BEFORE .lower() is called. This guarantees İ->I->i instead of relying on
# platform-specific unicode folding behavior.
_TR_TABLE = str.maketrans("ğşıöüçĞŞİÖÜÇ", "gsioucGSIOUC")


def normalize_name(name: str) -> str:
    """Normalize a product name for cross-market canonical matching.

    Steps:
    1. Apply explicit Turkish diacritic translate (both lower + uppercase in one pass).
    2. Convert to lowercase.
    3. Strip leading/trailing whitespace.
    4. Collapse internal runs of whitespace to a single space.

    Args:
        name: Raw product name as scraped from a market website.

    Returns:
        Normalized string suitable for canonical product lookup.
    """
    text = name.translate(_TR_TABLE).lower().strip()
    return re.sub(r"\s+", " ", text)


def utc_now_str() -> str:
    """Return current UTC time as ISO 8601 string with Z suffix.

    Uses datetime.now(timezone.utc) — NOT datetime.utcnow() which is deprecated
    since Python 3.12 and returns a naive datetime without timezone info.

    Returns:
        UTC timestamp string e.g. '2026-04-02T10:00:00.000Z'
    """
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.000Z")


def upsert_product(
    db: Session,
    name: str,
    brand: str,
    market_id: str,
    price: float,
    is_discounted: bool,
) -> str:
    """Insert or update canonical product and market-specific product listing.

    Canonical product matching strategy (D-06):
    1. Normalize the product name.
    2. Look up existing Product by (normalized_name, brand).
    3. If found: reuse existing product_id.
    4. If not found: create new Product.
    5. Look up existing MarketProduct by (product_id, market_id).
    6. If found: update current_price, is_discounted, last_scraped_at.
    7. If not found: create new MarketProduct.
    8. Flush session (caller commits the batch).

    Args:
        db: SQLAlchemy session.
        name: Raw product name from scraper.
        brand: Product brand.
        market_id: Market slug (e.g., 'migros', 'a101').
        price: Current price.
        is_discounted: Whether the product is currently discounted.

    Returns:
        market_product.id — this is Flutter's ProductItem.id (D-02).
        Never returns products.id (internal canonical ID).
    """
    norm = normalize_name(name)

    # Step 1: Find or create canonical Product
    product = db.query(Product).filter_by(normalized_name=norm, brand=brand).first()
    if product is None:
        product = Product(
            id=str(uuid4()),
            name=name,
            brand=brand,
            normalized_name=norm,
            created_at=utc_now_str(),
        )
        db.add(product)
        db.flush()  # get product.id without committing

    product_id = product.id

    # Step 2: Find or create/update MarketProduct
    market_product = (
        db.query(MarketProduct)
        .filter_by(product_id=product_id, market_id=market_id)
        .first()
    )
    if market_product is None:
        market_product = MarketProduct(
            id=str(uuid4()),
            product_id=product_id,
            market_id=market_id,
            current_price=price,
            is_discounted=1 if is_discounted else 0,
            last_scraped_at=utc_now_str(),
        )
        db.add(market_product)
        db.flush()
    else:
        market_product.current_price = price
        market_product.is_discounted = 1 if is_discounted else 0
        market_product.last_scraped_at = utc_now_str()
        db.flush()

    # Return market_product.id — Flutter's ProductItem.id (D-02)
    # products.id is internal and must never be returned
    return market_product.id


class BaseScraper(ABC):
    """Abstract base class for all market scrapers.

    Each market scraper must implement the scrape() method which
    returns a structured scrape log dict for monitoring and logging.
    """

    @abstractmethod
    def scrape(self, db: Session) -> dict:
        """Execute a full scrape run for this market.

        Args:
            db: SQLAlchemy session for DB writes.

        Returns:
            Scrape log dict with keys:
                market (str): Market slug
                products_found (int): Total products encountered
                products_inserted (int): New canonical products created
                products_updated (int): Existing products whose price was updated
                prices_inserted (int): price_history rows inserted
                errors (list[str]): List of error messages (empty if all OK)
                duration_ms (int): Total scrape duration in milliseconds
        """
        pass
