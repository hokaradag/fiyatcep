# Coding Conventions

**Analysis Date:** 2026-03-27

## Naming Patterns

**Files:**
- Dart files use snake_case: `discount_item.dart`, `discount_card.dart`, `api_client.dart`
- Page files: `*_page.dart` (e.g., `discounts_page.dart`, `home_page.dart`)
- Widget files: suffix with component type (e.g., `discount_card.dart`, `market_card.dart`)
- Repository implementations: `*_repository_impl.dart` (e.g., `discount_repository_impl.dart`)
- Data source implementations: `*_datasource.dart` and `*_remote_datasource.dart` / `*_mock_datasource.dart`
- Provider files: `*_provider.dart` (e.g., `discounts_provider.dart`)
- Model files: `*_item.dart` (e.g., `discount_item.dart`, `product_item.dart`)

**Functions:**
- camelCase for all function/method names: `getAllDiscounts()`, `getDiscountsByMarket()`, `isFavorite()`
- Private methods prefixed with underscore: `_handleException()`, `_normalizeText()`, `_formatPrice()`, `_onRequest()`
- Accessor methods use plain names: `get()`, `post()`, `put()`, `delete()` for HTTP verbs
- Computed getters for derived values: `discountAmount`, `discountPercent`, `displayPrice`

**Variables:**
- camelCase for local and member variables: `baseUrl`, `remoteDataSource`, `discounts`, `favoritesNotifier`
- Constants use SCREAMING_SNAKE_CASE with `const`: `const String _favoritesKey = 'favorite_products'`
- Private members prefixed with underscore: `_dio`, `_prefs`, `_isInitialized`
- Null-safety used throughout: `String?`, `List<DiscountItem>?`

**Types:**
- Class names use PascalCase: `DiscountItem`, `ApiClient`, `AppException`, `FavoritesStore`
- Exception classes suffixed with `Exception`: `AppException`, `NetworkException`, `ServerException`, `ClientException`, `ParseException`, `CacheException`
- Repository/DataSource abstract classes: `DiscountRepository`, `DiscountRemoteDataSource`
- Implementation classes suffixed with `Impl`: `DiscountRepositoryImpl`, `DiscountRemoteDataSourceImpl`, `DiscountMockDataSourceImpl`
- Widget classes inherit from `StatelessWidget` or `StatefulWidget` appropriately

## Code Style

**Formatting:**
- No explicit formatter configured; follows Dart conventions
- Uses proper indentation and spacing throughout
- Line comments use `///` for public documentation
- Inline comments use `//` (e.g., "/// Üst satır: ürün adı + indirim yüzdesi")
- Turkish language used in some UI-related comments and strings

**Linting:**
- `flutter_lints` package enabled via `analysis_options.yaml`
- Includes `package:flutter_lints/flutter.yaml` for recommended lints
- Rules are customizable but not overridden beyond Flutter defaults
- Can suppress lints with `// ignore: lint_name` or `// ignore_for_file: lint_name`

## Import Organization

**Order:**
1. `dart:` imports (standard library): `dart:async`, `dart:convert`
2. `package:flutter` and `package:flutter_test` (Flutter framework)
3. Third-party packages: `package:dio`, `package:freezed_annotation`, `package:json_annotation`
4. Project imports: relative paths starting with `../` or package references

**Path Aliases:**
- No path aliases configured
- Uses relative imports with `../` to navigate hierarchy
- Project packages referenced as `package:fiyatcep/`

## Error Handling

**Patterns:**
- Custom exception hierarchy with base `AppException` class containing `message`, `code`, and `originalException`
- Specific exception types for different scenarios: `NetworkException`, `ServerException` (5xx), `ClientException` (4xx), `ParseException`, `CacheException`
- Try-catch blocks in repository/datasource implementations
- Dio exceptions converted to custom exceptions in `_handleException()` methods
- Repositories return `Result<T>` sealed type with success/failure/loading states
- Providers throw `Exception()` when repository returns failure

## Logging

**Framework:** No dedicated logging library used

**Patterns:**
- Debugging via standard `print()` is avoided (linted)
- Logging through Flutter's debug output via `debugPrint()` or Dart's `log()` when needed
- Error tracking through exception classes that capture original exceptions
- No structured logging system implemented

## Comments

**When to Comment:**
- Used for clarifying UI layout sections (e.g., "/// Üst satır: ürün adı + indirim yüzdesi" in `discount_card.dart`)
- Used to mark TODO items for future work: "// TODO: Change to actual API base URL when available"
- Used sparingly; code is expected to be self-documenting

**JSDoc/TSDoc:**
- Uses `///` for public API documentation
- Method documentation includes `@override` annotations where applicable
- Minimal documentation on private methods

## Function Design

**Size:** Generally compact, 10-50 lines for most functions
- Simple accessor methods (5-10 lines)
- Complex business logic (20-50 lines) with clear structure
- Repository methods follow consistent patterns using try-catch

**Parameters:**
- Named parameters preferred for clarity: `{required String endpoint, Map<String, dynamic>? queryParameters}`
- Required parameters marked with `required` keyword
- Optional parameters marked with `?` or given defaults

**Return Values:**
- Generic types used for flexibility: `Future<T>`, `Future<List<DiscountItem>>`
- Sealed `Result<T>` type wraps success/failure/loading states
- Null-safe returns: return type explicitly marks nullability

## Module Design

**Exports:**
- Abstract interfaces (repositories, datasources) defined separately for dependency inversion
- Implementations are private to their modules
- Providers inject dependencies via constructor injection

**Barrel Files:**
- Not extensively used
- Main feature structure exposes page and domain interfaces
- Each feature is relatively self-contained with clear boundaries

## Feature Structure Pattern

**Domain Layer:**
- `domain/repositories/` - Abstract repository interfaces
- Pure Dart, no Flutter dependencies

**Data Layer:**
- `data/datasources/` - Abstract and implementation classes (remote, mock)
- `data/repositories/` - Repository implementations using datasources
- `data/` - Mock data files for development

**Presentation Layer:**
- `models/` - Freezed immutable data models with code generation
- `presentation/providers/` - Riverpod providers
- `widgets/` - Reusable widget components
- `*_page.dart` - Full page widgets

**Dependencies:**
- Presentation depends on Domain and Data
- Data implements Domain interfaces
- Core utilities in `lib/core/` (network, errors)
- Shared utilities in `lib/shared/` (providers)
