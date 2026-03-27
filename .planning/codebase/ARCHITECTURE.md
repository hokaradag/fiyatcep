# Architecture

**Analysis Date:** 2026-03-27

## Pattern Overview

**Overall:** Clean Architecture with Repository Pattern + Riverpod State Management

**Key Characteristics:**
- Feature-based modular architecture with clear separation of concerns
- Domain-Driven Design principles with explicit repository abstractions
- State management via Riverpod (functional reactive state)
- Sealed Result type for async operation handling (Success/Failure/Loading)
- Mock data layer with swap-ready remote datasources for future API integration

## Layers

**Presentation Layer:**
- Purpose: UI components, pages, and consumer state management
- Location: `lib/features/*/presentation/` and `lib/features/*/*_page.dart`
- Contains: ConsumerStatefulWidget pages, local UI state, Riverpod provider watches
- Depends on: Presentation providers, domain models
- Used by: Bottom navigation, route navigation

**Riverpod Provider Layer:**
- Purpose: Centralized state management and side effects orchestration
- Location: `lib/features/*/presentation/providers/*.dart`, `lib/shared/providers/*.dart`
- Contains: FutureProvider, FutureProvider.family for async data, Provider for singleton instances
- Depends on: Repositories, datasources
- Used by: Presentation layer widgets via `ref.watch()` and `ref.invalidate()`

**Domain Layer:**
- Purpose: Business logic contracts and data models
- Location: `lib/features/*/domain/repositories/*.dart`, `lib/features/*/models/*.dart`
- Contains: Abstract repository interfaces, domain-level Result<T> type wrapping, Freezed immutable models
- Depends on: Nothing (pure Dart)
- Used by: Repositories (implement), providers (depend on), presentation (models)

**Data Layer:**
- Purpose: Data access and repository implementation
- Location: `lib/features/*/data/`
- Contains: Repository implementations, datasources (remote/mock/local), local cache logic
- Depends on: Domain repositories, API client, local storage
- Used by: Providers (instantiation)

**Core Layer:**
- Purpose: Shared infrastructure and cross-cutting concerns
- Location: `lib/core/`
- Contains: Network client (Dio-based), exception hierarchy, Result type, logging utilities
- Depends on: Nothing (foundational)
- Used by: Data layer (API calls), repositories (error handling)

## Data Flow

**Async Data Load (e.g., getAllProducts):**

1. UI component (ConsumerStatefulWidget) calls `ref.watch(productsProvider)`
2. productsProvider (FutureProvider) triggers repository.getAllProducts()
3. Repository delegates to remoteDataSource.getAllProducts()
4. DataSource (currently mock) returns List<ProductItem>
5. Repository catches AppException and wraps as FailureResult/SuccessResult
6. Provider unwraps with .when() and returns data or throws Exception
7. UI displays AsyncValue states: loading → data → error

**State Invalidation:**
- `ref.invalidate(productsProvider)` clears provider cache
- Next ref.watch triggers fresh async computation
- Manual refresh button example in ProductsPage line 147

**State Management:**
- Riverpod manages state caching and dependency tracking
- Local UI state (like searchText) managed via ConsumerStatefulWidget.setState()
- Persistent local state (favorites) via FavoritesStore + SharedPreferences ValueNotifier pattern
- No global Redux/Bloc, direct provider-to-widget bindings

## Key Abstractions

**Result<T> Type:**
- Purpose: Represent async operation outcomes uniformly
- Examples: `lib/core/errors/result.dart` (Success/Failure/Loading sealed classes)
- Pattern: Discriminated union with pattern matching via `.when()` method
- Used in: All repository methods return `Future<Result<T>>`

**Datasource Pattern:**
- Purpose: Abstract data acquisition source (API vs mock vs local cache)
- Examples: `lib/features/products/data/datasources/product_datasource.dart` (abstract), `product_mock_datasource.dart`, `product_remote_datasource.dart`
- Pattern: Abstract base class + concrete implementations
- Current: Mock datasources in use, remote datasources are stubs awaiting real API

**Repository Pattern:**
- Purpose: Bridge domain/presentation from data details
- Examples: `lib/features/products/data/repositories/product_repository_impl.dart` implements `lib/features/products/domain/repositories/product_repository.dart`
- Pattern: Domain interface, implementation handles datasource selection, error wrapping, caching
- Benefit: Testable, swappable datasources (mock → remote)

**Feature Isolation:**
- Purpose: Each feature (products, markets, discounts) is self-contained
- Location: `lib/features/{featureName}/` with parallel data/domain/presentation structure
- Cross-cutting: Shared only in `lib/shared/` (navigation, provider setup) and `lib/core/` (infrastructure)

## Entry Points

**Application Root:**
- Location: `lib/main.dart`
- Triggers: Initializes SharedPreferences via FavoritesStore.init(), wraps app in ProviderScope
- Responsibilities: Bootstrap phase, state initialization, Riverpod setup

**Navigation Root:**
- Location: `lib/shared/main_navigation.dart` (referenced in app.dart as home)
- Triggers: Called by FiyatCepApp MaterialApp
- Responsibilities: Bottom tab navigation, page switching via NavigationBar (5 tabs: Home, Products, Markets, Discounts, Favorites)

**Feature Pages:**
- Location: `lib/features/{featureName}/{featureName}_page.dart`
- Triggers: Navigated to via MainNavigation or internal navigation (detail pages)
- Responsibilities: Render feature-specific UI, watch providers, handle user interaction

## Error Handling

**Strategy:** Explicit exception hierarchy + Result type wrapping

**Patterns:**

1. **Network Errors** (ApiClient layer):
   - DioException types caught in `lib/core/network/api_client.dart` lines 121-158
   - Mapped to NetworkException (timeout), ServerException (5xx), ClientException (4xx)
   - Example: `DioExceptionType.connectionTimeout` → NetworkException thrown

2. **Repository Errors** (Data layer):
   - Repository catch AppException and wrap as FailureResult (see `lib/features/products/data/repositories/product_repository_impl.dart` lines 22-26)
   - Unknown errors wrapped as generic FailureResult with "Unknown error occurred"

3. **Provider Errors** (Presentation layer):
   - FutureProvider throws Exception when .when() success/failure/loading called (providers/products_provider.dart lines 13-14)
   - AsyncValue.error displayed in UI with error message and retry button

4. **UI Error Display**:
   - ConsumerWidget handles AsyncValue.error state in .when() callback
   - Shows icon, error message, retry button that calls ref.invalidate() (ProductsPage lines 129-154)

## Cross-Cutting Concerns

**Logging:**
- Not currently implemented; ApiClient interceptors (_onRequest, _onResponse, _onError in lines 93-117) are placeholders
- Can be extended for request/response/error logging

**Validation:**
- Product name/market search filters at repository level (empty query returns empty list)
- Model validation via Freezed generated constructors
- No explicit input validation layer

**Authentication:**
- Placeholder in ApiClient._onRequest (lines 98-101 commented out)
- Ready for Bearer token injection when auth system added

**Persistence:**
- FavoritesStore (singleton with ValueNotifier) handles favorites persistence to SharedPreferences
- Loaded on app startup in main() line 9
- Product/market/discount data loaded fresh each time (no HTTP caching layer)

---

*Architecture analysis: 2026-03-27*
