# Project Research Summary

**Project:** FiyatCep
**Domain:** Flutter mobile grocery price comparison app (Turkish market)
**Researched:** 2026-03-27
**Confidence:** MEDIUM-HIGH

## Executive Summary

FiyatCep is a Flutter mobile app targeting Turkish grocery shoppers who want to compare prices across 7 supermarket chains (Migros, A101, BIM, CarrefourSA, Şok, Tarım Kredi, File Market). The current codebase has a solid Clean Architecture + Riverpod foundation with full mock data — this milestone adds the live data layer (scraping backend integration), price history charts, cart comparison, FCM push notifications, enriched market detail, and codebase quality improvements. The architecture is already well-designed for this transition: `repository_providers.dart` is the single swap point from mock to real datasources, and the existing `Result<T>` and `AppException` hierarchy provides typed error handling — though it is not yet used correctly in providers.

The recommended approach follows a strict build order: quality and model fixes must precede API wiring, API wiring must precede chart and notification features, and cart/notification features build on top of a live data layer. The most critical dependency is the scraping backend — if it is delayed, the Flutter side can still build and validate all UI features against mock data, but live integration testing will be blocked. The two new Flutter packages needed are `firebase_messaging` + `firebase_core` for FCM and `fl_chart` for price history charts; everything else (cart state, notification preferences) uses existing packages (Riverpod, SharedPreferences, Dio).

The top risks are: (1) Turkish supermarket sites blocking the scraper (Migros and CarrefourSA are highest risk; residential proxy rotation is mandatory for production reliability), (2) iOS FCM silently failing without APNs Auth Key configuration in Firebase Console — a pure infrastructure mistake that produces no code-level errors, and (3) the existing `FavoritesStore` singleton causing data corruption when `ProductItem` gains new fields. All three risks are avoidable with the correct build order and pre-work, but they must be addressed proactively — not discovered post-launch.

---

## Key Findings

### Recommended Stack

The existing stack (flutter_riverpod 2.6.1, freezed 2.5.8, dio 5.9.2, shared_preferences 2.5.4) is sufficient for all new features except push notifications and charts. Only three new packages are needed: `firebase_core ^3.6.0` and `firebase_messaging ^15.1.0` (must be added together — firebase_messaging will crash without firebase_core), and `fl_chart ^0.69.0` for price history line charts. `mockito ^5.4.0` is needed as a dev dependency for repository unit tests. The backend scraping service is a separate concern from Flutter and requires Python + Playwright (for JavaScript-rendered supermarket sites) with residential proxy rotation — this is non-negotiable for Migros and CarrefourSA which use Cloudflare/DataDome bot protection.

One non-package platform requirement demands early attention: `minSdkVersion` in `android/app/build.gradle` must be 21+ for FCM v1 API compatibility. The current project may be set lower. This must be verified and bumped before any FCM code is written.

**Core technologies:**
- `firebase_core ^3.6.0` + `firebase_messaging ^15.1.0`: FCM push notifications — only first-party option for Flutter; both required together
- `fl_chart ^0.69.0`: Price history line chart and market comparison bar chart — dominant Flutter chart library, pure Flutter (no native bridges)
- `mockito ^5.4.0` (dev): Repository unit tests — standard Dart mock library, compatible with existing build_runner
- Python + Playwright + residential proxies (backend, not Flutter): Required to scrape JS-rendered Turkish supermarket sites at production reliability
- PostgreSQL + Redis (backend): Normalized price history storage and job queue for scraping scheduler

**What NOT to add:**
- `charts_flutter` — Google officially archived in 2022
- `syncfusion_flutter_charts` — commercial license required
- Scraping from within the Flutter app — bot protection, ToS violations, CORS blocks

### Expected Features

The milestone adds all features required for a functional demo/beta. Price comparison and favorites already exist; this milestone completes the value loop with live data, price history trends, cart comparison (the key differentiator — Turkish competitors Cimri and Akakce do not offer basket-level comparison), and price-drop notifications (the re-engagement mechanism).

**Must have (table stakes for this milestone — P1):**
- Price history chart on product detail (1W/1M/3M/1Y time selector, line chart, tap for exact price) — industry standard since Amazon/Camelcamelcamel; Turkish apps Akakce and Cimri both provide this
- Market price side-by-side comparison enhancement (cheapest highlighted, "X ₺ daha ucuz" savings delta) — already partially built, needs visual ranking clarity
- Cart comparison (build cart → compare total per market → show match rate "7/9 ürün mevcut") — key differentiator; must be honest about partial stock
- FCM push notification integration (SDK + permission request + notification routing to ProductDetailPage)
- Product/discount watch list UI (subscribe/unsubscribe, synced to backend)
- Market detail logo + loyalty/card info (BIM Kart, Migros Money, A101 Kart) — static assets, no new API

**Should have (add within milestone — P2):**
- Price trend direction arrow (up/down + % change) on product list row — derives from price history, no extra backend calls
- Notification threshold ("X ₺ altına düşünce") — add when users report fatigue

**Defer (v2+):**
- Per-market price history overlay on chart — useful for power users; defer until basic chart validated
- Store locator / maps — significant new permissions and SDK
- Offline cache (Hive/SQLite) — explicitly deferred in PROJECT.md
- User accounts / auth — explicitly deferred in PROJECT.md
- Real-time price polling — Turkish supermarket prices change at most once per day; daily scraping is sufficient

**Anti-features to avoid:**
- User accounts for notification targeting — FCM device token is sufficient; auth doubles scope
- Product image scraping — copyrighted retailer assets, legal risk
- "Best deal" AI recommendations — misleading with partial data from 7 markets

### Architecture Approach

The existing Clean Architecture (presentation → Riverpod providers → domain repositories → data datasources → ApiClient/Dio) requires two new feature modules (`features/cart/` and `features/notifications/`), a `FcmService` singleton provider, migration of `FavoritesStore` to a `NotifierProvider`, and a `SharedPreferences` provider injected at app startup to make `build()` synchronous across all persistent state notifiers. The `repository_providers.dart` single-file datasource swap pattern means mock → real API integration is a 3-line change per datasource — the architecture already supports this. A `TextNormalizer` utility must be extracted from the 6+ copies of `_normalizeText` before any new search or display feature is added.

**Major components:**
1. `features/cart/` — own bounded context; owns `List<CartItem>` (productId + quantity), SharedPreferences persistence, and per-market total computation; reads from `productMarketPricesProvider` but products/markets do not know about cart
2. `features/notifications/` — `FcmService` (Provider singleton for token registration/refresh lifecycle) + `NotifPrefsNotifier` (NotifierProvider + SharedPreferences for watch list) — these are separate concerns within the same module
3. `FavoritesNotifier` migration — replace `FavoritesStore` singleton with `NotifierProvider<FavoritesNotifier>`; must happen before cart and notif prefs are built so all persistent mutable state follows the same pattern
4. `ProductItem` + `PricePoint` model extension — add `@Default([]) List<PricePoint> priceHistory` to Freezed factory; additive, non-breaking; `PricePoint` is a first-class model in `features/products/models/`
5. Remote datasource swap — `repository_providers.dart` 3-line change per datasource; must add `localDataSource` caching (currently always `null`) before real API wire-up

### Critical Pitfalls

1. **Scraping backend treated as reliable — no circuit breaker** — Add `lastScrapedAt` timestamp to all API responses; implement in-memory TTL cache in repository layer; return stale data with a `DataState.stale` flag rather than propagating errors to UI; backend must return partial results per-market so one failing scraper does not blank the whole app. Address in DATA phase, before mock→real swap.

2. **FCM iOS silent failure — APNs not configured** — Before writing any FCM Dart code, upload APNs Auth Key (p8 file, not p12 certificate) to Firebase Console under iOS app configuration; add `UIBackgroundModes: remote-notification` to `Info.plist`; always test on physical iOS device (simulator cannot receive FCM push). This produces no code-level error — FCM token is obtained, subscription appears successful, notifications are silently never delivered.

3. **FCM token rotation not handled** — Register `onTokenRefresh` listener on app start alongside initial `getToken()`; use a stable UUID (stored in SharedPreferences on first launch) as device identifier in the backend — never the FCM token itself; FCM tokens are ephemeral and rotate. If not handled, price-drop alerts silently stop working after token rotation.

4. **`Result<T>` bypassed by raw exception throws in all providers** — Every provider currently does `failure: (message, code) => throw Exception(message)`, discarding typed error information. This must be fixed in QUAL phase, and BEFORE the real API is wired — otherwise all network errors are indistinguishable strings and error debugging becomes extremely difficult.

5. **FavoritesStore schema corruption on ProductItem change** — `FavoritesStore` serializes full `ProductItem` to JSON in SharedPreferences. When `ProductItem` gains `priceHistory`, the stored JSON schema becomes incompatible and a bare `catch (_) {}` silently wipes all favorites. Fix: migrate FavoritesStore to Riverpod Notifier AND store only product IDs (not full objects) BEFORE adding `PricePoint` field in DATA phase.

6. **Price history chart frame drops** — Converting `List<PricePoint>` to `List<FlSpot>` inside `build()` runs on every rebuild. Extract chart as standalone `ConsumerWidget`; compute `FlSpot` list outside `build()`; limit default display to 30 data points; test on physical mid-range Android device.

---

## Implications for Roadmap

The build order is strictly dictated by dependencies. Quality/model fixes are not optional polish — several of them are blockers for later phases. The recommended phase structure mirrors the architecture build order from ARCHITECTURE.md.

### Phase 1: Quality Foundation and Model Preparation
**Rationale:** Three quality tasks are hard blockers for later phases: (a) `FavoritesStore` migration must precede DATA phase adding `PricePoint` (otherwise favorites data corrupts silently), (b) `Result<T>` fix must precede real API wiring (otherwise error debugging is impossible), and (c) `TextNormalizer` extraction must precede any new search/display code (otherwise the bug-prone duplication deepens). This phase also migrates `FavoritesStore` to the `NotifierProvider` pattern that Cart and NotifPrefs will follow — establishing the pattern before building on it.
**Delivers:** `TextNormalizer` utility; typed error handling in all providers; `FavoritesNotifier` replacing `FavoritesStore` singleton; `SharedPreferences` injected via provider at app startup; large page `build()` methods decomposed into smaller widgets; `CarrefourSA` naming normalized; foundational repository unit tests
**Features addressed:** QUAL-01, QUAL-02, QUAL-03, QUAL-04, QUAL-05, QUAL-06
**Pitfalls avoided:** FavoritesStore schema corruption (Pitfall 8), Result<T> bypass (Pitfall 4), large widget refactor breaking navigation (Pitfall 7)
**Research flag:** Standard patterns — skip research-phase. All tasks are internal refactors with well-established approaches.

### Phase 2: Data Layer and Model Extension
**Rationale:** Once the quality foundation is stable, extend `ProductItem` with `PricePoint`, fix `DiscountItem.validUntil`, and wire real remote datasources via `repository_providers.dart`. This phase also adds the in-memory repository cache (currently `localDataSource: null`) and stale-data handling required before any public demo. Backend API contract must be finalized at the start of this phase; Flutter development can proceed with mock data while the scraping backend is built in parallel.
**Delivers:** `PricePoint` model + `ProductItem.priceHistory` field; `DiscountItem.validUntil` as `DateTime`; `ProductRemoteDataSourceImpl`, `MarketRemoteDataSourceImpl`, `DiscountRemoteDataSourceImpl` with real Dio calls; `repository_providers.dart` swap from mock to real; repository-layer caching with `lastScrapedAt` stale indicator; backend API contract documented
**Features addressed:** DATA-01, DATA-02, DATA-03, DATA-04, MKTD-02
**Pitfalls avoided:** Scraping backend unreliability (Pitfall 1), no cache (tech debt), no debounce on search
**Research flag:** May benefit from research on Turkish supermarket site structures and scraping approaches if not already decided. Backend scraping is medium-confidence; must validate bot protection levels empirically per site. Flutter side is standard patterns — skip Flutter-specific research-phase.

### Phase 3: Price Comparison and Market Detail
**Rationale:** With live data flowing, price comparison enhancements (cheapest market highlight, savings delta) and market detail enrichment (logo, loyalty card info) are low-complexity, high-visibility improvements. This phase completes the core market browsing experience before adding the more complex cart and notification features.
**Delivers:** Market price side-by-side comparison with "X ₺ daha ucuz" savings delta and discount badge; price history line chart on ProductDetailPage (1W/1M/3M/1Y selectors, tap-for-price tooltip, empty state when no data); market detail logo + brand color header; BIM Kart/Migros Money/A101 Kart loyalty info (static data); `PriceHistoryChart` extracted as standalone `ConsumerWidget`
**Features addressed:** COMP-01, COMP-02, MKTD-01, MKTD-03
**Pitfalls avoided:** Chart frame drops (Pitfall 5) — chart extracted as standalone component from day one
**Research flag:** Standard patterns for fl_chart LineChart. Skip research-phase. Verify exact fl_chart version on pub.dev before adding to pubspec.yaml.

### Phase 4: Cart Comparison
**Rationale:** Cart comparison is the key differentiator for FiyatCep vs. Turkish competitors. It requires live product/market data (Phase 2 dependency) and the established `NotifierProvider` pattern from Phase 1. Cart state design must be decided upfront as a single `CartNotifier` with `CartState` — not accumulated as multiple StateProviders. Cart depends on `productMarketPricesProvider` but is its own bounded context (`features/cart/`).
**Delivers:** `CartItem` model and `CartNotifier` (NotifierProvider + SharedPreferences persistence); "Sepete Ekle" button on ProductDetailPage; `CartComparisonPage` showing per-market totals, match rate ("7/9 ürün mevcut"), and "Toplam tasarruf" banner; cart accessible from AppBar icon; honest handling of markets that don't stock all items; cart survives navigation and app restart
**Features addressed:** COMP-03
**Pitfalls avoided:** Cart state spaghetti (Pitfall 6) — single CartNotifier with CartState from day one; cart total computed inside CartNotifier, not in build()
**Research flag:** Standard patterns. Skip research-phase.

### Phase 5: FCM Push Notifications
**Rationale:** FCM is the most infrastructure-heavy feature and has the most cross-cutting dependencies: it requires the backend to have a device registration endpoint + subscription endpoint + price-comparison-after-scrape logic, AND requires iOS APNs pre-configuration before any Dart code is useful. This phase comes last among new features because it depends on live data (Phase 2) and the established Riverpod provider pattern (Phase 1), and its backend side can be built in parallel with Phases 3-4.
**Delivers:** `firebase_core` + `firebase_messaging` integrated; `FcmService` Provider singleton (token registration + `onTokenRefresh` listener + background handler); stable device UUID stored in SharedPreferences; `NotifPrefsNotifier` (NotifierProvider + SharedPreferences); "Takip Et" button on ProductDetailPage and DiscountsPage; permission request at correct moment (first "Takip Et" tap, with rationale text); notification tap routes to ProductDetailPage via deep link; backend endpoints: POST /devices/register, POST /notifications/subscribe, DELETE /notifications/subscribe
**Features addressed:** NOTIF-01, NOTIF-02, NOTIF-03
**Pitfalls avoided:** FCM iOS silent failure (Pitfall 2) — APNs key configured day one of this phase; FCM token rotation (Pitfall 3) — onTokenRefresh listener and stable UUID from initial implementation
**Research flag:** NEEDS deeper research-phase. FCM iOS setup is well-documented but error-prone (APNs Auth Key p8 vs p12, Xcode capabilities, AppDelegate delegate setup). Physical iOS device required for testing. FlutterFire releases frequently — verify exact firebase_messaging and firebase_core versions on pub.dev at start of this phase.

### Phase Ordering Rationale

- **Quality before data:** FavoritesStore migration and Result<T> fix are not optional — they are blockers that cause data corruption and impossible-to-debug errors if deferred past DATA phase
- **Data before UI features:** Price history chart, cart comparison, and notification subscription are all useless or misleading without real price data flowing
- **Cart before notifications:** Cart is self-contained Flutter state; notifications require both Flutter SDK work AND coordinated backend work — doing cart first keeps momentum while backend builds subscription endpoints
- **Notifications last:** Maximum backend dependency surface; benefits from all prior phases being stable; iOS provisioning work can be done in parallel with Phases 3-4

### Research Flags

Phases likely needing `/gsd:research-phase` during planning:
- **Phase 5 (FCM/Notifications):** iOS APNs setup is well-documented but has many silent failure modes; FlutterFire version churn means exact versions need verification at start of phase; background message handler Dart isolate constraints need careful review
- **Phase 2 (Data/Scraping backend):** Turkish supermarket bot protection levels must be validated empirically; scraping architecture (Playwright vs. requests+BS4 per site) should be confirmed with a spike before committing to a backend design

Phases with standard patterns (skip research-phase):
- **Phase 1 (Quality):** All internal refactors with well-established Riverpod 2.x patterns
- **Phase 3 (Price Comparison + Charts):** fl_chart LineChart is well-documented; market detail is static data
- **Phase 4 (Cart):** Riverpod NotifierProvider + SharedPreferences persistence is a standard pattern already established in Phase 1

---

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | MEDIUM-HIGH | Existing stack verified from pubspec.lock (HIGH). New packages (firebase_messaging, fl_chart) are dominant choices with no credible alternatives (HIGH on recommendation, MEDIUM on exact version numbers — verify on pub.dev before adding). Backend scraping stack is well-reasoned but Turkish supermarket bot protection levels are LOW confidence until empirically tested. |
| Features | MEDIUM | Based on established industry patterns (Akakce, Cimri, Trolley.co.uk, Idealo) and PROJECT.md requirements — both authoritative. Turkish loyalty card program details are training knowledge, not freshly verified. |
| Architecture | HIGH | Grounded in direct codebase analysis (pubspec.lock, repository_providers.dart, favorites_store.dart, product_item.dart). Build order and component boundaries are derived from actual dependency analysis, not speculation. |
| Pitfalls | HIGH | Grounded in both codebase analysis (existing anti-patterns found in code) and well-established Flutter/FCM/Riverpod failure modes. FCM iOS silent failure and token rotation issues are documented failure patterns. |

**Overall confidence:** MEDIUM-HIGH

### Gaps to Address

- **Android minSdkVersion:** Must check `android/app/build.gradle` before starting Phase 5. If current setting is <21, a bump is required for FCM v1 API — this is a breaking change for very old Android devices and needs a conscious decision.
- **Turkish supermarket bot protection (Phase 2):** Cannot be resolved without hands-on testing per site. Migros and CarrefourSA are the highest risk. Design backend with per-site circuit breakers from day one.
- **APNs setup timeline (Phase 5):** iOS push requires Apple Developer account enrollment + APNs key generation + Firebase Console configuration. Budget 1-3 days of provisioning work before any FCM Dart code can be tested on iOS. This is a project management dependency, not a code dependency.
- **firebase_messaging and fl_chart exact versions:** Both recommendations are based on training knowledge through August 2025. Verify current latest versions on pub.dev at the start of their respective phases.
- **Backend API contract finalization:** The API contract in ARCHITECTURE.md (Q5) is a recommended contract, not a finalized agreement with the backend team. Must be confirmed at the start of Phase 2 before remote datasource implementations are written.

---

## Sources

### Primary (HIGH confidence)
- `pubspec.lock` (direct inspection) — all existing package versions
- `.planning/codebase/CONCERNS.md` (direct inspection) — FavoritesStore singleton, Result<T> bypass, _normalizeText duplication, localDataSource null pattern
- `.planning/codebase/ARCHITECTURE.md` (direct inspection) — feature module structure, provider graph
- `lib/` codebase direct analysis — repository_providers.dart, favorites_store.dart, product_item.dart, providers

### Secondary (MEDIUM confidence)
- FlutterFire documentation (training knowledge, Aug 2025) — firebase_messaging lifecycle, iOS APNs requirements, token refresh
- fl_chart package documentation (training knowledge, Aug 2025) — LineChart API, FlSpot, LineTouchData
- Riverpod 2.x NotifierProvider patterns (training knowledge, well-established) — CartNotifier, FavoritesNotifier migration
- Competitor app analysis: Akakce, Cimri, Trolley.co.uk, Idealo (training knowledge) — feature expectations

### Tertiary (LOW confidence — validate empirically)
- Turkish supermarket site bot protection levels (training knowledge) — Migros Cloudflare, CarrefourSA DataDome, BIM/A101 lighter protection; must be tested per-site before committing to backend architecture
- Turkish loyalty card program details (training knowledge) — BIM Kart, Migros Money, A101 Kart; verify current program details before building market detail pages

---
*Research completed: 2026-03-27*
*Ready for roadmap: yes*
