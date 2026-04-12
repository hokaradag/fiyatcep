---
phase: 01-quality-foundation
plan: 01
subsystem: ui
tags: [dart, flutter, text-normalization, error-handling, riverpod]

# Dependency graph
requires: []
provides:
  - TextNormalizer utility class for centralized Turkish text normalization
  - Typed AppException error propagation in all feature providers
  - Consistent CarrefourSA brand naming across all mock datasources
affects: [02-quality-foundation, data-layer, market-detail, product-search]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - TextNormalizer.normalize() as the single source of Turkish character normalization (ç->c, ğ->g, ı->i, ö->o, ş->s, ü->u)
    - Provider failure branches throw AppException(message, code) instead of raw Exception(message)
    - Loading branches throw StateError as dead-code safety guard

key-files:
  created:
    - lib/core/utils/text_normalizer.dart
  modified:
    - lib/features/products/data/datasources/product_mock_datasource.dart
    - lib/features/markets/data/datasources/market_mock_datasource.dart
    - lib/features/discounts/data/datasources/discount_mock_datasource.dart
    - lib/features/markets/widgets/market_card.dart
    - lib/features/products/presentation/providers/products_provider.dart
    - lib/features/markets/presentation/providers/markets_provider.dart
    - lib/features/discounts/presentation/providers/discounts_provider.dart

key-decisions:
  - "TextNormalizer is a pure static utility class with no state — no new dependencies required"
  - "switch-case strings like 'carrefoursa' in market_card.dart are the correct normalized form and remain unchanged"
  - "StateError used for loading branch as it is unreachable dead code — clearer intent than Exception('Loading')"

patterns-established:
  - "Turkish normalization: always call TextNormalizer.normalize() — never write inline replaceAll chains"
  - "Provider error: always throw AppException(message: message, code: code) from failure branch"

requirements-completed: [QUAL-01, QUAL-02, QUAL-07]

# Metrics
duration: 2min
completed: 2026-03-27
---

# Phase 01 Plan 01: Quality Foundation — TextNormalizer + Typed Errors Summary

**Centralized Turkish text normalization via TextNormalizer utility, CarrefourSA brand name fixed in all mock datasources, and typed AppException error propagation in 9 provider failure branches**

## Performance

- **Duration:** 2 min
- **Started:** 2026-03-27T19:08:32Z
- **Completed:** 2026-03-27T19:11:15Z
- **Tasks:** 2
- **Files modified:** 7 (1 created, 6 modified)

## Accomplishments

- Created `lib/core/utils/text_normalizer.dart` with static `normalize()` method — single source of truth for Turkish character normalization across the codebase
- Replaced 4 private `_normalizeText`/`_normalizeName` method copies (in 3 datasources + 1 widget) with `TextNormalizer.normalize()` calls
- Fixed `'Carrefoursa'` -> `'CarrefourSA'` in product, market, and discount mock datasources (switch-case strings preserved as correct post-normalization form)
- Replaced 9 raw `throw Exception(message)` calls in provider failure branches with `throw AppException(message: message, code: code)` — UI error handlers now receive typed exceptions with meaningful messages

## Task Commits

Each task was committed atomically:

1. **Task 1: Extract TextNormalizer utility and normalize CarrefourSA naming** - `f6d9ec3` (feat)
2. **Task 2: Fix typed error propagation in all providers** - `036b781` (fix)

## Files Created/Modified

- `lib/core/utils/text_normalizer.dart` — New utility class with static normalize() for Turkish character folding
- `lib/features/products/data/datasources/product_mock_datasource.dart` — TextNormalizer import, _normalizeText removed, CarrefourSA fixed
- `lib/features/markets/data/datasources/market_mock_datasource.dart` — TextNormalizer import, _normalizeText removed, CarrefourSA fixed
- `lib/features/discounts/data/datasources/discount_mock_datasource.dart` — TextNormalizer import, _normalizeText removed, CarrefourSA fixed
- `lib/features/markets/widgets/market_card.dart` — TextNormalizer import, _normalizeName removed
- `lib/features/products/presentation/providers/products_provider.dart` — AppException import, 3 failure branches + 3 loading branches updated
- `lib/features/markets/presentation/providers/markets_provider.dart` — AppException import, 3 failure branches + 3 loading branches updated
- `lib/features/discounts/presentation/providers/discounts_provider.dart` — AppException import, 3 failure branches + 3 loading branches updated

## Decisions Made

- `TextNormalizer` is a pure static class with no state, requiring no dependency injection and no new pub dependencies
- The switch-case strings (`'carrefoursa'`, `'bim'`, etc.) in `market_card.dart` are the correct output of `TextNormalizer.normalize()` applied to display names — they are intentionally lowercase and remain unchanged
- `StateError('Unexpected loading state in provider')` used for loading branches since repositories never return `LoadingResult` — clearer intent than `Exception('Loading')`

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- TextNormalizer is ready for use by any new search/filter code added in future plans
- Provider error propagation is correct — UI `.when(error: (e, st) => ...)` handlers can now cast to `AppException` and display `e.message` meaningfully
- No blockers for Plan 02 (widget decomposition) or Plan 03 (unit tests)

---
*Phase: 01-quality-foundation*
*Completed: 2026-03-27*
