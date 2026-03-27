# Pitfalls Research

**Domain:** Flutter mobile price comparison app with scraping backend, FCM push notifications, price history charts, cart comparison, and codebase refactoring
**Researched:** 2026-03-27
**Confidence:** HIGH (grounded in existing codebase analysis + established Flutter/FCM/scraping patterns)

---

## Critical Pitfalls

### Pitfall 1: Scraping Backend Treated as Reliable — No Circuit Breaker or Degraded State

**What goes wrong:**
The Flutter app calls the scraping backend as if it were a stable REST API. Turkish supermarket sites (Migros, A101, BIM, etc.) change their HTML structure, add anti-bot measures, or rate-limit without warning. When a scraper fails, the entire product list for that market returns empty or errors — with no indication to the user whether data is stale, partially missing, or unavailable. The app currently has no caching layer (`localDataSource` is always `null` in `ProductRepositoryImpl`), so a backend outage means the app shows nothing at all.

**Why it happens:**
Developers wire mock → real API and assume the reliability contract is the same. Scraping backends are fundamentally unreliable in ways REST APIs are not — they are adversarial by nature.

**How to avoid:**
- Add a `lastScrapedAt` timestamp to every API response. The Flutter app renders this prominently when data is older than a threshold (e.g., >4 hours).
- Implement response-level caching in the Flutter repository layer. Even an in-memory `Map<String, CachedResult>` with TTL prevents a single failed request from wiping the screen.
- Design `ProductRepositoryImpl` to return stale cached data with a `DataState.stale` flag rather than propagating the error to the UI.
- The backend should return partial results per market — one market failing should not block all seven.

**Warning signs:**
- `getAllProducts()` returns an empty list when any single market scraper fails.
- The UI shows a generic error on first load instead of cached data from the previous session.
- No `lastUpdated` field exists in any API response model.

**Phase to address:** DATA phase (mock → real API swap). Must be addressed before any public demo, not as a later quality task.

---

### Pitfall 2: FCM iOS Silent Failure — APN Certificates Not Configured Before Flutter Code

**What goes wrong:**
FCM on Android works with just the `google-services.json` file and minimal Dart code. iOS requires additional steps that are easy to miss: APNs authentication key (or certificate) uploaded to Firebase Console, background modes enabled in Xcode (`Remote notifications`), and `UNUserNotificationCenter` delegate set before `FlutterFire` initializes. If APN key is missing, iOS devices silently register for FCM but never receive notifications. No error is thrown — the FCM token is obtained, the subscription appears to succeed, and notifications are sent from the backend but never arrive.

**Why it happens:**
The iOS-specific setup lives in Xcode and Firebase Console, not in Dart code. Developers write the Flutter code, test on Android (where it works), then assume iOS is done. The Apple Developer account requirement (Team ID, Bundle ID, APNs key ID) is orthogonal to the Flutter codebase and easy to defer.

**How to avoid:**
- Before writing any FCM Dart code, complete the Apple Developer setup: create APNs Auth Key (p8 file) in Apple Developer Console, upload to Firebase Console under Project Settings → Cloud Messaging → Apple app configuration.
- In `ios/Runner/Info.plist`, add `UIBackgroundModes` with `remote-notification`.
- In `AppDelegate.swift`, ensure `UNUserNotificationCenter.current().delegate = self` is set.
- Test on a physical iOS device (not simulator — simulators cannot receive FCM push notifications).
- Verify both foreground and background notification delivery separately — they use different code paths.

**Warning signs:**
- FCM token is obtained on iOS but no notification arrives.
- Firebase Console "Test message" shows success but device shows nothing.
- No APNs configuration visible in Firebase Console → Project Settings → iOS app.
- Using iOS Simulator for notification testing.

**Phase to address:** NOTIF phase (FCM integration). iOS setup must be completed on day 1 of this phase, not at the end.

---

### Pitfall 3: FCM Token Management — Tokens Stored Nowhere, Refresh Not Handled

**What goes wrong:**
Without user accounts, FCM tokens must be stored per-device and refreshed when they change. `FirebaseMessaging.instance.getToken()` returns a token that can be rotated by Firebase at any time. If the app does not call `FirebaseMessaging.instance.onTokenRefresh.listen(...)` and persist the updated token to the backend, push notifications silently stop working after a token rotation. This is particularly critical for the price-drop alert feature (NOTIF-03) — a user subscribes to a product, their token rotates a week later, and they stop receiving alerts with no indication anything is wrong.

**Why it happens:**
The initial FCM integration tutorial shows getting the token once. Token rotation is a background concern that is not visible during development.

**How to avoid:**
- On app start: get token AND register the `onTokenRefresh` listener.
- Send both initial token and refreshed tokens to the backend via a `/devices` registration endpoint.
- The backend stores `(product_id, fcm_token)` pairs for subscriptions. Token rotation requires updating all subscriptions atomically.
- Since FiyatCep has no auth system (out of scope for this milestone), use a stable local device UUID (stored in SharedPreferences on first launch) as the device identifier — never the FCM token itself.

**Warning signs:**
- Token is fetched once in `initState` and never stored beyond the session.
- No `onTokenRefresh` listener in the codebase.
- Backend stores raw FCM tokens as user identifiers.
- Notification subscriptions break after reinstalling the app.

**Phase to address:** NOTIF phase. Token refresh handling must be part of the initial FCM implementation, not a follow-up.

---

### Pitfall 4: `Result<T>` Sealed Class Bypassed by Exception Re-throwing in All Providers

**What goes wrong:**
The project has a properly designed `Result<T>` sealed class and typed `AppException` hierarchy. However, every provider in the codebase currently does:
```dart
failure: (message, code) => throw Exception(message),
loading: () => throw Exception('Loading'),
```
This discards the typed error information before it reaches the UI. When the real API is wired up, network errors, 404s, and server 500s all arrive at the UI as identical `Exception` strings. The `AsyncValue.error` in Riverpod will contain an untyped `Exception`, making it impossible to render context-appropriate error messages (e.g., "Bu ürün artık mevcut değil" vs. "Bağlantı sorunu, lütfen tekrar deneyin").

**Why it happens:**
The mock datasource never actually fails, so the error branch was never exercised. The `throw Exception(message)` was written as a placeholder and never revisited.

**How to avoid:**
- In the QUAL phase, replace all `failure: (message, code) => throw Exception(message)` with either:
  - Returning typed `AppException` subclasses from repositories (preferred), or
  - Mapping the `Result` failure to a typed state object before the provider returns.
- The `loading:` case in a `FutureProvider` is always a bug — `FutureProvider` cannot return a `LoadingResult` from an `async` function. Remove all `loading: () => throw Exception('Loading')` branches.
- Add a Riverpod error handler at the `ProviderScope` level to catch unhandled errors during development.

**Warning signs:**
- `failure: (message, code) => throw Exception(message)` appears in any provider file.
- UI `error:` callback in `.when()` receives a plain `Exception` not an `AppException`.
- Any `loading:` case in a `FutureProvider`.

**Phase to address:** QUAL phase (error handling cleanup), but must be completed BEFORE wiring the real API in the DATA phase — otherwise error debugging becomes nearly impossible.

---

### Pitfall 5: Price History Data Volume Causes Flutter Frame Drops in Chart Rendering

**What goes wrong:**
When `ProductItem` gains a `List<PricePoint>` field (DATA-03), and the product detail page renders a price history chart (COMP-02), passing a large `List<PricePoint>` directly into a chart widget on every `build()` call causes unnecessary recomputation. If the chart library re-renders on every scroll event in the parent `SingleChildScrollView`, or if the `PricePoint` list is reconstructed each rebuild (not memoized), frame times exceed 16ms on mid-range Android devices. The existing `product_detail_page.dart` at 270 lines already has no subdivision — adding chart rendering inline will worsen this.

**Why it happens:**
Chart widgets like `fl_chart` accept `List<FlSpot>` which must be converted from `List<PricePoint>`. If this conversion happens in `build()` rather than being derived once, it runs on every rebuild triggered by any parent state change.

**How to avoid:**
- Compute the chart data series (`List<FlSpot>`) outside `build()` — either in a `select`-based derived provider or by caching it in the widget's `build` using `useMemoized` (if using hooks) or a `StatefulWidget` with `didUpdateWidget`.
- Extract the chart widget into its own `ConsumerWidget` so it only rebuilds when `priceHistory` data actually changes, not when other parts of the product detail page rebuild.
- Limit the default chart display to 30 data points; provide a toggle for full history. Do not pass 365 data points to the chart on first render.
- Test chart rendering on a physical mid-range Android device (not Pixel emulator) before considering it done.

**Warning signs:**
- Chart data conversion (`PricePoint` → `FlSpot`) happens inside `build()` method.
- Scrolling the product detail page triggers chart redraws (check Flutter DevTools "Rebuild" overlay).
- `product_detail_page.dart` grows beyond 350 lines after adding chart code.

**Phase to address:** COMP phase (price history charts). Chart widget must be extracted as a standalone component from the start.

---

### Pitfall 6: Cart Comparison State Becomes a Riverpod Provider Spaghetti

**What goes wrong:**
Cart comparison (COMP-03) requires: a list of selected products, quantities per product, total per market, and filtering/sorting. Without deliberate state design upfront, this becomes 4-6 separate `StateProvider`s that must all be read together in a cart summary widget. When a product is removed from the cart, 3 providers must update atomically. When the user navigates away and back, cart state either resets (bad UX) or is preserved inconsistently (some items disappear, totals don't recalculate).

**Why it happens:**
Simple features start with a `StateProvider<List<ProductItem>>` and accumulate additional providers as requirements grow. Each provider is added reactively rather than designed upfront.

**How to avoid:**
- Model the cart as a single `StateNotifierProvider` (or `NotifierProvider` if using Riverpod 2.x) with a `CartState` class that holds: `Map<String, CartItem>` (keyed by productId), computed totals per market, and an `isEmpty` guard.
- The `CartNotifier` exposes methods: `addItem`, `removeItem`, `updateQuantity`, `clear`. All state mutations go through these methods — no external `state =` assignments.
- Cart state should survive navigation (do not scope to a page's `ProviderScope` override).
- CartState totals (per-market sum) are computed inside `CartNotifier` as derived values, not as separate providers watching the cart provider.

**Warning signs:**
- More than 2 separate providers to represent the cart.
- Cart total computed in a widget's `build()` method by iterating `cartItems`.
- `ref.read(cartProvider)` called inside `build()` instead of `ref.watch()`.
- Cart state resets on navigation pop.

**Phase to address:** COMP phase (cart comparison). CartNotifier design must precede UI implementation.

---

### Pitfall 7: Large Widget Refactor Breaks Existing Navigation or State

**What goes wrong:**
`home_page.dart` (432 lines) and `market_detail_page.dart` (416 lines) are extracted into smaller widgets without first understanding how `BuildContext`, `WidgetRef`, and navigation are used inline. Common breakage patterns:
- An extracted widget calls `Navigator.of(context).push(...)` but the new widget's context is a descendant that lacks the correct `Navigator` ancestor.
- A `ref.watch(someProvider)` is moved into a child widget, but the child widget now rebuilds independently — causing a flash or double-fetch.
- The `FavoritesStore` (currently accessed as a static singleton, not via Riverpod) is wrapped into an extracted widget that doesn't have access to the singleton because it's initialized asynchronously in `main.dart`.

**Why it happens:**
Large `build()` methods are extracted mechanically by cut-and-paste without tracing data flow dependencies. The mix of Riverpod providers and the non-Riverpod `FavoritesStore` singleton makes dependency tracing especially error-prone.

**How to avoid:**
- Before extracting any widget: map all data dependencies (which providers, which static singletons, which `BuildContext` capabilities are used in the block being extracted).
- Migrate `FavoritesStore` to a proper `StateNotifierProvider` (QUAL concern) BEFORE or DURING the large widget refactor — not after. Doing refactor first locks in the singleton access pattern.
- Extract one widget at a time and run the app after each extraction. Do not batch all extractions into one commit.
- Prefer extracting to private `_SomeSection` widgets within the same file first, then move to separate files once boundaries are confirmed.
- Write widget tests for the page BEFORE refactoring. Tests that pass before and after confirm behavior is preserved.

**Warning signs:**
- `FavoritesStore.favoritesNotifier` accessed in an extracted widget without `addListener`.
- Navigation from an extracted widget crashes with "No MaterialApp ancestor found."
- Any extracted widget rebuilds visibly (shimmer flash) on page load when the parent page did not.

**Phase to address:** QUAL phase (large widget refactor). Must be done after FavoritesStore is Riverpod-ized.

---

### Pitfall 8: FavoritesStore Singleton Silently Breaks When Product Model Changes

**What goes wrong:**
`FavoritesStore` serializes `ProductItem` to JSON via `product.toJson()` and stores it in SharedPreferences. When `ProductItem` gains new fields (`List<PricePoint>` for DATA-03, new market metadata fields), the stored JSON schema is incompatible. `ProductItem.fromJson` will either silently drop the new fields (if they are optional) or throw a parse exception on `init()`, causing `FavoritesStore` to silently reset to an empty list (the `catch (_) {}` in `_loadFavorites` swallows all errors). Users lose their favorites after the update.

**Why it happens:**
SharedPreferences-based JSON serialization has no schema migration. The `catch (_)` in `_loadFavorites` masks the failure entirely.

**How to avoid:**
- Before adding any new required field to `ProductItem`, audit how it is stored in SharedPreferences and plan a migration.
- Make all new `ProductItem` fields nullable or provide defaults in `fromJson` to ensure backward compatibility.
- Replace `catch (_) {}` in `_loadFavorites` with explicit handling: log the error, and optionally show a one-time "Favoriler sıfırlandı" notification rather than silently losing data.
- Long term: migrate `FavoritesStore` to store only product IDs, not full product JSON. Product details are fetched from the API on app start. This eliminates the schema migration problem entirely.

**Warning signs:**
- `ProductItem` gains a new non-nullable field.
- `_loadFavorites` has a bare `catch (_) {}`.
- Favorites tab shows 0 items after an app update that changed `ProductItem`.

**Phase to address:** QUAL phase (FavoritesStore Riverpod migration). Do migration before adding `PricePoint` field in DATA phase.

---

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| `throw Exception(message)` in all providers | Compiles, mock data never fails so tests pass | All API errors become indistinguishable strings; impossible to localize errors | Never — even mock implementations should use typed exceptions |
| `localDataSource: null` in all repositories | No need to wire a cache implementation yet | Every navigation = fresh network call; scraping backend outage = blank screen | Only while mock data is the only source; must be fixed before real API integration |
| `FavoritesStore` as static singleton | No Riverpod migration needed | Untestable, product schema changes silently corrupt stored data, inconsistent with rest of app | Never for new code; acceptable as frozen legacy until migration phase |
| `_normalizeText` copy-pasted 6+ times | Fast to add per file | Turkish character bugs must be fixed in 6+ places; normalization inconsistency across pages causes missed search results | Never — consolidate before any new search feature is added |
| Hardcoded 600-800ms mock delays | Simulates "real" feel in demos | Unit tests run 3-5x slower than necessary; impossible to test timeout behavior | Acceptable in mock datasources if tests use `FakeAsync` or override the delay |
| No debounce on search input | Simpler code | Every keystroke triggers a provider rebuild and "network" call; with real API = N rapid requests per second | Never — debounce must be added before real API, not after |

---

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| FCM iOS | Testing on iOS Simulator | Always test FCM on a physical device; Simulator cannot receive remote pushes |
| FCM iOS | Uploading APN Certificate (.p12) instead of Auth Key (.p8) | Use APNs Auth Key (p8) — it does not expire, works for all apps in the account |
| FCM token lifecycle | Storing FCM token as a stable device identifier in the backend | Store a separate stable UUID; FCM token is ephemeral and rotates |
| FCM foreground messages | Only testing background notifications | Foreground messages require `FirebaseMessaging.onMessage` listener; background uses `onBackgroundMessage` — both must be tested |
| Scraping backend | Treating HTTP 200 with partial data as full success | Backend must return a per-market `status` field (`ok`/`failed`/`stale`) so Flutter can render partial results correctly |
| Scraping backend | No retry or backoff in Flutter API client | Dio's `ApiClient` has no retry interceptor; add `dio_smart_retry` or implement exponential backoff for scraping backend endpoints specifically |
| `fl_chart` / chart library | Passing raw `DateTime` timestamps as X-axis values without normalization | Turkish locale date formatting must use the same `TextNormalizer` utility to avoid inconsistent display |
| Dio `ApiClient` | Timeout of 30s for all endpoints | Scraping backend endpoints may legitimately take 5-10s; product list endpoints should have a longer timeout than product detail |
| Freezed code generation | Adding `PricePoint` list field to `ProductItem` without running `build_runner` | Always run `dart run build_runner build --delete-conflicting-outputs` after any Freezed model change; generated `.freezed.dart` and `.g.dart` files must be committed |

---

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| No debounce on search, real API | Each keystroke fires an HTTP request; UI stutters; backend rate-limits the app | Add `Duration(milliseconds: 300)` debounce using `Timer` or `ref.debounce()` pattern before wiring real API | At first real user typing |
| `productsProvider` fetched once, then `productsByMarketProvider` filters client-side | Fine with 50 mock products; memory spike + 300ms+ filter time with 2000+ real products per market | Add server-side filtering: `getProductsByMarket(marketId)` endpoint; client-side filter only for cached subset | ~500+ products in full dataset |
| Price history chart re-renders on every scroll | Janky scroll in `product_detail_page`; Flutter DevTools shows chart widget in rebuild list constantly | Extract chart as standalone `ConsumerWidget`; memo-ize `FlSpot` list outside `build()` | Immediately visible on any real device |
| `FutureProvider.family` with string key — no caching eviction | Memory grows unboundedly as user browses products | Use `keepAlive: false` (default) — providers dispose when unwatched; verify no stale `.family` subscriptions hold references | After browsing 50+ products in a session |
| Cart total computed in widget `build()` | UI lag when cart has many items; recomputes on any unrelated state change | Compute totals inside `CartNotifier`; expose as derived fields on `CartState` | ~20+ items in cart |

---

## Security Mistakes

| Mistake | Risk | Prevention |
|---------|------|------------|
| No input sanitization on search queries | Malformed queries could expose internal API error structure; if backend uses search strings in scraping URLs, could enable SSRF-adjacent abuse | Sanitize and length-limit search queries client-side before sending to API (`query.trim().substring(0, 100)`) |
| FCM topic subscriptions without validation | Subscribing to topic `/topics/price-alert-*` client-side allows any client to subscribe to any product's alerts without backend validation | Do not use FCM topic subscriptions; use server-side token registration — backend sends targeted FCM messages to registered tokens only |
| API base URL hardcoded in `api_client.dart` as placeholder | `https://api.example.com/api/v1` will still be in code if not replaced before build | Use `--dart-define` build-time environment variables for API base URL; never commit real backend URL in source |
| `catch (_) {}` in `_loadFavorites` silently hides data corruption | User loses favorites silently; no log for debugging | Replace with `catch (e, st) { debugPrint(...); }` at minimum; add crash reporting in production |
| Dio client has no certificate pinning | Acceptable for demo/beta; MITM possible in public WiFi scenarios | Acceptable for this milestone per PROJECT.md; add pinning in production hardening milestone |

---

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| Showing "Veri bulunamadı" when scraping backend partially fails | User thinks no products exist for a market, not that data is temporarily unavailable | Show "Veriler [X] saat önce güncellendi" with a stale indicator; never show empty state for a market known to exist |
| Price history chart with insufficient data points | Chart renders a flat line or single dot for newly tracked products | Show a "Fiyat geçmişi henüz yok" placeholder with a "Takibe Al" CTA when fewer than 2 data points exist |
| Push notification without deep link | User receives "BİM'de fiyat düştü" notification, taps it, lands on home screen | Every FCM notification payload must include `productId`; `onMessageOpenedApp` handler must route to `ProductDetailPage(product)` |
| Cart comparison showing "en ucuz" without availability caveat | User goes to market only to find product is out of stock or price changed | Display `lastCheckedAt` on cart comparison; add "Fiyatlar değişmiş olabilir" disclaimer |
| Favorites showing stale product data (old price) | User sees a price from when they favorited the product, not current price | Favorites tab should show a "son güncelleme" timestamp or refresh prices on tab entry |

---

## "Looks Done But Isn't" Checklist

- [ ] **FCM iOS integration:** `google-services.json` added and Android works — verify APNs Auth Key is uploaded to Firebase Console and `UIBackgroundModes` is in `Info.plist`
- [ ] **FCM token refresh:** Token is obtained on startup — verify `onTokenRefresh` listener is registered and sends updated token to backend
- [ ] **Mock → real API swap:** `repository_providers.dart` updated — verify `localDataSource` is also wired (not left as `null`), caching is active, and stale-data handling exists
- [ ] **Price history chart:** Chart renders in `product_detail_page` — verify chart does not re-render on parent scroll, and renders correctly with 1-point and 0-point datasets
- [ ] **Cart comparison:** Cart adds and removes products — verify cart persists across tab navigation and cart totals recalculate when product prices update
- [ ] **FavoritesStore migration:** Riverpod provider created — verify existing SharedPreferences data is migrated (not silently wiped) after the refactor
- [ ] **Turkish text normalization:** `TextNormalizer` utility created — verify all 6 `_normalizeText` copies are removed and search results are identical to pre-refactor behavior
- [ ] **Error handling:** `throw Exception(message)` removed from providers — verify each `AppException` subtype is handled separately in the UI with distinct user-facing messages
- [ ] **CarrefourSA naming:** Inconsistency fixed in one place — verify `"Carrefoursa"` and `"CarrefourSA"` are normalized at the data layer, not just renamed in visible strings

---

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Scraping backend unreliability discovered post-launch | MEDIUM | Add `lastScrapedAt` field to API response; implement response cache in `ProductRepositoryImpl`; display stale data indicator; backend adds partial-failure status per market |
| FCM iOS not working (missing APNs key) | LOW | Upload APNs Auth Key p8 to Firebase Console; add `UIBackgroundModes` to `Info.plist`; rebuild; no Dart code changes required |
| FCM tokens stale (users not receiving alerts) | MEDIUM | Add `onTokenRefresh` listener; backend endpoint to update all subscriptions for a given old token → new token; send bulk re-registration request on next app open |
| Cart state scattered across multiple providers | HIGH | Consolidate into `CartNotifier`; requires migrating all cart UI reads to the new single provider; test each cart interaction |
| FavoritesStore data loss after ProductItem schema change | MEDIUM | Add migration in `_loadFavorites`: catch parse failures individually per stored item; skip unparseable items rather than wiping all; log how many were skipped |
| Large widget refactor causes navigation breakage | LOW-MEDIUM | Revert to pre-refactor file; re-extract one section at a time; add widget tests before re-attempting |

---

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Scraping backend unreliability / no stale data handling | DATA phase (before mock → real swap) | Repository layer test: simulate backend 500 — verify cached data is returned, not empty list |
| FCM iOS APNs not configured | NOTIF phase, day 1 | Send test FCM message from Firebase Console to a physical iOS device before writing any Dart code |
| FCM token rotation not handled | NOTIF phase, initial implementation | Delete app, reinstall, verify backend receives updated token; send notification to verify delivery |
| `Result<T>` bypassed by raw exception throws | QUAL phase (must precede DATA phase) | Grep: zero occurrences of `throw Exception(` in any `*_provider.dart` file |
| Price history chart frame drops | COMP phase (chart implementation) | Flutter DevTools: chart widget must NOT appear in rebuild list during page scroll |
| Cart state as multiple providers | COMP phase (cart design upfront) | Single `CartState` class; no cart-related logic outside `CartNotifier` |
| Large widget refactor breaks navigation/state | QUAL phase (after FavoritesStore migration) | All existing widget tests pass before and after each extraction step |
| FavoritesStore schema incompatibility | QUAL phase (before DATA phase adds new fields) | Add `priceHistory: []` default to `ProductItem.fromJson`; test with pre-migration SharedPreferences data |
| No debounce on search | QUAL phase (before real API wire-up) | Network tab: single request emitted 300ms after last keystroke, not one per keystroke |

---

## Sources

- Codebase analysis: `/lib/core/errors/`, `/lib/features/*/presentation/providers/`, `/lib/features/favorites/data/favorites_store.dart`, `/lib/shared/providers/repository_providers.dart`
- Identified concerns: `.planning/codebase/CONCERNS.md`
- Project requirements and constraints: `.planning/PROJECT.md`
- Flutter/FCM iOS known issues: established pattern from `firebase_messaging` package documentation (APNs requirement, simulator limitation, `onTokenRefresh` necessity)
- Riverpod state management: established patterns from Riverpod 2.x documentation (`StateNotifierProvider` vs. multiple `StateProvider`s for related state)
- Freezed serialization: known behavior that `catch (_) {}` in `fromJson` silently drops fields when schema changes

---
*Pitfalls research for: FiyatCep — Flutter price comparison app (scraping backend + FCM + charts + cart + refactor milestone)*
*Researched: 2026-03-27*
