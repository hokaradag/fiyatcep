<!-- GSD:project-start source:PROJECT.md -->
## Project

**FiyatCep**

FiyatCep, bireysel kullanıcıların ve ailelerin market alışverişinde bilinçli karar vermesini sağlayan bir mobil fiyat karşılaştırma uygulamasıdır. Kullanıcılar aynı ürünü veya sepeti farklı marketlerde karşılaştırabilir, geçmiş fiyat trendlerini görebilir ve indirim fırsatlarını anlık takip edebilir. Uygulama Flutter tabanlıdır, Android ve iOS'u hedefler ve mevcut Clean Architecture + Riverpod altyapısı üzerine inşa edilmektedir.

**Core Value:** Aynı ürün ya da sepet için marketler arası gerçek fiyat farkını, geçmiş fiyat değişimini ve indirim fırsatlarını görünür kılmak — kullanıcı alışveriş kararını vermeden önce gerçek veriye bakabilmeli.

### Constraints

- **Tech Stack**: Flutter + Dart (Riverpod, Freezed, Dio) — mevcut mimari korunacak, yeni bağımlılıklar minimize edilecek
- **Platform**: Android + iOS eş zamanlı — platform-specific kodu isolate etmek kritik
- **Backend**: Scraping servisi bu milestone'da eş zamanlı geliştirilecek — Flutter tarafı API contract'ına göre çalışacak
- **Timeline**: Demo önce → Beta → Store sıralaması korunacak; her aşama bağımsız çalışabilir durumda olmalı
<!-- GSD:project-end -->

<!-- GSD:stack-start source:codebase/STACK.md -->
## Technology Stack

## Languages
- Dart 3.11.1+ - All application logic, UI, and business logic
## Runtime
- Flutter SDK (latest compatible with Dart 3.11.1)
- Pub (Dart package manager)
- Lockfile: `pubspec.lock` present
## Frameworks
- Flutter - Mobile UI framework for iOS, Android, macOS, Windows, Linux, and web platforms
- Flutter Riverpod 2.6.1 - Reactive state management and dependency injection
- Riverpod Annotation 2.3.0 - Code generation support for Riverpod
- Build Runner 2.4.0 - Build system for generated code
- Freezed 2.4.0 - Immutable data classes and pattern matching
- Freezed Annotation 2.4.0 - Annotations for Freezed code generation
- JSON Serializable 6.7.0 - JSON serialization/deserialization
- JSON Annotation 4.8.0 - Annotations for JSON serialization
- Riverpod Generator 2.3.0 - Code generation for Riverpod providers
- Flutter Test (SDK integrated) - Unit and widget testing framework
- Flutter Lints 6.0.0 - Linting rules for Flutter/Dart projects
## Key Dependencies
- Dio 5.3.0 - HTTP client for API communication with interceptor support, timeout configuration, and error handling
- Shared Preferences 2.5.4 - Local key-value storage for persisting favorites data
- Cupertino Icons 1.0.8 - iOS-style icons
- shared_preferences_android 2.4.21
- shared_preferences_foundation 2.5.6 (iOS/macOS)
- shared_preferences_linux 2.4.1
- shared_preferences_web 2.4.3
- shared_preferences_windows 2.4.1
## Configuration
- `pubspec.yaml` - Main dependency and build configuration
- `analysis_options.yaml` - Linter rules (uses flutter_lints package)
- No environment files required currently
- Base API URL configured in code: `https://api.example.com/api/v1`
- Configuration location: `lib/shared/providers/api_client_provider.dart`
- `lib/main.dart` - Application entry point with Riverpod ProviderScope setup
## Platform Requirements
- Dart SDK 3.11.1+
- Flutter SDK
- IDE: Android Studio, IntelliJ IDEA, VS Code, or similar
- For iOS: Xcode and CocoaPods
- For Android: Android SDK and Android Studio
- For Windows: Visual Studio 2022 or Build Tools
- iOS 11.0+ (from analysis based on Flutter defaults)
- Android API Level 16+
- macOS 10.11+
- Windows 10+
- Linux (GTK 3.0+)
- Web browsers (Chromium-based, Firefox, Safari)
<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->
## Conventions

## Naming Patterns
- Dart files use snake_case: `discount_item.dart`, `discount_card.dart`, `api_client.dart`
- Page files: `*_page.dart` (e.g., `discounts_page.dart`, `home_page.dart`)
- Widget files: suffix with component type (e.g., `discount_card.dart`, `market_card.dart`)
- Repository implementations: `*_repository_impl.dart` (e.g., `discount_repository_impl.dart`)
- Data source implementations: `*_datasource.dart` and `*_remote_datasource.dart` / `*_mock_datasource.dart`
- Provider files: `*_provider.dart` (e.g., `discounts_provider.dart`)
- Model files: `*_item.dart` (e.g., `discount_item.dart`, `product_item.dart`)
- camelCase for all function/method names: `getAllDiscounts()`, `getDiscountsByMarket()`, `isFavorite()`
- Private methods prefixed with underscore: `_handleException()`, `_normalizeText()`, `_formatPrice()`, `_onRequest()`
- Accessor methods use plain names: `get()`, `post()`, `put()`, `delete()` for HTTP verbs
- Computed getters for derived values: `discountAmount`, `discountPercent`, `displayPrice`
- camelCase for local and member variables: `baseUrl`, `remoteDataSource`, `discounts`, `favoritesNotifier`
- Constants use SCREAMING_SNAKE_CASE with `const`: `const String _favoritesKey = 'favorite_products'`
- Private members prefixed with underscore: `_dio`, `_prefs`, `_isInitialized`
- Null-safety used throughout: `String?`, `List<DiscountItem>?`
- Class names use PascalCase: `DiscountItem`, `ApiClient`, `AppException`, `FavoritesStore`
- Exception classes suffixed with `Exception`: `AppException`, `NetworkException`, `ServerException`, `ClientException`, `ParseException`, `CacheException`
- Repository/DataSource abstract classes: `DiscountRepository`, `DiscountRemoteDataSource`
- Implementation classes suffixed with `Impl`: `DiscountRepositoryImpl`, `DiscountRemoteDataSourceImpl`, `DiscountMockDataSourceImpl`
- Widget classes inherit from `StatelessWidget` or `StatefulWidget` appropriately
## Code Style
- No explicit formatter configured; follows Dart conventions
- Uses proper indentation and spacing throughout
- Line comments use `///` for public documentation
- Inline comments use `//` (e.g., "/// Üst satır: ürün adı + indirim yüzdesi")
- Turkish language used in some UI-related comments and strings
- `flutter_lints` package enabled via `analysis_options.yaml`
- Includes `package:flutter_lints/flutter.yaml` for recommended lints
- Rules are customizable but not overridden beyond Flutter defaults
- Can suppress lints with `// ignore: lint_name` or `// ignore_for_file: lint_name`
## Import Organization
- No path aliases configured
- Uses relative imports with `../` to navigate hierarchy
- Project packages referenced as `package:fiyatcep/`
## Error Handling
- Custom exception hierarchy with base `AppException` class containing `message`, `code`, and `originalException`
- Specific exception types for different scenarios: `NetworkException`, `ServerException` (5xx), `ClientException` (4xx), `ParseException`, `CacheException`
- Try-catch blocks in repository/datasource implementations
- Dio exceptions converted to custom exceptions in `_handleException()` methods
- Repositories return `Result<T>` sealed type with success/failure/loading states
- Providers throw `Exception()` when repository returns failure
## Logging
- Debugging via standard `print()` is avoided (linted)
- Logging through Flutter's debug output via `debugPrint()` or Dart's `log()` when needed
- Error tracking through exception classes that capture original exceptions
- No structured logging system implemented
## Comments
- Used for clarifying UI layout sections (e.g., "/// Üst satır: ürün adı + indirim yüzdesi" in `discount_card.dart`)
- Used to mark TODO items for future work: "// TODO: Change to actual API base URL when available"
- Used sparingly; code is expected to be self-documenting
- Uses `///` for public API documentation
- Method documentation includes `@override` annotations where applicable
- Minimal documentation on private methods
## Function Design
- Simple accessor methods (5-10 lines)
- Complex business logic (20-50 lines) with clear structure
- Repository methods follow consistent patterns using try-catch
- Named parameters preferred for clarity: `{required String endpoint, Map<String, dynamic>? queryParameters}`
- Required parameters marked with `required` keyword
- Optional parameters marked with `?` or given defaults
- Generic types used for flexibility: `Future<T>`, `Future<List<DiscountItem>>`
- Sealed `Result<T>` type wraps success/failure/loading states
- Null-safe returns: return type explicitly marks nullability
## Module Design
- Abstract interfaces (repositories, datasources) defined separately for dependency inversion
- Implementations are private to their modules
- Providers inject dependencies via constructor injection
- Not extensively used
- Main feature structure exposes page and domain interfaces
- Each feature is relatively self-contained with clear boundaries
## Feature Structure Pattern
- `domain/repositories/` - Abstract repository interfaces
- Pure Dart, no Flutter dependencies
- `data/datasources/` - Abstract and implementation classes (remote, mock)
- `data/repositories/` - Repository implementations using datasources
- `data/` - Mock data files for development
- `models/` - Freezed immutable data models with code generation
- `presentation/providers/` - Riverpod providers
- `widgets/` - Reusable widget components
- `*_page.dart` - Full page widgets
- Presentation depends on Domain and Data
- Data implements Domain interfaces
- Core utilities in `lib/core/` (network, errors)
- Shared utilities in `lib/shared/` (providers)
<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->
## Architecture

## Pattern Overview
- Feature-based modular architecture with clear separation of concerns
- Domain-Driven Design principles with explicit repository abstractions
- State management via Riverpod (functional reactive state)
- Sealed Result type for async operation handling (Success/Failure/Loading)
- Mock data layer with swap-ready remote datasources for future API integration
## Layers
- Purpose: UI components, pages, and consumer state management
- Location: `lib/features/*/presentation/` and `lib/features/*/*_page.dart`
- Contains: ConsumerStatefulWidget pages, local UI state, Riverpod provider watches
- Depends on: Presentation providers, domain models
- Used by: Bottom navigation, route navigation
- Purpose: Centralized state management and side effects orchestration
- Location: `lib/features/*/presentation/providers/*.dart`, `lib/shared/providers/*.dart`
- Contains: FutureProvider, FutureProvider.family for async data, Provider for singleton instances
- Depends on: Repositories, datasources
- Used by: Presentation layer widgets via `ref.watch()` and `ref.invalidate()`
- Purpose: Business logic contracts and data models
- Location: `lib/features/*/domain/repositories/*.dart`, `lib/features/*/models/*.dart`
- Contains: Abstract repository interfaces, domain-level Result<T> type wrapping, Freezed immutable models
- Depends on: Nothing (pure Dart)
- Used by: Repositories (implement), providers (depend on), presentation (models)
- Purpose: Data access and repository implementation
- Location: `lib/features/*/data/`
- Contains: Repository implementations, datasources (remote/mock/local), local cache logic
- Depends on: Domain repositories, API client, local storage
- Used by: Providers (instantiation)
- Purpose: Shared infrastructure and cross-cutting concerns
- Location: `lib/core/`
- Contains: Network client (Dio-based), exception hierarchy, Result type, logging utilities
- Depends on: Nothing (foundational)
- Used by: Data layer (API calls), repositories (error handling)
## Data Flow
- `ref.invalidate(productsProvider)` clears provider cache
- Next ref.watch triggers fresh async computation
- Manual refresh button example in ProductsPage line 147
- Riverpod manages state caching and dependency tracking
- Local UI state (like searchText) managed via ConsumerStatefulWidget.setState()
- Persistent local state (favorites) via FavoritesStore + SharedPreferences ValueNotifier pattern
- No global Redux/Bloc, direct provider-to-widget bindings
## Key Abstractions
- Purpose: Represent async operation outcomes uniformly
- Examples: `lib/core/errors/result.dart` (Success/Failure/Loading sealed classes)
- Pattern: Discriminated union with pattern matching via `.when()` method
- Used in: All repository methods return `Future<Result<T>>`
- Purpose: Abstract data acquisition source (API vs mock vs local cache)
- Examples: `lib/features/products/data/datasources/product_datasource.dart` (abstract), `product_mock_datasource.dart`, `product_remote_datasource.dart`
- Pattern: Abstract base class + concrete implementations
- Current: Mock datasources in use, remote datasources are stubs awaiting real API
- Purpose: Bridge domain/presentation from data details
- Examples: `lib/features/products/data/repositories/product_repository_impl.dart` implements `lib/features/products/domain/repositories/product_repository.dart`
- Pattern: Domain interface, implementation handles datasource selection, error wrapping, caching
- Benefit: Testable, swappable datasources (mock → remote)
- Purpose: Each feature (products, markets, discounts) is self-contained
- Location: `lib/features/{featureName}/` with parallel data/domain/presentation structure
- Cross-cutting: Shared only in `lib/shared/` (navigation, provider setup) and `lib/core/` (infrastructure)
## Entry Points
- Location: `lib/main.dart`
- Triggers: Initializes SharedPreferences via FavoritesStore.init(), wraps app in ProviderScope
- Responsibilities: Bootstrap phase, state initialization, Riverpod setup
- Location: `lib/shared/main_navigation.dart` (referenced in app.dart as home)
- Triggers: Called by FiyatCepApp MaterialApp
- Responsibilities: Bottom tab navigation, page switching via NavigationBar (5 tabs: Home, Products, Markets, Discounts, Favorites)
- Location: `lib/features/{featureName}/{featureName}_page.dart`
- Triggers: Navigated to via MainNavigation or internal navigation (detail pages)
- Responsibilities: Render feature-specific UI, watch providers, handle user interaction
## Error Handling
## Cross-Cutting Concerns
- Not currently implemented; ApiClient interceptors (_onRequest, _onResponse, _onError in lines 93-117) are placeholders
- Can be extended for request/response/error logging
- Product name/market search filters at repository level (empty query returns empty list)
- Model validation via Freezed generated constructors
- No explicit input validation layer
- Placeholder in ApiClient._onRequest (lines 98-101 commented out)
- Ready for Bearer token injection when auth system added
- FavoritesStore (singleton with ValueNotifier) handles favorites persistence to SharedPreferences
- Loaded on app startup in main() line 9
- Product/market/discount data loaded fresh each time (no HTTP caching layer)
<!-- GSD:architecture-end -->

<!-- GSD:workflow-start source:GSD defaults -->
## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:
- `/gsd:quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd:debug` for investigation and bug fixing
- `/gsd:execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->



<!-- GSD:profile-start -->
## Developer Profile

> Profile not yet configured. Run `/gsd:profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->
