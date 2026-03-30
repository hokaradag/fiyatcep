---
phase: 04-cart-comparison
plan: 01
subsystem: state-management
tags: [riverpod, shared-preferences, async-notifier, cart, tdd]

# Dependency graph
requires:
  - phase: 01-quality-foundation
    provides: FavoritesNotifier AsyncNotifier pattern and test infrastructure to clone
  - phase: 02-data-layer
    provides: ProductItem Freezed model with id, marketId, priceHistory fields
provides:
  - CartNotifier AsyncNotifier with add/remove/clear/isInCart and SharedPreferences persistence
  - cartNotifierProvider for cart state consumption in Plan 02 cart UI
affects: [04-02-cart-ui, any feature consuming cartNotifierProvider]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Id-based dedup in CartNotifier uses p.id == product.id (not Freezed equality) — safe for objects with List<PricePoint> that breaks value equality"
    - "AsyncNotifier build() reads SharedPreferences for hydration; _save() writes on every mutation"
    - "TDD RED/GREEN cycle: test file committed before implementation"

key-files:
  created:
    - lib/features/cart/presentation/providers/cart_notifier.dart
    - test/features/cart/presentation/providers/cart_notifier_test.dart
  modified: []

key-decisions:
  - "Id-based dedup (p.id == product.id) chosen over Freezed equality — Freezed equality on ProductItem compares all fields including priceHistory List, making same-product dedup fragile if price changes before re-add"
  - "No toggle() method on CartNotifier — add/remove are asymmetric operations in cart UX (user explicitly adds to cart, explicitly removes from cart)"
  - "SharedPreferences key 'cart_products' mirrors 'favorite_products' key naming pattern"

patterns-established:
  - "CartNotifier: clone FavoritesNotifier with id-based equality for all comparisons"
  - "Cart test pattern: SharedPreferences.setMockInitialValues({}) in setUp, ProviderContainer per test with addTearDown"

requirements-completed: [COMP-03]

# Metrics
duration: 10min
completed: 2026-03-30
---

# Phase 4 Plan 01: CartNotifier Provider Summary

**CartNotifier AsyncNotifier<List<ProductItem>> with id-based dedup, add/remove/clear/isInCart, and SharedPreferences persistence to 'cart_products' key**

## Performance

- **Duration:** 10 min
- **Started:** 2026-03-30T10:21:04Z
- **Completed:** 2026-03-30T10:31:00Z
- **Tasks:** 2 (TDD: RED + GREEN)
- **Files modified:** 2

## Accomplishments

- CartNotifier AsyncNotifier that mirrors FavoritesNotifier pattern with id-based equality instead of Freezed equality
- 8 unit tests covering build/add/remove/clear/dedup-by-id/isInCart/persistence — all passing
- Full test suite still green (82 tests, 0 failures) — no regressions

## Task Commits

Each task was committed atomically:

1. **Task 1: Create CartNotifier unit test suite (RED phase)** - `787baaa` (test)
2. **Task 2: Implement CartNotifier provider (GREEN phase)** - `9e9649a` (feat)

**Plan metadata:** (docs commit follows)

_Note: TDD tasks committed as RED (test) then GREEN (implementation)_

## Files Created/Modified

- `lib/features/cart/presentation/providers/cart_notifier.dart` - CartNotifier + cartNotifierProvider (57 lines)
- `test/features/cart/presentation/providers/cart_notifier_test.dart` - 8 unit tests (167 lines)

## Decisions Made

- Id-based dedup (`p.id == product.id`) chosen over Freezed equality — Freezed equality compares all fields including `List<PricePoint> priceHistory`, making dedup fragile when price data differs between two lookups of the same product
- No `toggle()` method — cart has semantically asymmetric operations (explicit add vs explicit remove), unlike favorites where toggle is the primary UX verb
- SharedPreferences key `'cart_products'` follows established `'favorite_products'` naming pattern

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None — pattern was well-established from FavoritesNotifier. Flutter test runner required `Developer Mode` warning on Windows but tests ran correctly.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- `cartNotifierProvider` is ready for consumption in Plan 02 (cart UI)
- `CartNotifier.add()`, `.remove()`, `.clear()`, `.isInCart()` are all tested and functional
- No blockers for Plan 02

---
*Phase: 04-cart-comparison*
*Completed: 2026-03-30*
