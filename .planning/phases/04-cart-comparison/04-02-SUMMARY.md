---
phase: 04-cart-comparison
plan: 02
subsystem: ui
tags: [riverpod, flutter, cart, comparison, futprovider, tdd]

# Dependency graph
requires:
  - phase: 04-cart-comparison/04-01
    provides: CartNotifier AsyncNotifier with add/remove/clear and cartNotifierProvider
  - phase: 03-price-comparison-market-detail
    provides: MarketPriceItem model, productMarketPricesProvider, marketBrands config
  - phase: 01-quality-foundation
    provides: FavoritesNotifier AsyncNotifier pattern and test infrastructure

provides:
  - CartMarketResult model with matchedCount/partialTotal/isCheapest aggregation
  - cartComparisonProvider FutureProvider with fan-out price fetching across cart items
  - CartAppBarIcon with red badge and green icon tint when cart non-empty
  - CartProductListSection with remove buttons and accessibility semantics
  - CartMarketComparisonCard expandable card with En Uygun badge and partial footnotes
  - CartComparisonPage full comparison page with loading/error/empty/data states
  - Sepete Ekle/Sepetten Cikar toggle on ProductDetailPage with snackbar and Sepete Git action
  - CartAppBarIcon wired into ProductsPage and ProductDetailPage AppBar actions

affects: [04-UAT, any phase consuming cart comparison UI or cartComparisonProvider]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Fan-out pattern: Future.wait across all cart items for concurrent price fetching"
    - "ref.watch(asyncNotifierProvider) used synchronously before any await in FutureProvider to ensure correct Riverpod dependency tracking"
    - "Test pattern for FutureProvider watching AsyncNotifier: await cart notifier future before reading comparison provider"
    - "CartMarketResult is plain Dart class (not Freezed) — not serialized, only used for UI rendering"
    - "TDD RED/GREEN cycle applied to cartComparisonProvider aggregation logic"

key-files:
  created:
    - lib/features/cart/presentation/providers/cart_comparison_provider.dart
    - lib/features/cart/presentation/providers/cart_notifier.dart
    - lib/features/cart/widgets/cart_app_bar_icon.dart
    - lib/features/cart/widgets/cart_product_list_section.dart
    - lib/features/cart/widgets/cart_market_comparison_card.dart
    - lib/features/cart/cart_comparison_page.dart
    - test/features/cart/presentation/providers/cart_comparison_provider_test.dart
    - test/features/cart/presentation/providers/cart_notifier_test.dart
  modified:
    - lib/features/products/product_detail_page.dart
    - lib/features/products/products_page.dart

key-decisions:
  - "await cartNotifierProvider.future before reading cartComparisonProvider in tests — FutureProvider ref.watch on AsyncNotifier requires the notifier to be in AsyncData state before the comparison provider executes, otherwise the .future never resolves"
  - "CartMarketResult is plain Dart class (no Freezed) — only used for UI rendering, no serialization needed, simpler to copy with manual constructor for isCheapest mutation"
  - "0-match markets sort to bottom in cartComparisonProvider results — showing 0.00 TL total at top would appear cheapest, which is dishonest per research Open Question 2"

patterns-established:
  - "FutureProvider test: always prime dependent AsyncNotifierProvider with .future before reading the FutureProvider"
  - "Fan-out concurrent fetching: Future.wait(cart.map((p) => ref.read(provider(p.id).future))) for parallel price queries"

requirements-completed: [COMP-03]

# Metrics
duration: 36min
completed: 2026-03-30
---

# Phase 4 Plan 02: Cart Comparison UI Summary

**FutureProvider fan-out aggregating per-market cart totals, 5 new widgets (CartAppBarIcon, CartProductListSection, CartMarketComparisonCard, CartComparisonPage), and "Sepete Ekle" wired into ProductDetailPage completing the COMP-03 cart comparison user flow**

## Performance

- **Duration:** 36 min
- **Started:** 2026-03-30T10:27:04Z
- **Completed:** 2026-03-30T11:03:27Z
- **Tasks:** 2 (TDD: RED + GREEN for Task 1; direct implementation for Task 2)
- **Files modified:** 10 (8 created, 2 modified)

## Accomplishments

- cartComparisonProvider fan-out: fetches prices for all cart items concurrently via Future.wait, aggregates per-market matchedCount and partialTotal, sorts 0-match markets to bottom, marks cheapest market with isCheapest=true
- Complete cart comparison UI: CartAppBarIcon with badge, CartProductListSection with remove semantics, CartMarketComparisonCard expandable with En Uygun badge and partial footnotes, CartComparisonPage with Sepeti Temizle dialog
- ProductsPage and ProductDetailPage AppBar wired with CartAppBarIcon; ProductDetailPage has full Sepete Ekle/Sepetten Cikar toggle with snackbar actions
- Full test suite: 90 tests passing (8 new cartComparisonProvider tests + 8 existing cartNotifier tests + 74 from prior phases)

## Task Commits

Each task was committed atomically:

1. **Task 1 RED: cartComparisonProvider failing test suite** - `79adfc0` (test)
2. **Task 1 GREEN: cartComparisonProvider implementation** - `a87a4c8` (feat)
3. **Task 2: Cart UI widgets + page wiring** - `c159de2` (feat)

**Plan metadata:** (docs commit follows)

_Note: TDD RED/GREEN commits for Task 1, then direct implementation for Task 2_

## Files Created/Modified

- `lib/features/cart/presentation/providers/cart_comparison_provider.dart` - CartMarketResult + CartProductRow models + cartComparisonProvider FutureProvider (117 lines)
- `lib/features/cart/presentation/providers/cart_notifier.dart` - Restored from Plan 01 commits (57 lines)
- `lib/features/cart/widgets/cart_app_bar_icon.dart` - ConsumerWidget with badge and Tooltip (57 lines)
- `lib/features/cart/widgets/cart_product_list_section.dart` - Cart product list with remove buttons and semantics (70 lines)
- `lib/features/cart/widgets/cart_market_comparison_card.dart` - Expandable market card with En Uygun badge (162 lines)
- `lib/features/cart/cart_comparison_page.dart` - Full comparison page (142 lines)
- `test/features/cart/presentation/providers/cart_comparison_provider_test.dart` - 8 unit tests for aggregation logic (175 lines)
- `test/features/cart/presentation/providers/cart_notifier_test.dart` - 8 unit tests restored from Plan 01 (167 lines)
- `lib/features/products/product_detail_page.dart` - Added CartAppBarIcon to AppBar, Sepete Ekle/Sepetten Cikar Consumer with snackbar
- `lib/features/products/products_page.dart` - Added CartAppBarIcon to AppBar actions

## Decisions Made

- `await cartNotifierProvider.future` before reading `cartComparisonProvider` in tests — when a `FutureProvider` uses `ref.watch` on an `AsyncNotifierProvider`, the notifier must be in `AsyncData` state before the FutureProvider executes its body, otherwise the `container.read(cartComparisonProvider.future)` call hangs until container disposal (2-minute timeout in test runner)
- `CartMarketResult` as plain Dart class (not Freezed) — no serialization needed, plain constructor is simpler for the `isCheapest` copy mutation pattern where we rebuild one result with `isCheapest: true`
- 0-match markets sorted to bottom — per research Open Question 2, displaying 0.00 TL at the top of the sorted list would falsely appear as cheapest to users scanning prices

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Restored cart_notifier.dart and cart_notifier_test.dart from orphaned commits**
- **Found during:** Task 1 setup
- **Issue:** Plan 01 committed `cart_notifier.dart` and its tests to commits `9e9649a`/`787baaa` which were NOT in the ancestry of `worktree-agent-a02c13cb` branch (Plan 01 was executed on a different worktree). The `lib/features/cart/` directory was entirely absent in the current worktree.
- **Fix:** Used `git show {commit}:{path} >` to extract files from the orphaned commits and placed them in the worktree at their correct paths
- **Files modified:** lib/features/cart/presentation/providers/cart_notifier.dart, test/features/cart/presentation/providers/cart_notifier_test.dart
- **Verification:** All 8 cart_notifier tests pass
- **Committed in:** `79adfc0` (RED phase commit includes these restored files)

**2. [Rule 1 - Bug] Fixed FutureProvider test deadlock when watching AsyncNotifierProvider**
- **Found during:** Task 1 GREEN phase verification
- **Issue:** `container.read(cartComparisonProvider.future)` timed out (2+ minutes) because `ref.watch(cartNotifierProvider)` inside the FutureProvider body executed before the AsyncNotifier was initialized, leaving the FutureProvider suspended indefinitely
- **Fix:** Changed `_makeContainer` to `async` and added `await container.read(cartNotifierProvider.future)` before returning the container, ensuring the cart notifier is in `AsyncData` state when `cartComparisonProvider` reads it
- **Files modified:** test/features/cart/presentation/providers/cart_comparison_provider_test.dart
- **Verification:** All 8 comparison tests pass in <1 second
- **Committed in:** `a87a4c8` (GREEN phase commit)

---

**Total deviations:** 2 auto-fixed (1 blocking/missing-file, 1 bug/test-deadlock)
**Impact on plan:** Both fixes necessary for compilation and test correctness. No scope creep.

## Issues Encountered

- cart_notifier.dart was absent in worktree because Plan 01 was executed in a different worktree whose commits were orphaned from this worktree's branch. Resolved by extracting files from git object store.
- FutureProvider + AsyncNotifier test deadlock: documented as established pattern for future TDD in this codebase.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Complete COMP-03 cart comparison user flow is implemented and tested
- CartComparisonPage accessible from ProductsPage and ProductDetailPage
- cartComparisonProvider ready for consumption by any future feature that needs cart aggregation
- All 90 tests green, no regressions introduced
- Phase 04 UAT ready: both plans complete

---
*Phase: 04-cart-comparison*
*Completed: 2026-03-30*
