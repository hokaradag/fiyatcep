# Phase 1: Quality Foundation - Research

**Researched:** 2026-03-27
**Domain:** Flutter/Dart — refactoring, Riverpod migration, widget decomposition, test scaffolding
**Confidence:** HIGH (all findings verified against live codebase; no external library research required — phase uses only existing dependencies)

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- **D-01:** Use existing mock datasources (`ProductMockDataSourceImpl`, `MarketMockDataSourceImpl`, `DiscountMockDataSourceImpl`) directly in repository unit tests — no new mock library dependency
- **D-02:** No mocktail or mockito added — consistent with constraint "yeni bağımlılıklar minimize edilecek" and existing datasource-swapping pattern
- **D-03:** Widget tests cover products list page and product detail page only — minimum per QUAL-05 requirement ("en az ürün listesi ve ürün detay sayfası kapsanır")

### Claude's Discretion
- **FavoritesNotifier init pattern:** How async SharedPreferences loading is handled inside the new Riverpod NotifierProvider (AsyncNotifier vs Notifier with manual init step) — Claude decides based on Riverpod best practices
- **Widget extraction file layout:** Where extracted widgets from home_page, market_detail_page, product_detail_page are placed (alongside page in `pages/` dir or in `widgets/` dir) — Claude decides, preferring consistency with the existing `markets/widgets/` pattern
- **Error display on UI:** Whether page error builders are updated to show typed messages now or just the throw pattern is fixed — Claude decides, but QUAL-02 requirement says "kullanıcı anlamlı hata mesajı görür" so some UI update is required

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope.
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| QUAL-01 | Tüm `_normalizeText` kopyaları `TextNormalizer` utility'sine taşınır | 4 duplicate implementations found across 3 datasources + 1 widget (market_card.dart). Exact character map documented below. |
| QUAL-02 | Provider'lardaki `throw Exception(message)` typed `AppException` ile değiştirilir | 9 raw `throw Exception()` calls found across 3 provider files. `AppException` hierarchy already complete. |
| QUAL-03 | `home_page`, `product_detail_page`, `market_detail_page` sayfaları ayrı widget dosyaları olarak bölünmüştür | home_page.dart 432 lines, market_detail_page.dart 416 lines, product_detail_page.dart 270 lines — decomposition targets identified. |
| QUAL-04 | Repository katmanı için unit testler çalıştırılabilir | Repository pattern verified. Direct constructor injection pattern ready. No new dependencies needed. |
| QUAL-05 | Ana kullanıcı akışı için widget testleri çalıştırılabilir | Existing widget_test.dart fails due to missing ProviderScope wrapper. Fix pattern documented. |
| QUAL-06 | `FavoritesStore` singleton → `FavoritesNotifier` NotifierProvider olarak taşınır | FavoritesStore is a static-only class with ValueNotifier. All consumers listed below. |
| QUAL-07 | `CarrefourSA` ismi uygulama genelinde tek bir yazımla kullanılır | 10 occurrences found: 5 use `Carrefoursa`, 5 use `CarrefourSA`. Canonical form decision required. |
</phase_requirements>

---

## Summary

Phase 1 is a pure refactoring and test scaffolding phase. No new user-facing features are built. All work operates within the existing Flutter/Dart/Riverpod stack — no new pub.dev packages are needed. Research was conducted entirely from the live codebase, giving HIGH confidence on all findings.

The seven requirements map cleanly to discrete code changes: (1) extract a `TextNormalizer` utility class, (2) fix 9 `throw Exception()` calls to throw typed `AppException` subclasses, (3) decompose three large page `build()` methods into extracted widgets, (4) write repository unit tests using existing mock datasources, (5) fix and expand widget tests, (6) migrate `FavoritesStore` static singleton to a Riverpod `AsyncNotifier`, and (7) normalize the `CarrefourSA` spelling across 10 occurrences in mock data files.

The critical sequencing insight is: QUAL-06 (FavoritesStore migration) must be done before the widget tests (QUAL-05) are written, because the widget tests will need to work with the new Riverpod-managed favorites state. QUAL-01 (TextNormalizer) can proceed independently and should go first as it unblocks the datasource files from carrying duplicate utility code.

**Primary recommendation:** Implement in this order — QUAL-01 (TextNormalizer extraction) → QUAL-07 (CarrefourSA naming) → QUAL-02 (typed errors) → QUAL-06 (FavoritesStore migration) → QUAL-03 (widget decomposition) → QUAL-04 (repository tests) → QUAL-05 (widget tests). This ordering avoids rework: test files written after migration are clean from the start.

---

## Standard Stack

### Core (no new packages needed)
| Library | Version in pubspec | Purpose in this phase |
|---------|-------------------|----------------------|
| flutter_riverpod | ^2.4.0 | FavoritesNotifier migration — AsyncNotifier pattern |
| flutter_test (SDK) | SDK-integrated | Unit tests and widget tests |
| shared_preferences | ^2.5.4 | Retained inside FavoritesNotifier for persistence |

### No New Dependencies
This phase explicitly prohibits new pub.dev packages (D-02). All tools needed already exist:
- `flutter_test` is already in `dev_dependencies`
- `flutter_riverpod` already provides `AsyncNotifier` / `NotifierProvider`
- `shared_preferences` is already wired

---

## Architecture Patterns

### Recommended Project Structure (additions only)
```
lib/
├── core/
│   └── utils/
│       └── text_normalizer.dart        # NEW — QUAL-01
├── features/
│   ├── favorites/
│   │   ├── data/
│   │   │   └── favorites_store.dart    # KEEP as-is or delete after QUAL-06
│   │   └── presentation/
│   │       └── providers/
│   │           └── favorites_notifier.dart  # NEW — QUAL-06
│   ├── home/
│   │   └── widgets/                    # NEW directory — QUAL-03
│   │       ├── home_header_widget.dart
│   │       ├── home_stats_section.dart
│   │       └── home_discounts_section.dart
│   ├── markets/
│   │   └── widgets/                    # EXISTING — add to here
│   │       └── market_detail_*.dart    # NEW — QUAL-03
│   └── products/
│       └── widgets/                    # NEW directory — QUAL-03
│           └── product_detail_*.dart   # NEW — QUAL-03
test/
├── widget_test.dart                    # MODIFY — fix ProviderScope
├── features/
│   ├── products/
│   │   ├── product_repository_test.dart  # NEW — QUAL-04
│   │   └── products_page_test.dart       # NEW — QUAL-05
│   ├── markets/
│   │   └── market_repository_test.dart   # NEW — QUAL-04
│   └── discounts/
│       └── discount_repository_test.dart # NEW — QUAL-04
```

### Pattern 1: TextNormalizer Utility (QUAL-01)

**What:** Static utility class in `lib/core/utils/text_normalizer.dart`. The identical `_normalizeText()` method exists in 4 places: `ProductMockDataSourceImpl`, `MarketMockDataSourceImpl`, `DiscountMockDataSourceImpl`, and `MarketCard`. All 4 copies use the same 6-character replacement map.

**Confirmed character map from codebase:**
```dart
// lib/core/utils/text_normalizer.dart
class TextNormalizer {
  static String normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll('ç', 'c')
        .replaceAll('ğ', 'g')
        .replaceAll('ı', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ş', 's')
        .replaceAll('ü', 'u');
  }
}
```

**After extraction:** Each datasource replaces `_normalizeText(x)` with `TextNormalizer.normalize(x)` and removes its private method. `MarketCard._normalizeName()` is replaced with `TextNormalizer.normalize()`.

**Note:** `MarketCard` also uses `_normalizeName` for switch-case matching against `'carrefoursa'` (lowercase, no special chars). After TextNormalizer is in place and QUAL-07 normalizes the CarrefourSA spelling, the switch-case string `'carrefoursa'` remains correct because `TextNormalizer.normalize('CarrefourSA')` = `'carrefoursa'`.

### Pattern 2: Typed Error Propagation (QUAL-02)

**What:** All 9 instances of `throw Exception(message)` in provider files must throw the appropriate `AppException` subclass. The repository already returns `FailureResult(message: e.message, code: e.code)` — the typed information is already there; it is lost only in the provider's `.when()` failure branch.

**All occurrences (verified by reading source):**

| File | Provider | Current | Fix |
|------|----------|---------|-----|
| `products_provider.dart` | `productsProvider` | `throw Exception(message)` | `throw AppException(message: message, code: code)` |
| `products_provider.dart` | `productsProvider` | `throw Exception('Loading')` | remove — LoadingResult should not be thrown |
| `products_provider.dart` | `productSearchProvider` | `throw Exception(message)` | `throw AppException(message: message, code: code)` |
| `products_provider.dart` | `productSearchProvider` | `throw Exception('Loading')` | remove |
| `products_provider.dart` | `productByIdProvider` | `throw Exception(message)` | `throw AppException(message: message, code: code)` |
| `products_provider.dart` | `productByIdProvider` | `throw Exception('Loading')` | remove |
| `markets_provider.dart` | `marketsProvider` | `throw Exception(message)` | `throw AppException(message: message, code: code)` |
| `markets_provider.dart` | `marketSearchProvider` | `throw Exception(message)` | `throw AppException(message: message, code: code)` |
| `markets_provider.dart` | `marketByIdProvider` | `throw Exception(message)` | `throw AppException(message: message, code: code)` |
| `discounts_provider.dart` | `discountsProvider` | `throw Exception(message)` | `throw AppException(message: message, code: code)` |
| `discounts_provider.dart` | `discountSearchProvider` | `throw Exception(message)` | `throw AppException(message: message, code: code)` |
| `discounts_provider.dart` | `discountsByMarketProvider` | `throw Exception(message)` | `throw AppException(message: message, code: code)` |

**Note on loading branch:** `LoadingResult` is never returned by repositories in normal flow (repositories are async and return immediately). The `loading: () => throw Exception('Loading')` branches are dead code. They should be removed or replaced with an assertion. The `Result.when()` signature requires all 3 branches, so replace `loading` with `throw StateError('Unexpected loading state')` or restructure to avoid the dead branch.

**UI display:** QUAL-02 says users must see a meaningful message. `AsyncValue.error` in Riverpod's `.when(error: (e, st) => ...)` receives the thrown object. After fix, `e` will be an `AppException` and `e.message` (via `toString()`) will show the Turkish-language message from the exception. Pages that currently use `.when(error: (e, st) => Text(e.toString()))` will automatically show the better message once providers throw `AppException` instead of opaque `Exception(message)` — because `AppException.toString()` returns `message` directly.

### Pattern 3: FavoritesStore Migration (QUAL-06)

**What:** Replace static-singleton `FavoritesStore` with `FavoritesNotifier extends AsyncNotifier<List<ProductItem>>`. The `AsyncNotifier` pattern handles the async SharedPreferences initialization naturally via `build()`.

**Recommended pattern (AsyncNotifier — Claude's Discretion resolved):**

`AsyncNotifier` is the correct choice. Reasons:
1. Initialization requires `await SharedPreferences.getInstance()` — `AsyncNotifier.build()` is inherently async, eliminating the need for a separate `.init()` method
2. Riverpod 2.x explicitly provides `AsyncNotifier` for this pattern
3. Widget consumers get `AsyncValue<List<ProductItem>>` — consistent with how `productsProvider` / `marketsProvider` work in the existing codebase

```dart
// lib/features/favorites/presentation/providers/favorites_notifier.dart
@riverpod
class FavoritesNotifier extends _$FavoritesNotifier {
  static const _key = 'favorite_products';

  @override
  Future<List<ProductItem>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_key) ?? [];
    return stored.map((s) => ProductItem.fromJson(jsonDecode(s))).toList();
  }

  Future<void> add(ProductItem product) async { ... }
  Future<void> remove(ProductItem product) async { ... }
  Future<void> toggle(ProductItem product) async { ... }
  bool isFavorite(List<ProductItem> favorites, ProductItem product) => favorites.any((p) => p == product);
}
```

**Consumers to update:**
- `lib/features/favorites/favorites_page.dart` — replaces `ValueListenableBuilder<List<ProductItem>>` + `FavoritesStore.favoritesNotifier` with `ref.watch(favoritesNotifierProvider)` + `.when()`
- `lib/features/home/home_page.dart` lines ~148-155 — replaces `ValueListenableBuilder` + `FavoritesStore.favoritesNotifier` for the stats section
- `lib/features/products/product_detail_page.dart` — uses `FavoritesStore.isFavorite()` and `FavoritesStore.toggle()`; replace with provider calls
- `lib/main.dart` — remove `await FavoritesStore.init()` (now handled by AsyncNotifier.build())

**Note:** `FavoritesPage` is currently a `StatelessWidget` (no Riverpod). After migration it must become a `ConsumerWidget`.

### Pattern 4: Widget Decomposition (QUAL-03)

**What:** Break large `build()` methods into extracted `StatelessWidget` subclasses.

**File layout decision (Claude's Discretion resolved):** Place extracted widgets in `widgets/` subdirectory alongside each feature, matching the existing `lib/features/markets/widgets/market_card.dart` precedent. Specifically:
- `lib/features/home/widgets/` — home page sections
- `lib/features/markets/widgets/` — already exists; add market detail sections here
- `lib/features/products/widgets/` — create; add product detail sections here

**Targets:**
| Page | File | Lines | Extraction candidates |
|------|------|-------|----------------------|
| `HomePage` | `lib/features/home/home_page.dart` | 432 | `HomeHeaderWidget`, `HomeStatsSection` (contains the nested `_buildStatCard` logic), `HomeMarketsSection`, `HomeDiscountsSection` |
| `MarketDetailPage` | `lib/features/markets/market_detail_page.dart` | 416 | `MarketDetailHeaderWidget`, `MarketProductsSection`, `MarketDiscountsSection` |
| `ProductDetailPage` | `lib/features/products/product_detail_page.dart` | 270 | `ProductImagePlaceholder`, `ProductPriceComparisonSection`, `ProductMarketPriceRow` |

**Anti-pattern to avoid:** Do not extract methods (`Widget _buildSection()`) as the goal is extractable, separately-testable widget classes, not private helper methods. Extracted classes must be `StatelessWidget` (no state, receive data via constructor).

### Pattern 5: Repository Unit Tests (QUAL-04)

**What:** Flutter unit tests using `flutter_test`, with mock datasources injected directly. No Riverpod container needed for repository tests — repositories take datasources via constructor.

```dart
// test/features/products/product_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fiyatcep/features/products/data/repositories/product_repository_impl.dart';
import 'package:fiyatcep/features/products/data/datasources/product_mock_datasource.dart';
import 'package:fiyatcep/core/errors/result.dart';

void main() {
  group('ProductRepository', () {
    late ProductRepositoryImpl repository;

    setUp(() {
      repository = ProductRepositoryImpl(
        remoteDataSource: ProductMockDataSourceImpl(),
      );
    });

    test('getAllProducts returns success with non-empty list', () async {
      final result = await repository.getAllProducts();
      expect(result, isA<SuccessResult<List>>());
    });

    test('searchProducts with empty query returns empty success', () async {
      final result = await repository.searchProducts('');
      final data = (result as SuccessResult).data;
      expect(data, isEmpty);
    });

    test('searchProducts normalizes Turkish characters', () async {
      final result = await repository.searchProducts('makarna');
      final data = (result as SuccessResult).data;
      expect(data.isNotEmpty, true);
    });
  });
}
```

Same pattern for `MarketRepository` and `DiscountRepository`.

### Pattern 6: Widget Tests (QUAL-05)

**Critical finding:** The existing `test/widget_test.dart` FAILS because `FiyatCepApp` contains Riverpod `ConsumerWidget`s but is not wrapped in `ProviderScope`. The test pumps `FiyatCepApp()` directly without a `ProviderScope`.

**Fix required:** Widget tests must wrap with `ProviderScope`:
```dart
await tester.pumpWidget(
  const ProviderScope(child: FiyatCepApp()),
);
```

**Also:** `FavoritesStore.init()` is called in `main()` but NOT called in tests — after QUAL-06 migration this is no longer needed. Before migration, tests that touch favorites functionality need `SharedPreferences.setMockInitialValues({})` or must stub the store.

**Products list page test strategy:**
```dart
// test/features/products/products_page_test.dart
testWidgets('ProductsPage shows loading then product list', (tester) async {
  await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: ProductsPage())));
  expect(find.byType(CircularProgressIndicator), findsOneWidget); // loading state
  await tester.pumpAndSettle();
  expect(find.byType(ListView), findsOneWidget); // products loaded
});
```

**Product detail page test:** Needs a `ProductItem` instance passed as constructor arg. Use any item from `ProductMockDataSourceImpl` mock data.

### Pattern 7: CarrefourSA Normalization (QUAL-07)

**All occurrences found (verified by grep):**

| File | Current value | Target |
|------|--------------|--------|
| `features/markets/data/datasources/market_mock_datasource.dart:48` | `'Carrefoursa'` | `'CarrefourSA'` |
| `features/markets/widgets/market_card.dart:34` | `case 'carrefoursa':` | keep as-is (normalized comparison, correct) |
| `features/markets/widgets/market_card.dart:51` | `case 'carrefoursa':` | keep as-is (normalized comparison, correct) |
| `features/discounts/data/datasources/discount_mock_datasource.dart:48` | `'Carrefoursa'` | `'CarrefourSA'` |
| `features/markets/data/mock_markets.dart:42` | `'CarrefourSA'` | already correct |
| `features/discounts/data/mock_discounts.dart:42` | `'CarrefourSA'` | already correct |
| `features/products/data/mock_market_prices.dart:33` | `'CarrefourSA'` | already correct |
| `features/products/data/mock_market_prices.dart:81` | `'CarrefourSA'` | already correct |
| `features/products/data/mock_products.dart:45` | `'CarrefourSA'` | already correct |
| `features/products/data/datasources/product_mock_datasource.dart:52` | `'Carrefoursa'` | `'CarrefourSA'` |

**Canonical form: `CarrefourSA`** — matches the legal brand name, already used in 7 of 10 occurrences, and matches `mock_markets.dart` which is the source of truth for market names.

**Files to change:** 3 files — `market_mock_datasource.dart`, `discount_mock_datasource.dart`, `product_mock_datasource.dart`.

**Note on market_card.dart switch-cases:** These use `_normalizeName()` (which will become `TextNormalizer.normalize()` after QUAL-01). `TextNormalizer.normalize('CarrefourSA')` = `'carrefoursa'`, so the existing switch-case strings `'carrefoursa'` remain correct after QUAL-07. No change needed in market_card.dart for QUAL-07.

### Anti-Patterns to Avoid

- **Extracting methods instead of widget classes:** `Widget _buildSomething()` private helpers are not extracted widgets — they don't enable independent testing or reuse. Use `class SomethingWidget extends StatelessWidget`.
- **Adding mockito/mocktail:** Locked out by D-02. Use concrete mock datasource implementations directly.
- **Notifier vs AsyncNotifier confusion:** `Notifier<List<ProductItem>>` requires synchronous `build()` — cannot `await SharedPreferences.getInstance()`. Must use `AsyncNotifier<List<ProductItem>>`.
- **Forgetting to wrap tests with ProviderScope:** The existing test proves this — it crashes with "No ProviderScope found". Every widget test for any page that uses Riverpod needs `ProviderScope` as ancestor.
- **Leaving `FavoritesPage` as StatelessWidget:** After migration it needs `ref` access — must become `ConsumerWidget`.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Async state init in Notifier | Manual `init()` + bool flag (current pattern) | `AsyncNotifier.build()` | Riverpod manages lifecycle; `build()` runs before first read |
| Mock objects for tests | Custom stub classes | Existing `*MockDataSourceImpl` | Already implement the same abstract interface |
| Turkish character normalization | New regex or Unicode library | Simple `replaceAll` map (already proven) | Works for the 6 special characters in Turkish; no external dependency |

---

## Runtime State Inventory

> This is a refactoring phase. Runtime state audit applies because FavoritesStore data is persisted.

| Category | Items Found | Action Required |
|----------|-------------|------------------|
| Stored data | SharedPreferences key `'favorite_products'` — stores JSON-encoded `List<ProductItem>` | No migration needed — key name and data format are unchanged; `AsyncNotifier` reads the same key via same `SharedPreferences` API |
| Live service config | None — no external services at runtime | None |
| OS-registered state | None — no task scheduler, pm2, or systemd involvement | None |
| Secrets/env vars | None — `shared_preferences` uses platform storage, no env vars | None |
| Build artifacts | `pubspec.lock` will not change (no new deps) | None |

**Key insight:** The SharedPreferences persistence format is unchanged — both old `FavoritesStore` and new `FavoritesNotifier` use `getStringList('favorite_products')` with `jsonEncode`/`jsonDecode`. Existing user favorites survive the migration.

---

## Common Pitfalls

### Pitfall 1: Widget Test Missing ProviderScope
**What goes wrong:** Test crashes with `StateError: No ProviderScope found` at `HomePage.build`.
**Why it happens:** `FiyatCepApp` has no `ProviderScope` — it expects to be wrapped by `ProviderScope` in `main()`. Widget tests don't run `main()`.
**How to avoid:** Always wrap pumped widgets with `ProviderScope` in widget tests: `tester.pumpWidget(const ProviderScope(child: FiyatCepApp()))`.
**Warning signs:** `StateError: No ProviderScope found` in test output — already occurring in current `widget_test.dart`.

### Pitfall 2: AsyncNotifier Build Returns vs State
**What goes wrong:** Calling `state = newValue` in `AsyncNotifier.build()` — `build()` should return the initial value, not set `state` directly.
**Why it happens:** Confusion between `Notifier` (synchronous `build` returns T) and `AsyncNotifier` (async `build` returns `Future<T>`).
**How to avoid:** `AsyncNotifier.build()` is async and returns `Future<List<ProductItem>>`. To update state after build: assign `state = AsyncData(newList)`.
**Warning signs:** Dart type errors during code generation when using `@riverpod` annotation.

### Pitfall 3: Dead Loading Branch in Result.when()
**What goes wrong:** Keeping `loading: () => throw Exception('Loading')` — this is dead code that adds noise and may mask bugs.
**Why it happens:** `Result<T>` has a `LoadingResult` case that repositories never actually return (they're all `async` functions that complete).
**How to avoid:** Remove the `loading` branch or replace with `throw StateError('Unexpected loading state in provider')`. Consider whether `LoadingResult` should even exist in `Result<T>` — for now, just make the dead branch safe.
**Warning signs:** If `LoadingResult` is ever accidentally returned by a repository, the current code silently throws an opaque message.

### Pitfall 4: TextNormalizer Import After Extraction
**What goes wrong:** Forgetting to update import paths in datasource files after extracting `TextNormalizer` to `lib/core/utils/text_normalizer.dart`.
**Why it happens:** The private `_normalizeText` method had no import; the extracted class requires one.
**How to avoid:** Each updated datasource and `market_card.dart` must add `import 'package:fiyatcep/core/utils/text_normalizer.dart';`.
**Warning signs:** Dart analysis errors `Undefined name '_normalizeText'` or `TextNormalizer not found`.

### Pitfall 5: FavoritesPage is StatelessWidget
**What goes wrong:** `FavoritesPage` currently extends `StatelessWidget`. After migration it calls `ref.watch()` — this won't compile.
**Why it happens:** Pre-migration, `FavoritesPage` used `ValueListenableBuilder` which doesn't need `ref`.
**How to avoid:** Change `FavoritesPage extends StatelessWidget` to `FavoritesPage extends ConsumerWidget` and update `build(BuildContext context)` to `build(BuildContext context, WidgetRef ref)`.
**Warning signs:** Compile error `The name 'ref' is defined in '_ConsumerState' but is not accessible`.

---

## Code Examples

### AsyncNotifier Pattern for FavoritesNotifier
```dart
// lib/features/favorites/presentation/providers/favorites_notifier.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../products/models/product_item.dart';

class FavoritesNotifier extends AsyncNotifier<List<ProductItem>> {
  static const String _favoritesKey = 'favorite_products';

  @override
  Future<List<ProductItem>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_favoritesKey) ?? [];
    return stored
        .map((item) => ProductItem.fromJson(jsonDecode(item)))
        .toList();
  }

  Future<void> add(ProductItem product) async {
    final current = await future; // wait for current state
    if (current.any((p) => p == product)) return;
    final updated = [...current, product];
    state = AsyncData(updated);
    await _save(updated);
  }

  Future<void> remove(ProductItem product) async {
    final current = await future;
    final updated = current.where((p) => p != product).toList();
    state = AsyncData(updated);
    await _save(updated);
  }

  Future<void> toggle(ProductItem product) async {
    final current = await future;
    if (current.any((p) => p == product)) {
      await remove(product);
    } else {
      await add(product);
    }
  }

  bool isFavorite(List<ProductItem> favorites, ProductItem product) {
    return favorites.any((p) => p == product);
  }

  Future<void> _save(List<ProductItem> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = favorites.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_favoritesKey, encoded);
  }
}

final favoritesNotifierProvider =
    AsyncNotifierProvider<FavoritesNotifier, List<ProductItem>>(
  FavoritesNotifier.new,
);
```

### Typed Error in Provider
```dart
// Before
failure: (message, code) => throw Exception(message),

// After
failure: (message, code) => throw AppException(message: message, code: code),
```

### Repository Test Setup
```dart
// test/features/products/product_repository_test.dart
void main() {
  group('ProductRepositoryImpl', () {
    late ProductRepositoryImpl repo;
    setUp(() {
      repo = ProductRepositoryImpl(remoteDataSource: ProductMockDataSourceImpl());
    });

    test('getAllProducts returns SuccessResult with items', () async {
      final result = await repo.getAllProducts();
      expect(result, isA<SuccessResult<List<ProductItem>>>());
      final data = (result as SuccessResult<List<ProductItem>>).data;
      expect(data, isNotEmpty);
    });
  });
}
```

### Widget Test with ProviderScope
```dart
// test/widget_test.dart (fix)
testWidgets('FiyatCep app renders bottom navigation', (tester) async {
  await tester.pumpWidget(
    const ProviderScope(child: FiyatCepApp()),
  );
  await tester.pump(); // one frame for async providers
  expect(find.text('Ana Sayfa'), findsOneWidget);
});
```

---

## State of the Art

| Old Approach | Current Approach | Impact |
|--------------|------------------|--------|
| ValueNotifier singleton with manual `init()` | AsyncNotifier (Riverpod 2.x) | Riverpod manages lifecycle; testable; consistent with rest of app |
| Raw `Exception(message)` throws | Typed `AppException` throws | UI can display user-meaningful messages; debug tooling can categorize errors |
| Duplicate utility methods per class | Shared utility class in `lib/core/utils/` | Single fix point; consistent behavior across features |

---

## Open Questions

1. **Should `FailureResult` carry the typed `AppException` rather than just `String message`?**
   - What we know: `FailureResult` only stores `message: String` and `code: String?`. Type information is lost when repository returns `FailureResult`.
   - What's unclear: Whether this limitation matters for Phase 1. Currently the typed exceptions are created inside `_handleException()` in remote datasources, then flattened to string in `FailureResult`.
   - Recommendation: Do NOT change `Result<T>` in this phase — the fix to throw `AppException(message: message, code: code)` in providers is sufficient for QUAL-02's "anlamlı hata mesajı" requirement. Changing `FailureResult` to carry an `AppException` is a deeper refactor deferred to Phase 2 when real API errors appear.

2. **Where should `FavoritesNotifier` provider be declared — in `repository_providers.dart` or its own file?**
   - What we know: `repository_providers.dart` currently wires the 3 data repositories. Favorites is a different concern (local-only, no remote datasource).
   - Recommendation: Declare in a new dedicated file `lib/features/favorites/presentation/providers/favorites_notifier.dart`. This matches the feature-module pattern (other features have `presentation/providers/` directories).

---

## Environment Availability

Step 2.6: This is a code/config-only refactoring phase. The only runtime tool needed is the Flutter SDK, already confirmed active (test run executed above).

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | All test runs | ✓ | SDK present (tests ran) | — |
| shared_preferences | FavoritesNotifier | ✓ | ^2.5.4 in pubspec | — |
| flutter_riverpod | FavoritesNotifier, widget tests | ✓ | ^2.4.0 in pubspec | — |

---

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | flutter_test (SDK-integrated) |
| Config file | none — flutter test command discovers `test/` directory automatically |
| Quick run command | `flutter test test/widget_test.dart` |
| Full suite command | `flutter test` |

### Phase Requirements to Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| QUAL-01 | TextNormalizer produces correct output for all 6 Turkish characters | unit | `flutter test test/core/text_normalizer_test.dart` | ❌ Wave 0 |
| QUAL-02 | Provider throws AppException (not raw Exception) on failure | unit | `flutter test test/features/products/product_repository_test.dart` | ❌ Wave 0 |
| QUAL-03 | Large pages no longer have inline widget trees in build() | code review / analysis | `flutter analyze` | n/a — structural |
| QUAL-04 | Repository unit tests pass | unit | `flutter test test/features/` | ❌ Wave 0 |
| QUAL-05 | Products list page renders, product detail page renders | widget | `flutter test test/features/products/` | ❌ Wave 0 |
| QUAL-06 | FavoritesNotifier loads from SharedPreferences and provides list | unit | `flutter test test/features/favorites/favorites_notifier_test.dart` | ❌ Wave 0 |
| QUAL-07 | No 'Carrefoursa' string literals remain | static search | `grep -r 'Carrefoursa' lib/` | n/a — verification command |

### Sampling Rate
- **Per task commit:** `flutter test` (full suite — suite is small, < 30 seconds expected)
- **Per wave merge:** `flutter test && flutter analyze`
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] `test/core/text_normalizer_test.dart` — covers QUAL-01
- [ ] `test/features/products/product_repository_test.dart` — covers QUAL-04 (products) and QUAL-02
- [ ] `test/features/markets/market_repository_test.dart` — covers QUAL-04 (markets)
- [ ] `test/features/discounts/discount_repository_test.dart` — covers QUAL-04 (discounts)
- [ ] `test/features/products/products_page_test.dart` — covers QUAL-05 (products list)
- [ ] `test/features/products/product_detail_page_test.dart` — covers QUAL-05 (product detail)
- [ ] `test/features/favorites/favorites_notifier_test.dart` — covers QUAL-06
- [ ] Fix `test/widget_test.dart` — add `ProviderScope` wrapper (currently failing)

---

## Sources

### Primary (HIGH confidence)
- Live codebase — direct file reading of all referenced files
  - `lib/core/errors/exceptions.dart` — AppException hierarchy
  - `lib/core/errors/result.dart` — Result sealed type
  - `lib/features/favorites/data/favorites_store.dart` — migration source
  - `lib/features/*/presentation/providers/*_provider.dart` — all 12 `throw Exception()` occurrences
  - `lib/features/*/data/datasources/*_mock_datasource.dart` — all 3 duplicate `_normalizeText` implementations
  - `lib/features/markets/widgets/market_card.dart` — 4th `_normalizeName` copy
  - `lib/main.dart` — FavoritesStore.init() call location
  - `test/widget_test.dart` — existing test, confirmed failing
- `flutter test test/widget_test.dart` execution — confirmed StateError: No ProviderScope found

### Secondary (MEDIUM confidence)
- Riverpod 2.x `AsyncNotifier` pattern — confirmed from pubspec (`flutter_riverpod: ^2.4.0`) and existing `FutureProvider` usage patterns in codebase

### Tertiary (LOW confidence)
- None

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — no new packages; verified from pubspec.yaml
- Architecture: HIGH — patterns verified from live codebase file reads
- Pitfalls: HIGH — Pitfall 1 confirmed by running actual test (test fails with exact described error)

**Research date:** 2026-03-27
**Valid until:** 2026-06-27 (stable — no external dependencies; only stale if Flutter SDK makes breaking changes to Riverpod 2.x or flutter_test APIs)
