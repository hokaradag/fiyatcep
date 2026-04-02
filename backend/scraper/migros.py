"""Migros market scraper — fetches product data from migros.com.tr via JSON API.

# ============================================================
# ENDPOINT DISCOVERY NOTES (discovered 2026-04-02)
# ============================================================
#
# Working Endpoint:
#   GET https://www.migros.com.tr/rest/products/search
#   Query params:
#     q      — keyword/category search term (e.g. "sut", "ekmek", "yag")
#     sayfa  — page number, 1-indexed
#     boyut  — page size (max observed: 48, but API returns ~30 per page regardless)
#
# Required Headers:
#   User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) ...Chrome/131.0.0.0 Safari/537.36
#   Accept: application/json
#   Accept-Language: tr-TR,tr;q=0.9,en;q=0.8
#
# Session Cookies:
#   A Cloudflare _cfuvid cookie is obtained by first GETting the homepage
#   (https://www.migros.com.tr). Subsequent API calls must reuse the same
#   requests.Session() so the cookie is sent automatically.
#
# Response Shape:
#   {
#     "successful": true,
#     "data": {
#       "hitCount": 365,
#       "pageCount": 13,
#       "storeProductInfos": [
#         {
#           "id": 20000011019904,
#           "name": "Torku Uht Süt 1 L",
#           "brand": {"name": "Torku", "id": 434, ...},
#           "regularPrice": 6995,   // kuruş (divide by 100 for TL)
#           "shownPrice": 6995,     // current/discounted price in kuruş
#           "discountRate": 0,      // 0 means no discount; >0 means discounted
#           "category": {"name": "Uzun Ömürlü Süt", ...}
#         },
#         ...
#       ]
#     }
#   }
#
# Pagination:
#   Iterate sayfa=1..pageCount. Each page returns ~30 products even with boyut=48.
#   Apply a 0.5s delay between pages to avoid rate-limiting.
#
# Fallback (not needed — JSON API is accessible without auth):
#   If the JSON API becomes unavailable (403/CAPTCHA), parse __NEXT_DATA__ from HTML:
#   soup.find("script", id="__NEXT_DATA__") contains initial page state as JSON.
# ============================================================
"""
import logging
import time
from uuid import uuid4

import requests

from app.models import PriceHistory
from scraper.base import BaseScraper, upsert_product, utc_now_str

logger = logging.getLogger(__name__)

MARKET_ID = "migros"

# Base URL for the Migros product search API
_BASE_URL = "https://www.migros.com.tr/rest/products/search"

# Search keywords covering major grocery categories for demo data.
# Each keyword fetches products from Migros's internal search.
# Selected to return ~50-200 products across 3 major categories.
SEARCH_KEYWORDS = [
    "sut",       # dairy/milk — ~365 products, scrape 2 pages (~60 items)
    "ekmek",     # bread — ~131 products, scrape 2 pages (~60 items)
    "yag",       # oil/fat — ~217 products, scrape 2 pages (~60 items)
]

# Number of pages to fetch per keyword (keeps total runtime reasonable for demo)
MAX_PAGES_PER_KEYWORD = 2

# Delay between pagination requests (seconds) to avoid rate limiting
PAGE_DELAY_SECONDS = 0.5


class MigrosScraper(BaseScraper):
    """Scraper for migros.com.tr — fetches product listings via the internal JSON API.

    Uses requests.Session() to maintain Cloudflare cookies across requests.
    Prices are stored in TL (converted from kuruş, which is the API format).
    """

    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({
            "User-Agent": (
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
                "AppleWebKit/537.36 (KHTML, like Gecko) "
                "Chrome/131.0.0.0 Safari/537.36"
            ),
            "Accept": "application/json",
            "Accept-Language": "tr-TR,tr;q=0.9,en;q=0.8",
        })

    def scrape(self, db) -> dict:
        """Execute a full scrape run for Migros.

        Fetches products from 3 major keyword searches (sut, ekmek, yag),
        upserts them into products + market_products, and inserts one
        price_history row per market_product per run (per D-07).

        Args:
            db: SQLAlchemy session for DB writes.

        Returns:
            Scrape log dict (see BaseScraper.scrape docstring for schema).
        """
        started_at = utc_now_str()
        start_time = time.time()
        stats = {
            "market": MARKET_ID,
            "started_at": started_at,
            "products_found": 0,
            "products_inserted": 0,
            "products_updated": 0,
            "prices_inserted": 0,
            "errors": [],
        }

        try:
            # Initialize session with Cloudflare cookie from homepage
            self._init_session()

            products = self._fetch_products()
            stats["products_found"] = len(products)

            from app.models import MarketProduct, Product
            from scraper.base import normalize_name

            for raw in products:
                try:
                    name = raw.get("name", "").strip()
                    brand_field = raw.get("brand")
                    brand = (
                        brand_field.get("name", "Migros").strip()
                        if isinstance(brand_field, dict)
                        else str(brand_field or "Migros").strip()
                    )
                    # Prices are in kuruş (integer) — divide by 100 for TL
                    shown_price_kurus = raw.get("shownPrice") or raw.get("regularPrice") or 0
                    price = float(shown_price_kurus) / 100.0
                    discount_rate = raw.get("discountRate") or 0
                    is_discounted = discount_rate > 0

                    if not name or price <= 0:
                        continue

                    # Check if this market_product already exists (for stats)
                    norm = normalize_name(name)
                    existing_product = (
                        db.query(Product).filter_by(normalized_name=norm, brand=brand).first()
                    )
                    existing_mp = None
                    if existing_product:
                        existing_mp = (
                            db.query(MarketProduct)
                            .filter_by(product_id=existing_product.id, market_id=MARKET_ID)
                            .first()
                        )

                    # Upsert product + market_product — returns market_products.id (Flutter's ProductItem.id)
                    # CRITICAL: upsert_product returns market_products.id, NOT products.id (D-02)
                    mp_id = upsert_product(db, name, brand, MARKET_ID, price, is_discounted)

                    if existing_mp:
                        stats["products_updated"] += 1
                    else:
                        stats["products_inserted"] += 1

                    # Per D-07: Insert one price_history row per market_product per scrape run,
                    # even if price is unchanged. This builds the trend data for Flutter's chart.
                    ph = PriceHistory(
                        id=str(uuid4()),
                        market_product_id=mp_id,
                        price=price,
                        recorded_at=utc_now_str(),
                    )
                    db.add(ph)
                    stats["prices_inserted"] += 1

                except Exception as e:
                    stats["errors"].append(f"Product parse error: {str(e)}")
                    logger.warning("Error processing product: %s", e)

            db.commit()

        except Exception as e:
            stats["errors"].append(f"Fetch error: {str(e)}")
            logger.error("Migros scrape failed: %s", e)
            db.rollback()

        elapsed_ms = int((time.time() - start_time) * 1000)
        stats["duration_ms"] = elapsed_ms
        return stats

    def _init_session(self) -> None:
        """Visit Migros homepage to obtain Cloudflare session cookie (_cfuvid).

        This cookie is required for subsequent API calls to succeed.
        The session object automatically carries the cookie on all future requests.
        """
        try:
            self.session.get("https://www.migros.com.tr", timeout=15)
        except Exception as e:
            logger.warning("Homepage prefetch failed (continuing without cookie): %s", e)

    def _fetch_products(self) -> list[dict]:
        """Fetch products from Migros search API across configured keywords and pages.

        Endpoint: GET https://www.migros.com.tr/rest/products/search
        Params: q (keyword), sayfa (1-indexed page), boyut (page size, ~30 returned)
        Prices: in kuruş (integer) — caller divides by 100 for TL
        Pagination: iterates sayfa=1..min(pageCount, MAX_PAGES_PER_KEYWORD)

        Returns:
            List of raw product dicts with keys matching Migros API response
            (name, brand, regularPrice, shownPrice, discountRate, etc.)
            Deduped by product id to avoid double-counting across keyword overlaps.
        """
        all_products: list[dict] = []
        seen_ids: set[int] = set()

        for keyword in SEARCH_KEYWORDS:
            try:
                page = 1
                page_count = None

                while True:
                    if page_count is not None and page > min(page_count, MAX_PAGES_PER_KEYWORD):
                        break

                    url = _BASE_URL
                    params = {"q": keyword, "sayfa": page, "boyut": 48}
                    response = self.session.get(url, params=params, timeout=15)
                    response.raise_for_status()

                    payload = response.json()
                    data = payload.get("data", {})

                    if page == 1:
                        page_count = data.get("pageCount", 1)
                        logger.info(
                            "Migros keyword=%s: hitCount=%d, pageCount=%d",
                            keyword,
                            data.get("hitCount", 0),
                            page_count,
                        )

                    items = data.get("storeProductInfos", [])
                    new_items = 0
                    for item in items:
                        product_id = item.get("id")
                        if product_id not in seen_ids:
                            seen_ids.add(product_id)
                            all_products.append(item)
                            new_items += 1

                    logger.debug(
                        "Migros keyword=%s page=%d: %d items (%d new)",
                        keyword, page, len(items), new_items,
                    )

                    page += 1

                    if page > min(page_count or 1, MAX_PAGES_PER_KEYWORD):
                        break

                    if PAGE_DELAY_SECONDS > 0:
                        time.sleep(PAGE_DELAY_SECONDS)

            except Exception as e:
                logger.error("Migros fetch failed for keyword=%s: %s", keyword, e)
                # Continue to next keyword — do not abort entire fetch

        logger.info("Migros total unique products fetched: %d", len(all_products))
        return all_products
