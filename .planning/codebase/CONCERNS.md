# Concerns

## Critical Tech Debt

### 1. All Data is Hardcoded Mock Data
**Files:** `lib/shared/providers/repository_providers.dart`, all `*_mock_datasource.dart`
- Every repository uses `*MockDataSourceImpl` — no real API calls anywhere
- API base URL is `https://api.example.com/api/v1` (placeholder)
- Remote datasources exist (`*_remote_datasource.dart`) but are never wired up
- **Impact:** App cannot work in production

### 2. No Real Backend Integration
**Files:** `lib/core/network/api_client.dart`
- `ApiClient` (Dio) is instantiated but never used by any active code path
- Authentication headers, token refresh — none implemented
- **Impact:** All 3 remote datasources are dead code

### 3. FavoritesStore Not Integrated with Riverpod
**Files:** `lib/features/favorites/data/favorites_store.dart`, `lib/main.dart`
- Uses `ValueNotifier` + `SharedPreferences` independently of Riverpod
- Initialized manually in `main.dart` as a global singleton
- Inconsistent with rest of app's state management pattern
- **Impact:** Harder to test, inconsistent architecture

## Error Handling Issues

### 4. Providers Throw Raw Exceptions
**Files:** `lib/features/*/presentation/providers/*_provider.dart`
```dart
failure: (message, code) => throw Exception(message),  // loses error type
loading: () => throw Exception('Loading'),              // nonsensical
```
- `Result` sealed class exists but failure/loading cases just rethrow generic exceptions
- UI gets an opaque `Exception` string instead of typed errors
- **Impact:** No meaningful error messages shown to users

### 5. `orElse` Throws Generic Exception
**File:** `lib/features/products/data/datasources/product_mock_datasource.dart:75`
```dart
orElse: () => throw Exception('Ürün bulunamadı'),
```
- Should throw `NotFoundException` from `exceptions.dart`

## Design Problems

### 6. Large Build Methods
**Files:** `home_page.dart` (432 lines), `product_detail_page.dart` (270 lines), `market_detail_page.dart` (416 lines)
- Single `build()` method handles all UI construction and data fetching logic
- Hard to maintain, test, or extend
- **Impact:** Low maintainability

### 7. Turkish Text Normalization Duplicated Everywhere
**Files:** All `*_mock_datasource.dart` files + products/discounts/markets pages
```dart
String _normalizeText(String text) { ... }  // copied 6+ times
```
- No shared utility — pure copy-paste
- **Impact:** Bug fixes must be applied in multiple places

### 8. Deep Widget Nesting in Pages
**Files:** `home_page.dart`, `market_detail_page.dart`
- 10+ levels of nesting in some build methods
- Makes widget tree hard to follow and refactor

## Security Concerns

### 9. No Input Validation
- Search queries passed directly to datasources without sanitization
- No length limits or character filtering

### 10. No Authentication System
- No login/logout flow
- No token storage or management
- Market loyalty program / user-specific data (Migros Money) referenced in UI but not implemented

### 11. No HTTPS Certificate Pinning
**File:** `lib/core/network/api_client.dart`
- Dio client has no certificate pinning or SSL verification customization
- Acceptable for development, risky for production

## Performance Issues

### 12. No Pagination
- `getAllProducts()` / `getAllDiscounts()` / `getAllMarkets()` return full lists
- Will not scale when real API returns large datasets

### 13. No Caching Layer
**File:** `lib/features/products/data/repositories/product_repository_impl.dart`
- `localDataSource` parameter exists but is never instantiated (always `null`)
- Every navigation triggers a fresh "network" call (simulated delay)

### 14. Inefficient Search
- Client-side filtering across all items on every keystroke
- No debouncing on search input in UI layers

## Missing Features

### 15. No Offline Support
- No local database (Hive, SQLite, etc.)
- App entirely non-functional without network

### 16. No Price History / Trend Data
- `ProductItem` has no price history field
- `DiscountItem.validUntil` is a plain String, not a `DateTime`
- Cannot show price trends or expiry countdowns properly

### 17. Carrefoursa Naming Inconsistency
**Files:** Various mock data files
- Used as both `"Carrefoursa"` and `"CarrefourSA"` across datasources
- Can cause market filter mismatches

## Low Priority

### 18. No Localization (l10n)
- All strings hard-coded in Turkish
- No `AppLocalizations` setup

### 19. Hardcoded Mock Delays
- `Future.delayed` values (600-800ms) not configurable
- Makes tests unnecessarily slow

### 20. Analysis Warnings Suppressed
**Files:** Some pages use `// ignore_for_file: deprecated_member_use`
- Blanket suppression hides real issues
