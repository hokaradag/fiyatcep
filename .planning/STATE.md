---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: milestone
status: executing
stopped_at: Completed 05-02-PLAN.md
last_updated: "2026-04-12T01:01:34.086Z"
last_activity: 2026-04-12
progress:
  total_phases: 8
  completed_phases: 7
  total_plans: 25
  completed_plans: 24
  percent: 93
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-03-27)

**Core value:** Aynı ürün ya da sepet için marketler arası gerçek fiyat farkını, geçmiş fiyat değişimini ve indirim fırsatlarını görünür kılmak — kullanıcı alışveriş kararını vermeden önce gerçek veriye bakabilmeli.
**Current focus:** Phase 05 — fcm-push-notifications

## Current Position

Phase: 05 (fcm-push-notifications) — EXECUTING
Plan: 3 of 3
Status: Ready to execute
Last activity: 2026-04-12

Progress: [█████████░] 93%

## Performance Metrics

**Velocity:**

- Total plans completed: 1
- Average duration: 4 min
- Total execution time: 0.1 hours

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| - | - | - | - |

**Recent Trend:**

- Last 5 plans: -
- Trend: -

*Updated after each plan completion*
| Phase 01-quality-foundation P03 | 18min | 2 tasks | 12 files |
| Phase 01-quality-foundation P04 | 9min | 2 tasks | 8 files |
| Phase 01 P05 | 15 | 2 tasks | 3 files |
| Phase 02-data-layer P01 | 525711min | 1 tasks | 13 files |
| Phase 02-data-layer P01 | 35min | 1 tasks | 13 files |
| Phase 02-data-layer P02 | 3min | 2 tasks | 9 files |
| Phase 02-data-layer P03 | 2min | 1 tasks | 4 files |
| Phase 03-price-comparison-market-detail P01 | 3 | 3 tasks | 10 files |
| Phase 03-price-comparison-market-detail P02 | 2 | 2 tasks | 3 files |
| Phase 03-price-comparison-market-detail P03 | 2 | 1 tasks | 1 files |
| Phase 03-price-comparison-market-detail P04 | 2 | 1 tasks | 2 files |
| Phase 03-price-comparison-market-detail P05 | 5 | 3 tasks | 13 files |
| Phase 04-cart-comparison P01 | 10 | 2 tasks | 2 files |
| Phase 04-cart-comparison P02 | 36 | 2 tasks | 10 files |
| Phase 04.1 P01 | 3 | 2 tasks | 2 files |
| Phase 04.2-backend-data-pipeline P01 | 18 | 2 tasks | 16 files |
| Phase 04.2-backend-data-pipeline P02 | 3 | 2 tasks | 3 files |
| Phase 04.2 P03 | 2 | 2 tasks | 5 files |
| Phase 04.3 P02 | 3 | 2 tasks | 7 files |
| Phase 04.3-backend-api-and-flutter-integration P01 | 3 | 2 tasks | 6 files |
| Phase 04.3 P03 | 45 | 2 tasks | 0 files |
| Phase 05-fcm-push-notifications P01 | 3 | 2 tasks | 8 files |
| Phase 05-fcm-push-notifications P02 | 4 | 3 tasks | 7 files |

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Recent decisions affecting current work:

- [Init]: FavoritesStore migration must precede DATA phase to prevent silent favorites corruption when ProductItem gains PricePoint field
- [Init]: Result<T> typed error fix must precede real API wiring — otherwise network error debugging becomes impossible
- [Init]: TextNormalizer extraction must precede any new search/display code to avoid deepening the bug-prone duplication
- [01-02]: AsyncNotifier used for FavoritesNotifier — build() handles async SharedPreferences init, eliminating manual init() in main()
- [01-02]: Same SharedPreferences key 'favorite_products' preserved — existing user favorites survive migration without data loss
- [01-02]: FavoritesStore retained with deprecation comment; deletion deferred to Phase 1 verification
- [Phase 01-03]: MarketDetailHeaderWidget bundles info card + statistics card — same data, always render together
- [Phase 01-03]: ProductPriceSection uses MarketPriceItem not ProductItem — productMarketPricesProvider returns List<MarketPriceItem>
- [Phase 01-03]: _HomeFavoritesSection kept private in home_page.dart — receives AsyncValue from ConsumerWidget context, separate file adds no isolation
- [Phase 01-quality-foundation]: All widget tests must call pumpAndSettle() to drain mock datasource Future.delayed timers — bare pumpWidget leaves pending timers causing test assertion failures
- [Phase 01-quality-foundation]: Material3 NavigationBar renders label text twice (visible + semantics) — use findsAtLeastNWidgets(1) not findsOneWidget for navigation label assertions
- [Phase 01]: Uppercase Turkish replacements placed before toLowerCase() — platform-inconsistent Unicode folding means İ.toLowerCase() may not yield i on all Flutter targets
- [Phase 01]: Added .trim() to TextNormalizer.normalize() to preserve discounts_page original behavior when duplicate _normalizeText() was removed
- [Phase 02-data-layer]: @Default([]) for priceHistory on ProductItem — backward-compatible Freezed extension, zero breaking changes to existing constructors
- [Phase 02-data-layer]: Turkish month names as const array in displayDate getter — avoids intl dependency while delivering correct Unicode characters
- [Phase 02-data-layer]: DateTime type for DiscountItem.validUntil — json_serializable 6.x parses ISO 8601 natively, no custom converter needed
- [Phase 02-data-layer]: Error envelope extraction placed before status-code branches in _handleException — avoids repeating body/errorObj locals per branch, backward-compat fallback to body[message] preserved
- [Phase 02-data-layer]: getProductsByMarket added only to ProductRemoteDataSource, not ProductLocalDataSource — market-filtered lists are always fetched live, no caching needed
- [Phase 02-data-layer]: Widget tests must use ProviderScope.overrides to inject mock repository — global provider wiring is now remote, not mock
- [Phase 03-price-comparison-market-detail]: fl_chart ^0.69.0 chosen over 1.x — Flutter SDK constraint ^3.11.1 does not guarantee Flutter 3.27.4+ required by fl_chart 1.x
- [Phase 03-price-comparison-market-detail]: MarketBrand logoAsset and bannerAsset set to null initially — fallback rendering (solid color + Icons.store) activates in Plans 02/03
- [Phase 03-price-comparison-market-detail]: Turkish month names as const array in PricePoint.displayDate — avoids intl dependency for a 12-element string lookup
- [Phase 03-price-comparison-market-detail]: filteredPoints reused for tooltip lookup — avoids index mismatch if only a date-range subset of priceHistory is charted
- [Phase 03-price-comparison-market-detail]: Disabled tabs use onTap: null not just grey color — satisfies UI-SPEC D-09 interaction contract and prevents ghost taps
- [Phase 03-price-comparison-market-detail]: TimeRange enum defined in same file as widget — no shared usage across features, co-located avoids premature abstraction
- [Phase 03-price-comparison-market-detail]: Builder widget used for local brand variable scoping in MarketDetailHeaderWidget — avoids converting to StatefulWidget for a one-line const map lookup
- [Phase 03-price-comparison-market-detail]: SizedBox(height: 36) after banner = 28px logo overlap + 8px gap — ensures logo clearance before Market Info Card
- [Phase 03-price-comparison-market-detail]: DateTime.utc() for all PricePoint dates — platform-consistent time arithmetic ensures tab filter cutoffs work on all platforms
- [Phase 03-price-comparison-market-detail]: p2 intentionally missing 365d priceHistory data — demonstrates disabled 1Y tab for products with limited price history
- [Phase 03-price-comparison-market-detail]: Slug IDs (migros, a101, bim, sok, carrefoursa) replace numeric IDs (m1-m5) as primary keys — aligns mock data with marketBrands map keys
- [Phase 04-cart-comparison]: Id-based dedup (p.id == product.id) in CartNotifier — Freezed equality on ProductItem with List<PricePoint> priceHistory is fragile for cart dedup semantics
- [Phase 04-cart-comparison]: No toggle() on CartNotifier — cart add/remove are asymmetric operations; favorites toggle is primary UX verb but cart is not
- [Phase 04-cart-comparison]: await cartNotifierProvider.future before reading cartComparisonProvider in tests — FutureProvider watching AsyncNotifier requires notifier to be in AsyncData state first
- [Phase 04-cart-comparison]: CartMarketResult as plain Dart class (not Freezed) — no serialization needed, simpler for isCheapest mutation pattern
- [Phase 04-cart-comparison]: 0-match markets sorted to bottom in cartComparisonProvider — showing 0.00 TL total at top would falsely appear cheapest
- [Phase 04.1]: market_products.id is Flutter ProductItem.id — canonical products.id is internal to backend (D-02)
- [Phase 04.1]: GET /products/{id}/prices: {id} is market_products.id, backend resolves canonical product_id via JOIN (D-05)
- [Phase 04.1]: Dedicated discounts table chosen over view — discounts have own lifecycle (valid_until, old_price, new_price) not derivable from price_history
- [Phase 04.2-01]: pyproject.toml uses unpinned/range versions to survive Python 3.14 pip resolution — pinned versions from plan were reference targets
- [Phase 04.2-01]: init_db() uses sqlite3.executescript() not SQLAlchemy create_all() — DB-SCHEMA.sql is frozen source of truth
- [Phase 04.2-01]: upsert_product() returns market_product.id (Flutter ProductItem.id, D-02), flushes without committing — caller batches commits
- [Phase 04.2-02]: Migros endpoint: GET /rest/products/search?q={kw}&sayfa={page} returns JSON; prices in kurus (divide by 100 for TL); brand is dict with name key; homepage prefetch obtains Cloudflare cookie
- [Phase 04.2-02]: 3 search keywords (sut/ekmek/yag) x 2 pages = ~120-180 unique products for demo data; dedup by product id across keywords using seen_ids set
- [Phase 04.2]: Lifespan pattern replaces @app.on_event — deprecated since FastAPI 0.93; init_db() called before scheduler.start() prevents OperationalError on first startup (Pitfall 4)
- [Phase 04.2]: run_scrape_cycle imported lazily inside lifespan and admin handler to avoid circular imports at module load time
- [Phase 04.3-02]: getProductPrices stub in ProductMockDataSourceImpl returns empty list — mock datasource no longer used in production wiring, stub satisfies interface contract
- [Phase 04.3-02]: Base URL set to http://10.0.2.2:8000/api/v1 for Android emulator; LAN_IP comment added for physical device testing
- [Phase 04.3-01]: search routes defined before /{id} routes in each router file — FastAPI matches in definition order; /search after /{id} would match search as an id value
- [Phase 04.3-01]: JSONResponse returned directly for 404 errors — allows locked error envelope without FastAPI HTTPException wrapping
- [Phase 04.3-01]: raise_server_exceptions=False on TestClient — allows testing 404 responses without pytest raising for non-2xx
- [Phase 04.3-03]: Price history chart shows graceful empty state for demo-volume data — expected behavior, chart UI correct, will self-resolve as scraper accumulates history
- [Phase 04.3-03]: Turkish character search normalization is inconsistent (typing 'süt' produces 'st') — non-blocking UX issue, fix: apply TextNormalizer.normalize() to query string in productsProvider
- [Phase 05-01]: navigatorKey exported from notification_handler.dart — single source of truth for global navigation key avoids circular imports
- [Phase 05-01]: minSdk = 21 hardcoded (not flutter.minSdkVersion) — FCM HTTP v1 API requires API 21+, overrides Flutter default
- [Phase 05-01]: ProductItem with empty fields used for notification tap navigation — detail page fetches real data via productMarketPricesProvider, only id needed
- [Phase 05-02]: WatchList is a plain Dart class (not Freezed) — no serialization needed, IDs only; simpler for toggle pattern
- [Phase 05-02]: device_subscriptions table created via CREATE TABLE IF NOT EXISTS in subscribe endpoint — avoids schema migration complexity for a simple new table
- [Phase 05-02]: firebase-admin version relaxed to >=6.0 (7.4.0 installed) — original <7 upper bound had no documented incompatibility

### Roadmap Evolution

- Phase 4.1 inserted after Phase 4: Live Data Foundation (INSERTED) — API contract, DB schema, product-market matching, price-history model
- Phase 4.2 inserted after Phase 4.1: Backend Data Pipeline (INSERTED) — scraper service, DB writes, price-history persistence, scheduled refresh, logging
- Phase 4.3 inserted after Phase 4.2: Backend API and Flutter Integration (INSERTED) — REST API endpoints, mock→remote datasource switch, e2e verification

### Pending Todos

None yet.

### Blockers/Concerns

- [Phase 2 readiness]: Backend scraping API contract must be finalized before remote datasource implementations are written
- [Phase 5 readiness]: iOS APNs Auth Key (p8 file) must be uploaded to Firebase Console before any FCM Dart code is written; budget 1-3 days provisioning time
- [Phase 5 readiness]: Verify android/app/build.gradle minSdkVersion is 21+ before starting Phase 5 (FCM v1 API requirement)

### Quick Tasks Completed

| # | Description | Date | Commit | Directory |
|---|-------------|------|--------|-----------|
| 260329-ogy | Restore mock datasources for Phase 3 UAT | 2026-03-29 | 35ba4e3 | [260329-ogy-restore-mock-datasources-for-phase-3-uat](.planning/quick/260329-ogy-restore-mock-datasources-for-phase-3-uat/) |

## Session Continuity

Last session: 2026-04-12T01:01:34.080Z
Stopped at: Completed 05-02-PLAN.md
Resume file: None
