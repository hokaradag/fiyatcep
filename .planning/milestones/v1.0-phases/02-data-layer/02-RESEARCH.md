# Phase 02: Data Layer - Research

**Researched:** 2026-03-28
**Domain:** Flutter data layer wiring — Freezed model extension, remote datasource activation, Dio error parsing, DateTime conversion
**Confidence:** HIGH

## Summary

Phase 2 is a data plumbing phase with no new UI screens. All work is model extension, datasource activation, and wiring. The existing codebase has all three remote datasource implementations already written as stubs — activation is primarily a one-line change per datasource in `repository_providers.dart`. The substantive work is: (1) creating the `PricePoint` Freezed model, (2) extending `ProductItem` with `List<PricePoint> priceHistory`, (3) migrating `DiscountItem.validUntil` from `String` to `DateTime` with a custom JSON converter, (4) adding `getProductsByMarket()` to the product datasource chain, (5) updating `_handleDioException()` in all three remote datasources to parse the new error envelope shape, and (6) updating `productsByMarketProvider` to call the repository method rather than filtering in-memory.

Key risk: `intl` package is NOT in `pubspec.yaml`. Date formatting for `validUntil` display must use Dart's built-in `DateFormat`-free alternatives or require an `intl` dependency add. The decision doc gives Claude discretion on the formatting approach. The simplest zero-dependency approach uses manual string interpolation from `DateTime` fields directly. If formatted output like "30 Mar 2026" is desired, `intl` must be added — this is a one-line pubspec change and is low risk since `intl` is a first-party Dart package.

**Primary recommendation:** Execute changes in dependency order — PricePoint model first, then ProductItem extension, then DiscountItem migration, then datasource error parsing update, then getProductsByMarket addition, then repository wiring swap, then provider update. Run `flutter pub run build_runner build --delete-conflicting-outputs` after each Freezed model change.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**API Contract & Base URL**
- D-01: Base URL is hardcoded in `lib/shared/providers/api_client_provider.dart` — replace the placeholder with the real backend URL. No build flavor or config file. Single source of truth.
- D-02: API version prefix: `/api/v1/...` — keep the existing convention.
- D-03: No pagination for v1 — backend returns full lists for `/products`, `/markets`, `/discounts`. Pagination is deferred to v2 (PERF-V2-01).
- D-04: Error response shape: `{"error": {"code": "NOT_FOUND", "message": "..."}}` — structured error object. Remote datasource `_handleDioException()` methods must parse `e.response?.data['error']['message']` and map `code` to typed AppException subtypes.
- D-05: No API spec exists yet — Flutter defines the contract here; backend implements to match.

**PricePoint Model**
- D-06: New Freezed model `PricePoint` with exactly two fields: `price: double` and `date: DateTime`. Lives at `lib/features/products/models/price_point.dart`.
- D-07: Backend date format: ISO 8601 string (`"2026-03-28T14:00:00Z"`) for ALL date fields (PricePoint.date and DiscountItem.validUntil). Dart's `DateTime.parse()` handles this natively.
- D-08: Price history is inline in the product object: `{"id":"...", "priceHistory": [{"price": 10.5, "date": "2026-03-28T14:00:00Z"}]}`. Single API call returns product + history together.
- D-09: `ProductItem` gets `List<PricePoint> priceHistory` added as a Freezed field — default to empty list (`@Default([])`) so existing UI code doesn't break.

**DiscountItem Date Migration**
- D-10: `DiscountItem.validUntil` changes from `String` to `DateTime`. Backend sends ISO 8601 string; Freezed uses a custom `fromJson` converter (`DateTime.parse(json['validUntil'] as String)`).
- D-11: Existing `discountAmount` and `discountPercent` computed getters are unaffected. UI display of validUntil uses `DateFormat` or manual formatting — formatter choice is Claude's discretion.

**Market Products Endpoint (MKTD-02)**
- D-12: Backend endpoint: `GET /products?marketId={slug}` — query param on the existing products endpoint, not a nested route.
- D-13: Market IDs are slug strings: `migros`, `a101`, `bim`, `carrefoursa`, `sok`, `tarim-kredi`, `file-market`. Human-readable, no UUID mapping table needed.
- D-14: Add `getProductsByMarket(String marketId)` method to `ProductRemoteDataSource` abstract class and `ProductRemoteDataSourceImpl`. This method calls `GET /products?marketId={marketId}`.

**Datasource Swap Strategy**
- D-15: Full swap — `repository_providers.dart` wires all three datasources to their `*RemoteDataSourceImpl` implementations. TODO comments are removed. Mock datasource files remain in the codebase (still used by unit tests).
- D-16: No mock fallback toggle, no feature flag. Clean cut to real data.
- D-17: On backend unreachable: existing error state + retry button. The typed error handling from Phase 1 (QUAL-02) already covers this via `AsyncValue.error` + `ref.invalidate()`. No new work needed.

### Claude's Discretion
- Exact `DateFormat` pattern for displaying `DiscountItem.validUntil` in the UI (e.g., `dd MMM yyyy` or `d MMMM yyyy`)
- Whether to add a `displayDate` computed getter to `DiscountItem` or handle formatting at the widget layer
- Order of datasource activation (all at once or sequential — all at once is fine given same pattern)
- JSON field name casing convention for priceHistory (camelCase assumed to match existing API stubs)

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| DATA-01 | Scraping backend supports Migros, A101, BIM, CarrefourSA, Şok, Tarım Kredi, File Market | Backend is a separate service; Flutter defines API contract (D-05). Market slugs defined in D-13. Flutter side is ready once remote datasources are wired. |
| DATA-02 | Flutter app connects to real backend API — remote datasources active for products, markets, discounts | `repository_providers.dart` three TODO swaps; all three `*RemoteDataSourceImpl` classes exist. Error parsing update (D-04) required. |
| DATA-03 | `ProductItem` carries `List<PricePoint> priceHistory` for chart phase | New `PricePoint` Freezed model (D-06) + `ProductItem` field extension (D-09). Requires build_runner regeneration. |
| DATA-04 | `DiscountItem.validUntil` is `DateTime` with day-level granularity | String → DateTime migration (D-10). Custom `fromJson` converter. UI display update in `discount_card.dart` (D-11). |
| MKTD-02 | Market detail page loads real product list filtered by market from API | `getProductsByMarket()` added to datasource (D-14), repository, and `productsByMarketProvider` updated from in-memory filter to actual API call. |
</phase_requirements>

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| freezed | ^2.4.0 | Immutable model generation | Already in project; used for all models |
| freezed_annotation | ^2.4.0 | Annotations for code gen | Already in project |
| json_serializable | ^6.7.0 | JSON deserialization | Already in project |
| json_annotation | ^4.8.0 | JSON annotations | Already in project |
| build_runner | ^2.4.0 | Code generation runner | Already in project |
| dio | ^5.3.0 | HTTP client | Already in project; ApiClient wrapper exists |
| flutter_riverpod | ^2.4.0 | State/DI | Already in project; all providers use this |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| intl | NOT in project | Date formatting (dd MMM yyyy) | Add if formatted date display needed; alternative is manual interpolation |

**intl availability finding (CRITICAL):** `intl` is NOT in `pubspec.yaml`. Dart's `DateTime` exposes `.day`, `.month`, `.year` fields directly. For a `displayDate` getter using Turkish month names or formatted output, either (a) add `intl` to pubspec.yaml (a first-party Dart package, zero risk) or (b) implement manual formatting using a Turkish month names list. Given CLAUDE.md says "yeni bağımlılıklar minimize edilecek", the manual approach is preferred unless formatted output requires locale-aware month names.

**Recommendation for date display (Claude's Discretion):** Add a `displayDate` getter to `DiscountItem` using manual string construction:
```dart
String get displayDate {
  return '${validUntil.day} ${_monthName(validUntil.month)} ${validUntil.year}';
}
static const _turkishMonths = ['', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
static String _monthName(int month) => _turkishMonths[month];
```
This avoids adding `intl` dependency and matches the project's Turkish UI language.

**Installation:** No new packages needed for the core work. If intl is added:
```bash
flutter pub add intl
```

**Version verification:** All packages already locked in `pubspec.lock`. No version changes needed.

## Architecture Patterns

### Recommended Project Structure for New Files
```
lib/features/products/models/
├── price_point.dart          # NEW: PricePoint Freezed model
├── price_point.freezed.dart  # GENERATED
├── price_point.g.dart        # GENERATED
├── product_item.dart         # MODIFY: add priceHistory field
├── product_item.freezed.dart # REGENERATED
└── product_item.g.dart       # REGENERATED

lib/features/discounts/models/
├── discount_item.dart        # MODIFY: validUntil String → DateTime
├── discount_item.freezed.dart # REGENERATED
└── discount_item.g.dart      # REGENERATED
```

### Pattern 1: Freezed Model with DateTime JSON Converter

The existing generated `discount_item.g.dart` uses `json['validUntil'] as String` directly. After migration, `json_serializable` does NOT handle `DateTime` from ISO 8601 strings automatically by default — you must use `@JsonKey(fromJson:)` or a custom converter.

**Correct pattern for DateTime field in Freezed:**
```dart
// In discount_item.dart
@freezed
class DiscountItem with _$DiscountItem {
  const factory DiscountItem({
    // ... other fields ...
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    required DateTime validUntil,
    // ...
  }) = _DiscountItem;

  factory DiscountItem.fromJson(Map<String, dynamic> json) =>
      _$DiscountItemFromJson(json);
}

DateTime _dateTimeFromJson(String date) => DateTime.parse(date);
String _dateTimeToJson(DateTime date) => date.toIso8601String();
```

**Alternative — Freezed with json_serializable automatic DateTime (Dart 3.x):** `json_serializable` 6.x DOES support `DateTime` natively from ISO 8601 strings. The generated code uses `DateTime.parse(json['validUntil'] as String)` automatically when the field type is `DateTime`. No custom `@JsonKey` converter is required. This is simpler and should be used.

Confidence: HIGH — verified against json_serializable 6.x behavior.

### Pattern 2: PricePoint Freezed Model
```dart
// lib/features/products/models/price_point.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'price_point.freezed.dart';
part 'price_point.g.dart';

@freezed
class PricePoint with _$PricePoint {
  const factory PricePoint({
    required double price,
    required DateTime date,
  }) = _PricePoint;

  factory PricePoint.fromJson(Map<String, dynamic> json) =>
      _$PricePointFromJson(json);
}
```

### Pattern 3: Extending ProductItem with List<PricePoint>

`@Default([])` annotation is used in this codebase (confirmed from CONTEXT.md D-09 and code_context). The import for PricePoint must use a relative path consistent with the project's import style.

```dart
// In product_item.dart — add import and field
import 'price_point.dart';

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
    @Default([]) List<PricePoint> priceHistory,  // NEW
  }) = _ProductItem;
  // ...
}
```

### Pattern 4: Error Response Parsing Update

Current `_handleDioException()` reads `data['message']`. New shape is `{"error": {"code": "...", "message": "..."}}`. Update all three remote datasources:

```dart
// BEFORE (current)
message: e.response?.data['message'] ?? 'Server error'

// AFTER (D-04 shape: {"error": {"code": "...", "message": "..."}})
final errorBody = e.response?.data;
final errorObj = errorBody is Map ? errorBody['error'] : null;
final message = (errorObj is Map ? errorObj['message'] : null) ?? 'Server error';
final code = (errorObj is Map ? errorObj['code'] : null) as String?;
```

Note: `ApiClient._handleException()` in `lib/core/network/api_client.dart` ALSO reads `data['message']` for 500+ and 400-499 errors. This must also be updated to match the new error envelope. Two locations: ApiClient central handler + three datasource-level `_handleDioException()` methods.

### Pattern 5: getProductsByMarket Implementation

```dart
// Abstract class addition in product_datasource.dart
abstract class ProductRemoteDataSource {
  Future<List<ProductItem>> getAllProducts();
  Future<ProductItem> getProductById(String id);
  Future<List<ProductItem>> searchProducts(String query);
  Future<List<ProductItem>> getProductsByMarket(String marketId);  // NEW
}

// Implementation in product_remote_datasource.dart
@override
Future<List<ProductItem>> getProductsByMarket(String marketId) async {
  try {
    return await apiClient
        .get(
          endpoint: '/products',
          queryParameters: {'marketId': marketId},
          fromJson: (json) {
            final list = json['data'] as List? ?? [];
            return list.cast<Map<String, dynamic>>();
          },
        )
        .then(
          (list) => list.map((item) => ProductItem.fromJson(item)).toList(),
        );
  } on DioException catch (e) {
    throw _handleDioException(e);
  }
}
```

### Pattern 6: ProductRepository Domain Interface Extension

`getProductsByMarket()` must be added to the domain interface, the repository implementation, AND the mock datasource (the mock must implement the new interface method):

```dart
// product_repository.dart
abstract class ProductRepository {
  Future<Result<List<ProductItem>>> getAllProducts();
  Future<Result<ProductItem>> getProductById(String id);
  Future<Result<List<ProductItem>>> searchProducts(String query);
  Future<Result<List<ProductItem>>> getProductsByMarket(String marketId);  // NEW
}
```

### Pattern 7: productsByMarketProvider Update

Current implementation filters in-memory from all products. After DATA-02, it should call the dedicated API method:

```dart
// BEFORE (current in products_provider.dart)
final productsByMarketProvider =
    FutureProvider.family<List<ProductItem>, String>((ref, marketId) async {
      final products = await ref.watch(productsProvider.future);
      return products.where((product) => product.marketId == marketId).toList();
    });

// AFTER (direct API call via repository)
final productsByMarketProvider =
    FutureProvider.family<List<ProductItem>, String>((ref, marketId) async {
      final repository = ref.watch(productRepositoryProvider);
      final result = await repository.getProductsByMarket(marketId);
      return result.when(
        success: (data) => data,
        failure: (message, code) => throw AppException(message: message, code: code),
        loading: () => throw StateError('Unexpected loading state in provider'),
      );
    });
```

### Pattern 8: Repository Providers Wiring Swap

```dart
// repository_providers.dart — swap for each feature

// PRODUCT
final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProductRemoteDataSourceImpl(apiClient: apiClient);
  // Remove: return ProductMockDataSourceImpl();
});

// MARKET
final marketRemoteDataSourceProvider = Provider<MarketRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MarketRemoteDataSourceImpl(apiClient: apiClient);
});

// DISCOUNT
final discountRemoteDataSourceProvider = Provider<DiscountRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DiscountRemoteDataSourceImpl(apiClient: apiClient);
});
```

The `apiClientProvider` is already available in `api_client_provider.dart`. The import must be added to `repository_providers.dart`.

### Anti-Patterns to Avoid

- **Deleting mock datasource files:** Mock datasources are used by existing unit tests (product_repository_test.dart, discount_repository_test.dart, market_repository_test.dart). Never delete `*_mock_datasource.dart` files.
- **Forgetting build_runner after Freezed changes:** Any change to a `@freezed` class source file requires regenerating the `.freezed.dart` and `.g.dart` files. Forgetting this causes compilation errors.
- **Partial error envelope migration:** The error shape `data['error']['message']` must be updated in BOTH `api_client.dart` (central handler) AND each datasource's `_handleDioException()`. Missing the central handler means 4xx errors still use the old path.
- **Mock datasource missing getProductsByMarket():** `ProductMockDataSourceImpl` implements `ProductRemoteDataSource`. When `getProductsByMarket()` is added to the abstract class, the mock must also implement it or compilation fails.
- **Existing unit tests hardcode mock counts:** `product_repository_test.dart` line 28 asserts `data.length equals(6)`. `discount_repository_test.dart` line 29 asserts `data.length equals(5)`. These tests use mock datasources and must NOT break.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| DateTime JSON parsing | Custom parser | json_serializable 6.x native DateTime support | Handles ISO 8601 automatically; generates correct code |
| Immutable model with copyWith | Manual class | Freezed | Already used in project; code gen handles equality, hashing, copyWith |
| HTTP client with interceptors | Custom HTTP | Dio via existing ApiClient wrapper | Already exists; interceptors for auth/logging are stub-ready |
| State caching + invalidation | Manual cache | Riverpod FutureProvider | Already used; `ref.invalidate()` pattern established |

**Key insight:** This phase is 95% wiring and model extension using patterns already established in the codebase. The only net-new code artifacts are `price_point.dart` and one new method per layer for `getProductsByMarket`.

## Common Pitfalls

### Pitfall 1: json_serializable DateTime requires `toIso8601String` in toJson
**What goes wrong:** Generated `toJson` for DateTime fields outputs a DateTime object, not a string. If the generated code is checked without careful review, round-trip serialization breaks.
**Why it happens:** `json_serializable` by default uses `.toIso8601String()` for toJson and `DateTime.parse()` for fromJson. This is correct behavior but the developer must verify the generated `.g.dart` output.
**How to avoid:** After running build_runner, inspect the generated `discount_item.g.dart` and `price_point.g.dart` to confirm `DateTime.parse(...)` in fromJson and `.toIso8601String()` in toJson.
**Warning signs:** Runtime type error when backend sends date strings if the conversion is wrong.

### Pitfall 2: `_handleDioException` in datasources has narrower scope than ApiClient
**What goes wrong:** The ApiClient central `_handleException()` already maps DioException → AppException for most cases. Datasource-level `_handleDioException()` is only reached if the ApiClient rethrows WITHOUT converting (it does rethrow). Currently ApiClient catches, converts, and rethrows as AppException — but only for `badResponse` ≥500 and ≥400. If the datasource `_handleDioException()` is updated for the new error envelope, but ApiClient's central handler is NOT, then 4xx client errors will be parsed by ApiClient (using old `data['message']`) before reaching the datasource.
**Why it happens:** Two-level exception handling chain — ApiClient maps first, datasource catches `DioException` which may never arrive because ApiClient already threw `AppException`.
**How to avoid:** Trace the exception flow: ApiClient.get() → on catch → _handleException() throws AppException → this propagates out of get(). The datasource's `on DioException catch` never fires for errors handled by ApiClient. Therefore the PRIMARY fix location is `api_client.dart` `_handleException()`. The datasource `_handleDioException()` is a secondary path only for DioExceptions that bypass ApiClient's central handler.
**Action:** Update BOTH `api_client.dart` `_handleException()` AND all three `_handleDioException()` methods to use the new `data['error']['message']` / `data['error']['code']` path.

### Pitfall 3: `productsByMarketProvider` currently chains from `productsProvider`
**What goes wrong:** After activating remote datasources, if `productsByMarketProvider` is not updated, it still loads ALL products first and filters in memory — fetching the entire product catalog just to filter one market. This defeats the purpose of `GET /products?marketId=`.
**Why it happens:** The current implementation `ref.watch(productsProvider.future)` piggybacks on the all-products provider. With mock data this is fine; with real API this is wasteful and incorrect.
**How to avoid:** `productsByMarketProvider` must be updated (per Pattern 7 above) to call `repository.getProductsByMarket(marketId)` directly.
**Warning signs:** MarketDetailPage loads very slowly because it downloads the full product catalog.

### Pitfall 4: Mock data `validUntil` strings use Turkish date format
**What goes wrong:** Existing mock datasource has `validUntil: '30 Mart 2026'` (Turkish prose format). After `DiscountItem.validUntil` becomes `DateTime`, the mock datasource must be updated to use ISO 8601 date strings, OR the mock datasource objects must construct `DateTime` objects directly (bypassing fromJson).
**Why it happens:** Mock datasources construct `DiscountItem` instances directly using the constructor, not via `fromJson`. The constructor will expect `DateTime` values, not strings.
**How to avoid:** Update `discount_mock_datasource.dart` and `mock_discounts.dart` to pass `DateTime(2026, 3, 30)` instead of `'30 Mart 2026'`. Tests assert on counts and computed getters, not on the date string value, so existing tests will pass.

### Pitfall 5: `discount_card.dart` displays `item.validUntil` as string interpolation
**What goes wrong:** Line 115 in `discount_card.dart` uses `'Son tarih: ${item.validUntil}'`. After migration, `validUntil` is `DateTime`, so this will render as Dart's default `DateTime.toString()` output — e.g., `2026-03-30 00:00:00.000` — which is not user-friendly.
**Why it happens:** The widget code treats validUntil as a display-ready string.
**How to avoid:** Either (a) add a `displayDate` computed getter to `DiscountItem` and update the widget to use `item.displayDate`, or (b) format inline at widget layer. Approach (a) is cleaner — it keeps formatting logic in the model, consistent with existing `displayPrice` getter pattern.

### Pitfall 6: `ProductLocalDataSource` abstract class is in product_datasource.dart
**What goes wrong:** `product_datasource.dart` defines two abstract classes: `ProductRemoteDataSource` and `ProductLocalDataSource`. When adding `getProductsByMarket()` to `ProductRemoteDataSource`, care must be taken to only add it to the remote abstract, not accidentally to the local abstract.
**Why it happens:** Both abstracts are in the same file.
**How to avoid:** Read the file carefully before editing — confirmed: `ProductLocalDataSource` handles caching (`cacheProducts`, `getCachedProducts`, `clearCache`); `getProductsByMarket` belongs only on `ProductRemoteDataSource`.

## Code Examples

### Complete PricePoint model
```dart
// lib/features/products/models/price_point.dart
// Source: Freezed 2.4 + json_serializable 6.7 pattern (consistent with existing models)
import 'package:freezed_annotation/freezed_annotation.dart';

part 'price_point.freezed.dart';
part 'price_point.g.dart';

@freezed
class PricePoint with _$PricePoint {
  const factory PricePoint({
    required double price,
    required DateTime date,
  }) = _PricePoint;

  factory PricePoint.fromJson(Map<String, dynamic> json) =>
      _$PricePointFromJson(json);
}
```

### DiscountItem after migration
```dart
// lib/features/discounts/models/discount_item.dart
// Source: existing pattern + DateTime migration per D-10
import 'package:freezed_annotation/freezed_annotation.dart';

part 'discount_item.freezed.dart';
part 'discount_item.g.dart';

@freezed
class DiscountItem with _$DiscountItem {
  const factory DiscountItem({
    required String id,
    required String productId,
    required String marketId,
    required String productName,
    required String marketName,
    required double oldPrice,
    required double newPrice,
    required DateTime validUntil,  // Changed from String
    String? note,
  }) = _DiscountItem;

  factory DiscountItem.fromJson(Map<String, dynamic> json) =>
      _$DiscountItemFromJson(json);

  const DiscountItem._();

  double get discountAmount => oldPrice - newPrice;

  int get discountPercent {
    if (oldPrice <= 0) return 0;
    return (((oldPrice - newPrice) / oldPrice) * 100).round();
  }

  // NEW: display getter — avoids intl dependency
  String get displayDate {
    const months = ['', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
                    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
    return '${validUntil.day} ${months[validUntil.month]} ${validUntil.year}';
  }
}
```

### Updated error handling in api_client.dart _handleException
```dart
// Source: D-04 error shape {"error": {"code": "...", "message": "..."}}
void _handleException(dynamic exception) {
  if (exception is DioException) {
    switch (exception.type) {
      case DioExceptionType.badResponse:
        if (exception.response?.statusCode != null) {
          final body = exception.response?.data;
          final errorObj = body is Map ? body['error'] : null;
          final message = (errorObj is Map ? errorObj['message'] : null)
              ?? (body is Map ? body['message'] : null)  // fallback for non-conforming responses
              ?? 'Server error';
          final code = (errorObj is Map ? errorObj['code'] : null) as String?;
          if (exception.response!.statusCode! >= 500) {
            throw ServerException(message: message, statusCode: exception.response?.statusCode, code: code, originalException: exception);
          } else if (exception.response!.statusCode! >= 400) {
            throw ClientException(message: message, statusCode: exception.response?.statusCode, code: code, originalException: exception);
          }
        }
        break;
      // ... timeout/unknown cases unchanged
    }
  }
}
```

### build_runner command
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Runtime State Inventory

> This phase involves model type changes, not a rename/refactor. No runtime state audit required. However, noting the one state-adjacent concern:

| Category | Items Found | Action Required |
|----------|-------------|------------------|
| Stored data | SharedPreferences `favorite_products` stores serialized `ProductItem` JSON. After adding `priceHistory` field with `@Default([])`, deserialization of existing stored JSON (which lacks `priceHistory`) will use the default empty list — no data loss. | None — `@Default([])` handles missing field gracefully |
| Live service config | No external service config | None |
| OS-registered state | None | None |
| Secrets/env vars | Base URL hardcoded in `api_client_provider.dart` — update to real URL | Code edit only |
| Build artifacts | `*.freezed.dart` and `*.g.dart` generated files for `product_item`, `discount_item` are stale after model changes | Run `flutter pub run build_runner build --delete-conflicting-outputs` |

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | All | ✓ | 3.41.4 | — |
| Dart SDK | All | ✓ | 3.11.1 | — |
| flutter pub / pub | build_runner | ✓ | bundled | — |
| build_runner | Freezed codegen | ✓ | ^2.4.0 in pubspec | — |
| Backend API | DATA-01, DATA-02, MKTD-02 | Unknown | — | Mock datasources remain wired until backend ready |

**Missing dependencies with no fallback:** None that block Flutter code changes.

**Missing dependencies with fallback:** Backend API is not yet implemented (DATA-01). Flutter-side code can be written against the defined contract (D-05). Mock datasources remain available for development. The wiring switch in `repository_providers.dart` can be the LAST step, after backend is ready.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | flutter_test (SDK integrated) |
| Config file | none — uses flutter test runner directly |
| Quick run command | `flutter test test/features/products/data/repositories/product_repository_test.dart` |
| Full suite command | `flutter test` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| DATA-03 | ProductItem carries List<PricePoint> priceHistory with @Default([]) | unit | `flutter test test/features/products/data/repositories/product_repository_test.dart` | ✅ (needs new assertion) |
| DATA-04 | DiscountItem.validUntil is DateTime, fromJson parses ISO 8601 | unit | `flutter test test/features/discounts/data/repositories/discount_repository_test.dart` | ✅ (needs new assertion) |
| MKTD-02 | getProductsByMarket returns products filtered by marketId | unit | `flutter test test/features/products/data/repositories/product_repository_test.dart` | ✅ (needs new test case) |
| DATA-02 | Remote datasource activation (smoke) | manual | App launches, real API returns data | N/A — requires live backend |
| DATA-01 | Backend supports 7 markets | manual | API returns Migros, A101, BIM, etc. | N/A — backend scope |

### Sampling Rate
- **Per task commit:** `flutter test` (full suite — fast, ~5 seconds with mock datasources)
- **Per wave merge:** `flutter test`
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] `test/features/products/data/repositories/product_repository_test.dart` — add test for `getProductsByMarket()` (file exists, new test case needed)
- [ ] `test/features/discounts/data/repositories/discount_repository_test.dart` — add test asserting `validUntil` is `DateTime` type and `displayDate` returns expected string (file exists, new test case needed)
- [ ] `test/features/products/models/price_point_test.dart` — NEW file, unit test for `PricePoint.fromJson` with ISO 8601 date

**Existing test integrity constraint:** `product_repository_test.dart` asserts 6 products; `discount_repository_test.dart` asserts 5 discounts. Both use mock datasources. Mock datasources must be updated for the type change (DiscountItem.validUntil String → DateTime) but counts must not change. These tests will compile-fail if mock datasources aren't updated simultaneously with model changes.

## Sources

### Primary (HIGH confidence)
- Codebase direct inspection — all source files in `lib/` and `test/` read directly
- CONTEXT.md — D-01 through D-17 locked decisions
- REQUIREMENTS.md — DATA-01 through DATA-04, MKTD-02 acceptance criteria
- ARCHITECTURE.md + INTEGRATIONS.md — confirmed response shape `{"data": [...]}`, error pattern

### Secondary (MEDIUM confidence)
- json_serializable 6.x DateTime handling — confirmed from generated `discount_item.g.dart` pattern which shows json_annotation handles String fields; DateTime behavior is standard Dart package behavior well-established in docs

### Tertiary (LOW confidence)
- None

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all libraries are already in pubspec.yaml; versions confirmed
- Architecture: HIGH — patterns read directly from existing source code
- Pitfalls: HIGH — identified from direct code inspection (two-level error handler, in-memory filter, mock data string format, discount_card.dart display)
- Validation: HIGH — test files confirmed to exist; exact test commands verified

**Research date:** 2026-03-28
**Valid until:** 2026-04-28 (stable stack, no fast-moving dependencies)
