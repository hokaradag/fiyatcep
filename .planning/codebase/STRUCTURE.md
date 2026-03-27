# Structure

## Root Layout

```
c:\dev\fiyatcep\
├── lib/                        # Dart source code
│   ├── main.dart               # App entry point
│   ├── app.dart                # MaterialApp + theme config
│   ├── core/                   # Shared infrastructure
│   ├── shared/                 # Cross-feature providers & navigation
│   └── features/               # Feature modules
├── test/
│   └── widget_test.dart        # Placeholder only
├── android/                    # Android native project
├── ios/                        # iOS native project
├── pubspec.yaml                # Dependencies
├── analysis_options.yaml       # Linter config (flutter_lints)
└── .planning/                  # GSD planning artifacts
```

## lib/ Layout

```
lib/
├── main.dart                   # ProviderScope + FavoritesStore.init()
├── app.dart                    # MaterialApp, green seed color, Material3
├── core/
│   ├── errors/
│   │   ├── exceptions.dart     # AppException hierarchy
│   │   └── result.dart         # Sealed Result<T> (success/failure/loading)
│   └── network/
│       └── api_client.dart     # Dio HTTP client (unused in active code)
├── shared/
│   ├── main_navigation.dart    # BottomNavigationBar, 5 tabs
│   └── providers/
│       ├── api_client_provider.dart        # Provider<ApiClient>
│       └── repository_providers.dart       # Wires repos to mock datasources
└── features/
    ├── home/
    │   └── home_page.dart
    ├── products/
    │   ├── models/
    │   │   ├── product_item.dart + .freezed.dart + .g.dart
    │   │   └── market_price_item.dart + .freezed.dart + .g.dart
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   ├── product_datasource.dart         # Abstract interfaces
    │   │   │   ├── product_mock_datasource.dart     # Active implementation
    │   │   │   └── product_remote_datasource.dart   # Dio impl (wired off)
    │   │   ├── repositories/
    │   │   │   └── product_repository_impl.dart
    │   │   ├── mock_products.dart                  # Static product list
    │   │   └── mock_market_prices.dart             # Static price map
    │   ├── domain/
    │   │   └── repositories/
    │   │       └── product_repository.dart         # Abstract interface
    │   └── presentation/
    │       ├── pages/
    │       │   ├── products_page.dart
    │       │   └── product_detail_page.dart
    │       └── providers/
    │           └── products_provider.dart
    ├── markets/
    │   ├── models/
    │   │   └── market_item.dart + .freezed.dart + .g.dart
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   ├── market_datasource.dart
    │   │   │   ├── market_mock_datasource.dart
    │   │   │   └── market_remote_datasource.dart
    │   │   ├── repositories/
    │   │   │   └── market_repository_impl.dart
    │   │   └── mock_markets.dart
    │   ├── domain/
    │   │   └── repositories/
    │   │       └── market_repository.dart
    │   └── presentation/
    │       ├── pages/
    │       │   ├── markets_page.dart
    │       │   └── market_detail_page.dart
    │       ├── providers/
    │       │   └── markets_provider.dart
    │       └── widgets/
    │           └── market_card.dart
    ├── discounts/
    │   ├── models/
    │   │   └── discount_item.dart + .freezed.dart + .g.dart
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   ├── discount_datasource.dart
    │   │   │   ├── discount_mock_datasource.dart
    │   │   │   └── discount_remote_datasource.dart
    │   │   └── repositories/
    │   │       └── discount_repository_impl.dart
    │   ├── domain/
    │   │   └── repositories/
    │   │       └── discount_repository.dart
    │   └── presentation/
    │       ├── pages/
    │       │   └── discounts_page.dart
    │       ├── providers/
    │       │   └── discounts_provider.dart
    │       └── widgets/
    │           └── discount_card.dart
    └── favorites/
        ├── data/
        │   └── favorites_store.dart    # ValueNotifier + SharedPreferences
        └── presentation/
            └── pages/
                └── favorites_page.dart
```

## Naming Conventions

| Element              | Convention         | Example                             |
|----------------------|--------------------|-------------------------------------|
| Files                | snake_case         | `product_mock_datasource.dart`      |
| Classes              | PascalCase         | `ProductMockDataSourceImpl`         |
| Variables/functions  | camelCase          | `getAllProducts()`                  |
| Constants            | camelCase          | `mockMarketPrices`                  |
| Providers            | camelCase + suffix | `productsProvider`, `marketsProvider` |
| Feature dirs         | snake_case         | `features/products/`                |
| Generated files      | `*.freezed.dart`, `*.g.dart` — never edit manually |

## Key File Locations

| Purpose                        | Path                                              |
|--------------------------------|---------------------------------------------------|
| App entry point                | `lib/main.dart`                                   |
| Theme & routing                | `lib/app.dart`                                    |
| Bottom navigation              | `lib/shared/main_navigation.dart`                 |
| Dependency wiring              | `lib/shared/providers/repository_providers.dart`  |
| HTTP client                    | `lib/core/network/api_client.dart`                |
| Error types                    | `lib/core/errors/exceptions.dart`                 |
| Result type                    | `lib/core/errors/result.dart`                     |
| Favorites persistence          | `lib/features/favorites/data/favorites_store.dart` |
| Mock product data              | `lib/features/products/data/mock_products.dart`   |
| Mock price data                | `lib/features/products/data/mock_market_prices.dart` |

## Code Generation

Generated files (`*.freezed.dart`, `*.g.dart`) should not be edited. Regenerate with:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Affected models: `ProductItem`, `MarketPriceItem`, `MarketItem`, `DiscountItem`
