# Architecture Research

**Domain:** Mobile price comparison app (Flutter + Clean Architecture + Riverpod)
**Researched:** 2026-03-27
**Confidence:** HIGH — based on direct codebase analysis, established Flutter/Riverpod patterns

## Standard Architecture

### System Overview

```
┌────────────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                               │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐  │
│  │ Products │  │ Markets  │  │Discounts │  │Favorites │  │  Cart   │  │
│  │  Page    │  │  Page    │  │  Page    │  │  Page    │  │  Page   │  │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬────┘  │
│       │              │              │              │             │       │
│  ConsumerWidget watches Riverpod providers via ref.watch()              │
├───────┴──────────────┴──────────────┴──────────────┴─────────────┴─────┤
│                      RIVERPOD PROVIDER LAYER                            │
│  ┌────────────────┐  ┌────────────────┐  ┌──────────────────────────┐  │
│  │ FutureProvider │  │ NotifierProvider│  │ StreamProvider           │  │
│  │ (async data)   │  │ (mutable state)│  │ (FCM token stream)       │  │
│  └────────┬───────┘  └───────┬────────┘  └──────────────────────────┘  │
│  ┌────────────────────────────────────────────────────────────────┐     │
│  │  repository_providers.dart — single wiring point              │     │
│  └────────────────────────────────────────────────────────────────┘     │
├──────────────────────────────────────────────────────────────────────────┤
│                         DOMAIN LAYER                                     │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────────────┐ │
│  │ Product    │  │ Market     │  │ Discount   │  │ Cart / Notif Prefs │ │
│  │ Repository │  │ Repository │  │ Repository │  │ Repository (new)   │ │
│  │ (abstract) │  │ (abstract) │  │ (abstract) │  │ (abstract)         │ │
│  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘  └─────────┬──────────┘ │
├────────┴───────────────┴───────────────┴─────────────────────┴───────────┤
│                         DATA LAYER                                        │
│  ┌──────────────────────────┐  ┌───────────────────────────────────────┐  │
│  │ Remote Datasources        │  │ Local Datasources                     │  │
│  │  *_remote_datasource.dart│  │  favorites: SharedPreferences         │  │
│  │  (all currently mock)    │  │  cart: SharedPreferences              │  │
│  │  → swap via              │  │  notif_prefs: SharedPreferences       │  │
│  │    repository_providers  │  │                                       │  │
│  └───────────┬──────────────┘  └────────────────────────────────────────┘ │
│              │                                                              │
│  ┌───────────┴──────────────────────────────────────────────────────────┐  │
│  │                   ApiClient (Dio)                                     │  │
│  │   GET /products    GET /markets    GET /discounts                    │  │
│  │   GET /products/:id/prices         GET /products/:id/history         │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────────────────┘
                                    │
                          ┌─────────┴──────────┐
                          │  EXTERNAL SERVICES  │
                          │  ┌───────────────┐  │
                          │  │  Scraping API  │  │
                          │  │  (7 markets)  │  │
                          │  └───────────────┘  │
                          │  ┌───────────────┐  │
                          │  │  FCM / APNs   │  │
                          │  └───────────────┘  │
                          └────────────────────┘
```

### Component Responsibilities

| Component | Responsibility | Implementation |
|-----------|----------------|----------------|
| `repository_providers.dart` | Single wiring point — swaps mock to remote | Existing file, 3-line change per datasource |
| `*_remote_datasource.dart` | HTTP calls against scraping API | Already stubbed, needs real Dio calls |
| `CartRepository` (new) | Persists cart items, computes per-market totals | SharedPreferences local datasource |
| `NotifPrefsRepository` (new) | Stores which product/discount IDs user is watching | SharedPreferences local datasource |
| `FcmService` (new) | Registers FCM token, receives messages, routes them | Wraps `firebase_messaging` package |
| `FavoritesNotifier` (migration) | Replace `FavoritesStore` singleton with Riverpod `Notifier` | `NotifierProvider` + SharedPreferences |

---

## Recommended Project Structure

```
lib/
├── core/
│   ├── errors/             # Result<T>, AppException hierarchy (existing)
│   ├── network/            # ApiClient Dio (existing)
│   └── utils/              # TextNormalizer (extract from duplicated code)
│
├── features/
│   ├── products/           # existing — extend model only
│   ├── markets/            # existing — wire remote datasource
│   ├── discounts/          # existing — wire remote datasource
│   │
│   ├── favorites/          # existing — migrate to Riverpod Notifier
│   │   └── data/
│   │       └── favorites_notifier.dart   ← replaces favorites_store.dart
│   │
│   ├── cart/               # NEW feature module
│   │   ├── data/
│   │   │   ├── datasources/cart_local_datasource.dart
│   │   │   └── repositories/cart_repository_impl.dart
│   │   ├── domain/
│   │   │   └── repositories/cart_repository.dart
│   │   ├── models/
│   │   │   └── cart_item.dart            # productId, quantity
│   │   └── presentation/
│   │       ├── providers/cart_provider.dart
│   │       └── cart_page.dart
│   │
│   └── notifications/      # NEW feature module
│       ├── data/
│       │   ├── fcm_service.dart          # token reg, message routing
│       │   ├── datasources/notif_prefs_local_datasource.dart
│       │   └── repositories/notif_prefs_repository_impl.dart
│       ├── domain/
│       │   └── repositories/notif_prefs_repository.dart
│       ├── models/
│       │   └── notif_preference.dart     # productId | discountId, threshold
│       └── presentation/
│           └── providers/notif_prefs_provider.dart
│
└── shared/
    ├── providers/
    │   ├── repository_providers.dart     # existing — add cart + notif entries
    │   └── api_client_provider.dart      # existing
    └── main_navigation.dart              # existing
```

### Structure Rationale

- **`features/cart/`:** Cart is cross-feature state (products + markets), but it is its own bounded context — it owns the list of items, the persistence, and the comparison computation. It depends on `ProductRepository` and `MarketRepository` via providers but is not merged into either.
- **`features/notifications/`:** FCM token lifecycle and notification preferences are distinct enough from favorites to warrant their own module. The preferences (what to watch) are local state; the delivery mechanism (FCM token, background message handler) is infrastructure.
- **`core/utils/TextNormalizer`:** The duplicated `_normalizeText` function appears in 6+ files. Extracting it before adding more datasources prevents the pattern from spreading further.

---

## Architectural Patterns

### Pattern 1: Single-file datasource swap (mock → remote)

**What:** Each datasource provider in `repository_providers.dart` returns a mock implementation today. Switching to real API is one line per provider.

**When to use:** At the start of any phase that introduces real API data.

**Trade-offs:** Centralizes the wiring decision cleanly; does not support A/B or fallback logic without additional plumbing.

**Example:**
```dart
// repository_providers.dart — before
final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((ref) {
  return ProductMockDataSourceImpl();
});

// repository_providers.dart — after (single-line swap)
final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProductRemoteDataSourceImpl(apiClient: apiClient);
});
```

### Pattern 2: NotifierProvider for persistent mutable state

**What:** Replace `FavoritesStore` (ValueNotifier singleton) and use the same pattern for `CartNotifier` and `NotifPrefsNotifier`. A `Notifier` class holds state, reads from SharedPreferences on construction, and writes back on mutations.

**When to use:** Any list of user-owned items that must survive app restarts — favorites, cart, notification preferences.

**Trade-offs:** Consistent with Riverpod lifecycle (testable, overridable in tests); slightly more boilerplate than a singleton but eliminates the out-of-band state problem.

**Example:**
```dart
class FavoritesNotifier extends Notifier<List<ProductItem>> {
  @override
  List<ProductItem> build() {
    // Read from SharedPreferences synchronously via loaded ref
    return ref.watch(sharedPreferencesProvider).getFavorites();
  }

  void toggle(ProductItem product) {
    state = isFavorite(product)
        ? state.where((p) => p != product).toList()
        : [...state, product];
    _persist();
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, List<ProductItem>>(
  FavoritesNotifier.new,
);
```

The key is pre-loading SharedPreferences into its own Riverpod provider at app startup so that `build()` is synchronous:

```dart
// In main():
final sharedPrefs = await SharedPreferences.getInstance();
runApp(ProviderScope(
  overrides: [sharedPreferencesProvider.overrideWithValue(sharedPrefs)],
  child: const FiyatCepApp(),
));
```

This removes the `FavoritesStore.init()` call from `main.dart` and makes the pattern uniform.

### Pattern 3: FCM token registration via Riverpod lifecycle

**What:** FCM token registration happens once at app startup. A `Provider` (not `FutureProvider`) holds an `FcmService` singleton. The service registers itself on first access and exposes a `Stream<String>` for token refreshes.

**When to use:** Any integration that requires once-per-install side effects (token registration, analytics init).

**Trade-offs:** Using a `Provider` for a service with side effects is idiomatic Riverpod. The alternative (calling registration in `main()`) moves infrastructure code outside the provider graph and makes it untestable.

**Example:**
```dart
final fcmServiceProvider = Provider<FcmService>((ref) {
  final service = FcmService();
  // Riverpod calls dispose when ProviderScope closes (test teardown)
  ref.onDispose(service.dispose);
  return service;
});

// App-level initialization — e.g., in MaterialApp builder or root ConsumerWidget
class AppStartup extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Reading the provider causes FcmService to instantiate and register
    ref.watch(fcmServiceProvider);
    return const MainNavigation();
  }
}
```

Inside `FcmService`:
```dart
class FcmService {
  FcmService() {
    _initialize();
  }

  Future<void> _initialize() async {
    await Firebase.initializeApp();
    final token = await FirebaseMessaging.instance.getToken();
    // POST token to backend: POST /api/v1/devices/register
    FirebaseMessaging.instance.onTokenRefresh.listen(_onTokenRefresh);
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
  }
}
```

### Pattern 4: Extending ProductItem with price history (additive, non-breaking)

**What:** Add `priceHistory` as an optional field with a default of `[]`. Existing code that constructs `ProductItem` without the field continues to compile. The Freezed code-gen handles the default.

**When to use:** Any model extension where existing construction sites must not be touched.

**Trade-offs:** Optional fields with defaults can hide the fact that a feature is missing data. The field should be documented clearly as "populated only when fetched via `/products/:id` detail endpoint."

**Example:**
```dart
@freezed
class ProductItem with _$ProductItem {
  const factory ProductItem({
    required String id,
    required String marketId,
    required String name,
    required String brand,
    required String market,
    required double price,
    required bool isDiscounted,
    @Default([]) List<PricePoint> priceHistory,   // ← additive, non-breaking
  }) = _ProductItem;
}

@freezed
class PricePoint with _$PricePoint {
  const factory PricePoint({
    required DateTime date,
    required double price,
    required String marketId,
  }) = _PricePoint;
}
```

The detail endpoint (`GET /products/:id`) returns the full model including history. The list endpoint (`GET /products`) may omit history for payload efficiency — the default `[]` handles that transparently.

---

## Data Flow

### Request Flow: Standard data load

```
User navigates to ProductsPage
    ↓
ref.watch(productsProvider)          [FutureProvider]
    ↓
productRepositoryProvider            [Provider → ProductRepository]
    ↓
productRemoteDataSourceProvider      [Provider → mock or real datasource]
    ↓
ProductRemoteDataSourceImpl.getAllProducts()
    ↓
ApiClient.get('/products')           [Dio]
    ↓
Result<List<ProductItem>>            [SuccessResult or FailureResult]
    ↓
Provider unwraps via .when()
    ↓
AsyncValue<List<ProductItem>>        [AsyncData or AsyncError]
    ↓
UI renders with .when(data, loading, error)
```

### Request Flow: Cart comparison (cross-feature)

```
User adds product to cart
    ↓
cartProvider.notifier.add(productItem)   [NotifierProvider mutation]
    ↓
CartNotifier.state updated + persisted to SharedPreferences
    ↓
CartComparisonPage watches:
  - cartProvider                         [List<CartItem>]
  - marketsProvider                      [List<MarketItem>]
  - For each market: price lookup via productMarketPricesProvider.family(productId)
    ↓
CartComparisonNotifier (derived state) computes per-market totals
    ↓
UI renders comparison table
```

The cart provider itself does not call an API — it is purely local state. The per-market price data comes from the existing `productMarketPricesProvider`.

### Request Flow: FCM notification received

```
FCM delivers push to device
    ↓
FirebaseMessaging.onBackgroundMessage handler (isolate)
    ↓
Show system notification via flutter_local_notifications
    ↓
User taps notification
    ↓
App opens with payload (productId or discountId)
    ↓
Navigation router reads payload → deep link to ProductDetailPage or DiscountPage
    ↓
ref.watch(productByIdProvider(productId))  [existing FutureProvider.family]
```

### Request Flow: Notification preference registration

```
User taps "Watch this product" on ProductDetailPage
    ↓
notifPrefsProvider.notifier.watch(productId)
    ↓
NotifPrefsNotifier persists to SharedPreferences
    ↓
POST /api/v1/notifications/subscribe { deviceToken, productId }
    ↓
Backend registers device for price-drop alerts on this product
```

Note: the subscribe call is a fire-and-forget side effect triggered from within the Notifier's mutation method, not a separate provider.

### State Management

```
Persistent mutable (favorites, cart, notif prefs):
  NotifierProvider → Notifier class → SharedPreferences

Async remote data (products, markets, discounts):
  FutureProvider → Repository → Datasource → ApiClient

FCM lifecycle:
  Provider<FcmService> → initialized on first watch → token sent to backend

Cross-feature derived state (cart totals):
  NotifierProvider reading multiple FutureProviders → computed synchronously
```

---

## Component Boundaries — Answers to Specific Questions

### Q1: Where does cart state live?

**Answer:** `features/cart/` as its own feature module, not inside products or markets.

**Boundary:** CartNotifier owns `List<CartItem>` (productId + quantity). It does not own `ProductItem` details or market prices — those come from existing providers. A `cartComparisonProvider` (derived, read-only) joins cart items with `productMarketPricesProvider` to compute totals. This keeps cart state independent of price data fetching.

**Communicates with:** `productMarketPricesProvider` (read), `marketsProvider` (read). Neither products nor markets know about cart.

### Q2: How should notification preferences be stored and managed?

**Answer:** `features/notifications/` module with a `NotifPrefsNotifier` using `NotifierProvider`. Storage is SharedPreferences (same pattern as migrated favorites).

**Schema:** A `NotifPreference` model holds `{ entityId, entityType (product|discount), priceThreshold? }`. Serialized as JSON list in SharedPreferences.

**Boundary:** NotifPrefs knows about product IDs and discount IDs but does not hold the product objects — those are fetched on demand when displaying the preferences list. The FCM token is managed by `FcmService`, not by NotifPrefs — they are separate concerns.

### Q3: How does FCM token registration integrate with Riverpod lifecycle?

**Answer:** `FcmService` is a `Provider<FcmService>` singleton. Initialization (Firebase.initializeApp, getToken, onTokenRefresh listener, background handler registration) happens in `FcmService._initialize()` called from the constructor.

The `Provider` is first watched in the root widget (a `ConsumerWidget` wrapping `MainNavigation`), which guarantees the service starts before any UI is shown.

Token is sent to backend via `POST /api/v1/devices/register`. On token refresh, the same endpoint is called again.

**iOS caveat:** `requestPermission()` must be called explicitly and the result checked before attempting to get a token. This requires platform detection — `Platform.isIOS` or checking `defaultTargetPlatform`.

**Important:** `Firebase.initializeApp()` must be called before `WidgetsFlutterBinding.ensureInitialized()` resolves in `main()`, or it must be awaited before `runApp`. The FcmService initialization is async; the Provider returns the service synchronously but initialization runs in the background. UI should not depend on FCM being ready before displaying.

### Q4: Extending ProductItem with price history

**Answer:** Add `@Default([]) List<PricePoint> priceHistory` to the Freezed factory. This is additive — all existing `ProductItem(...)` construction sites compile unchanged because Freezed treats it as an optional named parameter with a default.

**Model location:** `PricePoint` belongs in `features/products/models/price_point.dart`. It is a first-class model, not a nested type, because it will be used in the chart widget and potentially in the API response mapping.

**API contract implication:** The list endpoint (`GET /products`) should return `ProductItem` without history (bandwidth). The detail endpoint (`GET /products/:id`) returns the full model. The `productByIdProvider` fetches the detail; the chart widget watches this provider. The `priceHistory` field is never populated from the list endpoint — this is documented behavior, not a bug.

### Q5: Backend API contract for clean Flutter integration

**Answer:** The contract should mirror the existing domain models as closely as possible to minimize transformation in the remote datasource layer.

**Recommended contract:**

```
GET /api/v1/products
Response: { "items": [ProductItem without priceHistory] }

GET /api/v1/products/:id
Response: ProductItem with priceHistory: [{ date, price, marketId }]

GET /api/v1/products/:id/market-prices
Response: [{ marketId, market, price, isDiscounted }]  ← maps to MarketPriceItem

GET /api/v1/markets
Response: [MarketItem]

GET /api/v1/discounts
Response: [DiscountItem with validUntil as ISO 8601 string]

POST /api/v1/devices/register
Body: { token: string, platform: "android"|"ios" }

POST /api/v1/notifications/subscribe
Body: { token: string, productId?: string, discountId?: string, priceThreshold?: number }

DELETE /api/v1/notifications/subscribe
Body: { token: string, productId?: string, discountId?: string }
```

**Key decisions in this contract:**
- `validUntil` is ISO 8601 (`"2025-04-01T00:00:00Z"`) — Flutter parses with `DateTime.parse()`. Fixes the existing `String` type issue.
- Market prices are a separate endpoint, not embedded in product — avoids large payload on list views.
- Price history is only on the detail endpoint.
- Subscription is token-based (no user accounts needed for this milestone).

---

## Build Order (Dependencies Between Components)

The components form a dependency chain. Build in this order to avoid integration blockers:

```
Phase order:

1. Core fixes (no dependencies)
   ├── Extract TextNormalizer utility
   ├── Fix Result<T> usage in providers (typed errors)
   └── Migrate FavoritesStore → FavoritesNotifier (Riverpod)
       └── This unblocks: consistent pattern for cart + notif prefs

2. Model extensions (depends on: nothing breaking)
   ├── Add PricePoint model
   ├── Extend ProductItem with @Default([]) priceHistory
   └── Fix DiscountItem.validUntil String → DateTime
       └── This unblocks: backend API contract can be finalized

3. Backend API integration (depends on: models finalized)
   ├── Implement ProductRemoteDataSourceImpl (real Dio calls)
   ├── Implement MarketRemoteDataSourceImpl
   ├── Implement DiscountRemoteDataSourceImpl
   └── Swap in repository_providers.dart
       └── This unblocks: price history data, market detail real data

4. Cart feature (depends on: products + markets + FavoritesNotifier migration)
   ├── CartItem model
   ├── CartNotifier (NotifierProvider + SharedPreferences)
   └── CartComparisonPage (reads productMarketPricesProvider)

5. Notifications (depends on: backend API wired + FcmService)
   ├── FcmService (Provider, Firebase init, token reg)
   ├── NotifPrefsNotifier (NotifierProvider + SharedPreferences)
   └── Subscribe/unsubscribe calls to backend
       └── This depends on backend having the subscribe endpoint live

6. Chart/price history UI (depends on: model extension + API wired)
   └── PriceHistoryChart widget in ProductDetailPage
       └── Depends on productByIdProvider returning real history data
```

---

## Anti-Patterns

### Anti-Pattern 1: FavoritesStore Redux (adding more singletons)

**What people do:** Add `CartStore` and `NotifPrefsStore` as additional static singletons with ValueNotifier, following the existing `FavoritesStore` pattern.

**Why it's wrong:** State lives outside the Riverpod graph — not testable with `ProviderScope` overrides, not reactive to provider invalidation, initialization order is manual and fragile. The CONCERNS.md already identifies this as a known problem.

**Do this instead:** `NotifierProvider<FavoritesNotifier, List<ProductItem>>` with SharedPreferences injected via a provider override at app startup. All mutable persistent state follows the same pattern.

### Anti-Pattern 2: Cart embedded in products or markets feature

**What people do:** Put `CartNotifier` inside `features/products/presentation/providers/` because cart items are products.

**Why it's wrong:** Cart is a cross-feature concept (it relates products to markets via prices). Embedding it in products creates a circular dependency when the cart page tries to read market data. It also prevents reuse of cart logic from discount or market screens.

**Do this instead:** `features/cart/` is its own module. It depends on products and markets via providers, but neither products nor markets know about cart.

### Anti-Pattern 3: FCM initialization in main()

**What people do:** Call `Firebase.initializeApp()`, `FirebaseMessaging.instance.getToken()`, and register background handlers directly in `main()` before `runApp()`.

**Why it's wrong:** Untestable, mixes infrastructure with app bootstrap, and makes it impossible to override FCM behavior in widget tests. Background message handlers must be top-level functions (Flutter requirement), which is fine, but everything else can live in the provider graph.

**Do this instead:** `Provider<FcmService>` that initializes Firebase and registers the token in its constructor. The background message handler is a top-level function (required by Flutter) but is registered inside `FcmService._initialize()`.

### Anti-Pattern 4: Embedding price history in the list endpoint

**What people do:** Return full `priceHistory` on every product in `GET /products` to avoid a second request.

**Why it's wrong:** Price history can be 30-365 data points per product. At 50+ products in a list response, this is 1,500-18,000+ extra data points on every list load. Most users never view price history for most products.

**Do this instead:** Price history only on `GET /products/:id`. The extra detail-page request is acceptable latency. The `productByIdProvider` already does a separate fetch for the detail view.

---

## Integration Points

### External Services

| Service | Integration Pattern | Notes |
|---------|---------------------|-------|
| Scraping API (backend) | `ApiClient` (Dio) → remote datasources → repositories | Base URL in `ApiClient` constructor; swap in `repository_providers.dart` |
| Firebase Cloud Messaging | `FcmService` Provider singleton; `firebase_messaging` package | Requires `google-services.json` (Android) and `GoogleService-Info.plist` + APN cert (iOS) |
| SharedPreferences | Injected as `Provider<SharedPreferences>` at app startup | Replaces manual `FavoritesStore.init()` call in `main.dart` |

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| Cart ↔ Products | `cartProvider` reads `productMarketPricesProvider` (one-way) | Cart never writes to product state |
| Cart ↔ Markets | `cartComparisonProvider` reads `marketsProvider` (one-way) | Cart never writes to market state |
| Notifications ↔ Products | `notifPrefsProvider` stores productIds (primitive, not objects) | Decoupled — product objects fetched separately when displaying prefs list |
| Notifications ↔ FcmService | `notifPrefsProvider.notifier` calls `FcmService.subscribe(token, productId)` | One-way dependency; FCM does not know about preferences |
| Favorites ↔ Cart | Independent modules; favorites stores `ProductItem`, cart stores `CartItem` (productId + quantity) | No shared state; both persist to SharedPreferences under different keys |

---

## Scaling Considerations

| Scale | Architecture Adjustments |
|-------|--------------------------|
| Demo (< 100 users) | Mock → real API swap; no caching layer needed; pagination deferred |
| Beta (100-10k users) | Add response caching in repository layer (in-memory TTL cache); debounce search input |
| Store launch (10k+ users) | Server-side search endpoint; pagination on product list; SQLite or Hive for offline support |

### Scaling Priorities

1. **First bottleneck:** Client-side search filtering across all products on every keystroke. Fix: server-side search endpoint + 300ms debounce in the search provider.
2. **Second bottleneck:** Full product list loaded on every navigation (no caching). Fix: in-memory TTL cache in repository implementation (the `localDataSource` parameter is already wired as `null` — populate it).

---

## Sources

- Direct codebase analysis: `lib/shared/providers/repository_providers.dart`, `lib/features/favorites/data/favorites_store.dart`, `lib/features/products/models/product_item.dart`, `lib/features/products/presentation/providers/products_provider.dart`, `lib/core/errors/result.dart`, `lib/main.dart`
- Codebase concern catalog: `.planning/codebase/CONCERNS.md`
- Codebase architecture analysis: `.planning/codebase/ARCHITECTURE.md`
- Project requirements: `.planning/PROJECT.md`
- Riverpod 2.x `NotifierProvider` pattern: established Flutter community pattern (training data, HIGH confidence for Riverpod 2.x as used in this codebase per `pubspec.yaml: flutter_riverpod: ^2.4.0`)
- FCM Flutter integration pattern: `firebase_messaging` package standard lifecycle (training data, MEDIUM confidence — verify actual package version and background handler API at integration time)

---

*Architecture research for: FiyatCep — Flutter mobile price comparison app*
*Researched: 2026-03-27*
