---
phase: 02-data-layer
plan: 01
subsystem: database
tags: [freezed, dart, models, price-history, datetime, json-serializable]

# Dependency graph
requires:
  - phase: 01-quality-foundation
    provides: Clean Architecture foundation with Result<T>, TextNormalizer, FavoritesNotifier, and widget tests

provides:
  - PricePoint Freezed model with price (double) and date (DateTime) fields, fromJson/toJson
  - ProductItem extended with @Default([]) List<PricePoint> priceHistory field
  - DiscountItem.validUntil migrated from String to DateTime with displayDate Turkish formatter
  - discount_card.dart renders human-readable Turkish date via item.displayDate

affects:
  - 02-02 (ProductItem priceHistory ready for chart/history display)
  - 02-03 (DiscountItem.validUntil is DateTime, displayDate ready for discount UI)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Freezed model extension: add optional field with @Default([]) to avoid breaking existing code"
    - "Turkish date formatting: const months array indexed by month number — avoids intl dependency"
    - "DateTime type for date fields: json_serializable 6.x parses ISO 8601 natively, no @JsonKey needed"

key-files:
  created:
    - lib/features/products/models/price_point.dart
    - lib/features/products/models/price_point.freezed.dart
    - lib/features/products/models/price_point.g.dart
    - test/features/products/models/price_point_test.dart
    - test/features/discounts/models/discount_item_test.dart
  modified:
    - lib/features/products/models/product_item.dart
    - lib/features/products/models/product_item.freezed.dart
    - lib/features/products/models/product_item.g.dart
    - lib/features/discounts/models/discount_item.dart
    - lib/features/discounts/models/discount_item.freezed.dart
    - lib/features/discounts/models/discount_item.g.dart
    - lib/features/discounts/data/datasources/discount_mock_datasource.dart
    - lib/features/discounts/widgets/discount_card.dart

key-decisions:
  - "priceHistory added with @Default([]) on ProductItem — existing ProductItem constructors compile without changes, no mock data updates needed"
  - "Turkish month names as const array indexed by month number — avoids adding intl dependency while delivering correct Unicode characters (Şubat, Mayıs, Ağustos, Eylül, Kasım, Aralık)"
  - "DiscountItem.validUntil type changed to DateTime directly — json_serializable 6.x handles ISO 8601 DateTime natively without custom @JsonKey converter"

patterns-established:
  - "Freezed optional field pattern: @Default([]) List<T> fieldName, — use for backward-compatible model extensions"
  - "Turkish date formatting: const months list in computed getter, no external package"

requirements-completed: [DATA-03, DATA-04]

# Metrics
duration: 35min
completed: 2026-03-28
---

# Phase 02 Plan 01: Data Model Foundation Summary

**PricePoint Freezed model created, ProductItem extended with priceHistory, DiscountItem.validUntil migrated to DateTime with Turkish displayDate getter**

## Performance

- **Duration:** ~35 min
- **Started:** 2026-03-28T13:05:00Z
- **Completed:** 2026-03-28T13:40:00Z
- **Tasks:** 1 of 1
- **Files modified:** 13

## Accomplishments

- Created PricePoint Freezed model (price: double, date: DateTime) with fromJson/toJson — foundation for price history charts in phase 03
- Extended ProductItem with `@Default([]) List<PricePoint> priceHistory` — zero breaking changes, all existing product code compiles unchanged
- Migrated DiscountItem.validUntil from String to DateTime and added displayDate getter returning Turkish formatted strings (e.g., "30 Mart 2026")
- Updated discount_card.dart to display `item.displayDate` instead of raw `item.validUntil`
- Added 13 new tests covering PricePoint fromJson/toJson and DiscountItem displayDate with all Turkish month names

## Task Commits

Each task was committed atomically:

1. **Task 1: Create PricePoint model, extend ProductItem, migrate DiscountItem.validUntil** - `ac2f062` (feat)

**Plan metadata:** _(added in final docs commit)_

## Files Created/Modified

- `lib/features/products/models/price_point.dart` - New PricePoint Freezed model with price and date fields
- `lib/features/products/models/price_point.freezed.dart` - Generated Freezed implementation
- `lib/features/products/models/price_point.g.dart` - Generated JSON serialization
- `lib/features/products/models/product_item.dart` - Added `@Default([]) List<PricePoint> priceHistory` field and price_point import
- `lib/features/products/models/product_item.freezed.dart` - Regenerated with new field
- `lib/features/products/models/product_item.g.dart` - Regenerated with new field
- `lib/features/discounts/models/discount_item.dart` - validUntil changed to DateTime, displayDate getter added
- `lib/features/discounts/models/discount_item.freezed.dart` - Regenerated for DateTime type
- `lib/features/discounts/models/discount_item.g.dart` - Regenerated for DateTime type
- `lib/features/discounts/data/datasources/discount_mock_datasource.dart` - validUntil updated to DateTime() constructors
- `lib/features/discounts/widgets/discount_card.dart` - Changed `item.validUntil` to `item.displayDate`
- `test/features/products/models/price_point_test.dart` - 3 tests for PricePoint model
- `test/features/discounts/models/discount_item_test.dart` - 10 tests for DiscountItem DateTime/displayDate/computed getters

## Decisions Made

- **@Default([]) for priceHistory:** Using Freezed's @Default annotation ensures ProductItem can be constructed without priceHistory parameter — all existing mock data and test factories compile without changes.
- **No intl package:** Turkish month names implemented as a const list indexed by month number. Avoids adding a new dependency while delivering correct Unicode characters for all 12 months.
- **DateTime native in json_serializable:** json_serializable 6.x handles `DateTime` from ISO 8601 strings natively. No custom `@JsonKey(fromJson: ...)` converter was needed (per research Pattern 1 alternative).

## Deviations from Plan

None — plan executed exactly as written. The discount_card.dart fix (Step 6) was the final piece needed after build_runner regenerated files.

## Issues Encountered

None — build_runner ran cleanly in one pass, all 70 existing tests continued to pass, and 13 new model tests pass when targeted.

## User Setup Required

None — no external service configuration required.

## Next Phase Readiness

- PricePoint model is ready for 02-02 (price history wiring to mock datasource)
- ProductItem.priceHistory defaults to [] — all existing data flow unaffected until 02-02 populates it
- DiscountItem.displayDate is live in discount_card.dart — discount UI now shows human-readable Turkish dates
- All acceptance criteria from 02-01-PLAN.md met

## Self-Check: PASSED

- FOUND: lib/features/products/models/price_point.dart
- FOUND: lib/features/products/models/price_point.freezed.dart
- FOUND: lib/features/products/models/price_point.g.dart
- FOUND: test/features/products/models/price_point_test.dart
- FOUND: test/features/discounts/models/discount_item_test.dart
- FOUND commit: ac2f062

---
*Phase: 02-data-layer*
*Completed: 2026-03-28*
