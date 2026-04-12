# Milestones

## v1.0 MVP (Shipped: 2026-04-12)

**Phases completed:** 8 phases, 25 plans, 38 tasks

**Key accomplishments:**

- FavoritesStore ValueNotifier singleton replaced by Riverpod AsyncNotifier with identical SharedPreferences persistence and no manual init() at app startup
- 9 StatelessWidget classes extracted from 3 large page files into `widgets/` directories, reducing home_page.dart from 427 to 174 lines, market_detail_page.dart from 416 to 112 lines, and product_detail_page.dart from 272 to 112 lines
- One-liner:
- TextNormalizer now handles all uppercase Turkish chars (İ,Ç,Ğ,Ö,Ş,Ü) via pre-toLowerCase replacement, eliminating discounts search defect and duplicate _normalizeText()
- PricePoint Freezed model created, ProductItem extended with priceHistory, DiscountItem.validUntil migrated to DateTime with Turkish displayDate getter
- 1. [Rule 1 - Bug] Fixed double-underscore lint warning in test
- All three datasource providers swapped from mock to RemoteDataSourceImpl via apiClientProvider; productsByMarketProvider calls repository.getProductsByMarket() directly instead of in-memory filtering
- fl_chart installed, MarketBrand config with 7 Turkish market brand colors, PricePoint.displayDate getter in Turkish, asset directories registered, Wave 0 stub tests scaffolded
- Brand banner (120px, solid brand color) with overlapping logo container (56x56, Icons.store fallback) added to MarketDetailHeaderWidget using marketBrands config map
- PricePoint lists added to p1 (10 points, 4 time windows) and p2 (8 points, 3 time windows) in product_mock_datasource.dart, enabling chart rendering and time-range tab switching at runtime
- One-liner:
- CartNotifier AsyncNotifier<List<ProductItem>> with id-based dedup, add/remove/clear/isInCart, and SharedPreferences persistence to 'cart_products' key
- SQLite schema (5 tables, 7-market seed) and REST API contract (11 endpoints) frozen as spec documents for Phase 04.2 backend and Phase 04.3 Flutter integration
- Python backend with FastAPI+SQLAlchemy+SQLite, 5 ORM models matching frozen DB-SCHEMA.sql, Turkish text normalizer handling all 12 diacritics, and canonical product matching — 20 unit tests passing
- Migros JSON API scraper fetching dairy/bread/oil products via migros.com.tr/rest/products/search, writing price_history rows per D-07, with run_scrape_cycle orchestrator and D-11 failure isolation
- APScheduler AsyncIOScheduler embedded in FastAPI lifespan with DB-before-scheduler init ordering, POST /admin/scrape/run background trigger, and JSONL scrape audit log wired into both success and error paths
- backend/tests/conftest.py additions
- 1. [Rule 1 - Bug] ProductMockDataSourceImpl missing getProductPrices() implementation
- Migros scraper -> SQLite -> FastAPI -> Flutter pipeline verified end-to-end on Android emulator: 7 markets, 178 products, 8/9 UI checks passed, phase 04.3 approved
- 1. [Rule 2 - Security] Added google-services.json and GoogleService-Info.plist to .gitignore
- 1. [Rule 1 - Bug] firebase-admin version constraint updated
- Watch button (Takip Et/Takibi Birak) wired to product detail page with best-effort POST /notifications/subscribe backend sync on each toggle and FCM token refresh

---
