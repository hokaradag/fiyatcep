# Phase 1: Quality Foundation - Context

**Gathered:** 2026-03-27 (discuss mode)
**Status:** Ready for planning

<domain>
## Phase Boundary

Codebase structural blockers are resolved so that new features can be safely built on top. No new user-facing features — this phase is entirely refactoring, cleanup, and test scaffolding.

Covers: TextNormalizer utility extraction, typed error handling in providers, widget decomposition of large pages, repository unit tests, widget tests for core flows, FavoritesStore Riverpod migration, CarrefourSA naming normalization.

</domain>

<decisions>
## Implementation Decisions

### Testing Strategy
- **D-01:** Use existing mock datasources (`ProductMockDataSourceImpl`, `MarketMockDataSourceImpl`, `DiscountMockDataSourceImpl`) directly in repository unit tests — no new mock library dependency
- **D-02:** No mocktail or mockito added — consistent with constraint "yeni bağımlılıklar minimize edilecek" and existing datasource-swapping pattern
- **D-03:** Widget tests cover products list page and product detail page only — minimum per QUAL-05 requirement ("en az ürün listesi ve ürün detay sayfası kapsanır")

### Claude's Discretion
- **FavoritesNotifier init pattern:** How async SharedPreferences loading is handled inside the new Riverpod NotifierProvider (AsyncNotifier vs Notifier with manual init step) — Claude decides based on Riverpod best practices
- **Widget extraction file layout:** Where extracted widgets from home_page, market_detail_page, product_detail_page are placed (alongside page in `pages/` dir or in `widgets/` dir) — Claude decides, preferring consistency with the existing `markets/widgets/` pattern
- **Error display on UI:** Whether page error builders are updated to show typed messages now or just the throw pattern is fixed — Claude decides, but QUAL-02 requirement says "kullanıcı anlamlı hata mesajı görür" so some UI update is required

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Requirements
- `.planning/REQUIREMENTS.md` §Quality Foundation — QUAL-01 through QUAL-07, acceptance criteria for each item
- `.planning/PROJECT.md` §Constraints — "yeni bağımlılıklar minimize edilecek", tech stack constraints

### Existing Code (critical files for this phase)
- `lib/core/errors/exceptions.dart` — AppException hierarchy (NetworkException, ServerException, etc.) — providers must throw these, not raw Exception
- `lib/core/errors/result.dart` — Sealed Result<T> type — understand the current failure/loading handling before changing providers
- `lib/features/favorites/data/favorites_store.dart` — ValueNotifier singleton being migrated
- `lib/main.dart` — Current FavoritesStore.init() call that must move to Riverpod lifecycle
- `lib/shared/providers/repository_providers.dart` — Dependency wiring; FavoritesNotifier provider goes here
- `lib/features/home/home_page.dart` — 432 lines, largest build() to decompose
- `lib/features/markets/presentation/pages/market_detail_page.dart` — 416 lines
- `lib/features/products/presentation/pages/product_detail_page.dart` — 270 lines
- `lib/features/products/data/datasources/product_mock_datasource.dart` — Contains `_normalizeText()` copy; use in tests
- `lib/features/markets/data/datasources/market_mock_datasource.dart` — Contains `_normalizeText()` copy
- `lib/features/discounts/data/datasources/discount_mock_datasource.dart` — Contains `_normalizeText()` copy
- `test/widget_test.dart` — Placeholder; tests go here (or in new test files alongside)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `AppException` hierarchy (`lib/core/errors/exceptions.dart`): Already has NetworkException, ServerException, ClientException, ParseException, CacheException — providers should throw these instead of raw `Exception(message)`
- `Result<T>` sealed class (`lib/core/errors/result.dart`): `.when()` pattern already in use in providers; the fix is in the failure/loading branches only
- Mock datasources: All 3 feature mock datasources implement the same abstract interface as remote — plug directly into repository constructors in tests without any additional setup
- `markets/presentation/widgets/market_card.dart`: Proof of extracted widget pattern — extracted widgets from market list follow this structure

### Established Patterns
- Repository test setup: `ProductRepositoryImpl(remoteDataSource: ProductMockDataSourceImpl())` — no DI container needed, direct constructor injection
- Widget naming: `*_card.dart` for list item widgets, `*_section.dart` or `*_widget.dart` for page sections — follow snake_case files, PascalCase classes
- Riverpod providers: Use `@riverpod` annotation or `Provider`/`FutureProvider` pattern as seen in existing providers
- Error handling: `_handleException()` pattern in datasource impls converts DioException → typed AppException already; the gap is in providers not forwarding the typed exception

### Integration Points
- `FavoritesNotifier` will be consumed by: `favorites_page.dart`, any widget that currently uses `FavoritesStore` (watch for refs to `favoritesNotifier` or `FavoritesStore.instance`)
- `TextNormalizer` destination: `lib/core/utils/text_normalizer.dart` fits the existing `lib/core/` infrastructure pattern
- CarrefourSA fix touches: mock datasource files and any hardcoded string references — check `mock_markets.dart`, `mock_market_prices.dart`, and any string literals in pages

</code_context>

<specifics>
## Specific Ideas

No specific requirements — open to standard approaches for decomposition and migration patterns.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

### Reviewed Todos (not folded)
None — no pending todos matched this phase.

</deferred>

---

*Phase: 01-quality-foundation*
*Context gathered: 2026-03-27*
