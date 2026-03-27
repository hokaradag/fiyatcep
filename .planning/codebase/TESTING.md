# Testing

## Framework

- **flutter_test** (Flutter SDK built-in) — widget and unit testing
- **No dedicated mock library** — project uses datasource-swapping pattern instead
- No integration test setup (`integration_test/` absent)

## Test Structure

```
test/
└── widget_test.dart   # Default Flutter placeholder only (minimal coverage)
```

## Mock Strategy

Mock data is implemented at the **datasource layer**, not at the test layer:

- Each feature has a `*_mock_datasource.dart` implementing the same interface as the remote datasource
- Repositories are wired to mock datasources via `repository_providers.dart`
- Switch to remote: change provider wiring in `lib/shared/providers/repository_providers.dart`

```dart
// lib/shared/providers/repository_providers.dart
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(
    remoteDataSource: ProductMockDataSourceImpl(), // TODO: swap to remote
  );
});
```

## Mock Data Locations

| Feature    | Mock datasource                                                              | Static data                                     |
|------------|------------------------------------------------------------------------------|-------------------------------------------------|
| Products   | `lib/features/products/data/datasources/product_mock_datasource.dart`       | `lib/features/products/data/mock_products.dart` |
| Markets    | `lib/features/markets/data/datasources/market_mock_datasource.dart`         | `lib/features/markets/data/mock_markets.dart`   |
| Discounts  | `lib/features/discounts/data/datasources/discount_mock_datasource.dart`     | (inline in datasource)                          |
| Favorites  | N/A — uses `FavoritesStore` with `SharedPreferences`                        | N/A                                             |

## Simulated Delays

All mock datasources simulate network latency with `Future.delayed`:
- `getAllProducts()` / `getAllDiscounts()` / `getAllMarkets()` → 800ms
- `getById()` → 500ms
- `search*()` → 600ms

## Coverage

| Area                  | Status       |
|-----------------------|--------------|
| Unit tests            | None         |
| Widget tests          | Placeholder  |
| Integration tests     | None         |
| Mock datasources      | Complete     |
| Repository tests      | None         |

## Gaps

- No automated tests for any feature
- No CI test pipeline configured
- FavoritesStore SharedPreferences not mocked for tests
- `flutter_test` and `flutter_lints` in devDependencies but unused
