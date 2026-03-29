---
phase: 03-price-comparison-market-detail
plan: 02
subsystem: ui
tags: [flutter, fl_chart, price-comparison, price-history, line-chart, market-prices]

# Dependency graph
requires:
  - phase: 03-price-comparison-market-detail/03-01
    provides: fl_chart ^0.69.0 installed, PricePoint.displayDate getter, Wave 0 stub tests
  - phase: 02-data-layer
    provides: ProductItem with priceHistory field, PricePoint model, MarketPriceItem model
provides:
  - Price diff label (+X.XX TL in grey) on non-cheapest market rows in ProductPriceSection
  - ProductPriceHistorySection widget with fl_chart LineChart and 4-tab time range selector
  - ProductDetailPage wired to show price history chart where placeholder text was
affects:
  - 03-03 (market detail header — no dependency on these widgets)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - StatefulWidget for time range selector state — avoids lifting state to page level for local UI concerns
    - filteredPoints used for both FlSpot generation and tooltip index lookup — avoids spotIndex mismatch when chart data is a subset of the full list
    - SizedBox(height: 200) wrapping LineChart — prevents unbounded height constraint error in Column

key-files:
  created:
    - lib/features/products/widgets/product_price_history_section.dart
  modified:
    - lib/features/products/widgets/product_price_section.dart
    - lib/features/products/product_detail_page.dart

key-decisions:
  - "filteredPoints reused for tooltip lookup — avoids index mismatch if only a date-range subset of priceHistory is charted"
  - "Disabled tabs use onTap: null not just grey color — satisfies UI-SPEC D-09 interaction contract and prevents ghost taps"
  - "TimeRange enum defined in same file as widget — no shared usage across features, keeping it co-located avoids premature abstraction"

patterns-established:
  - "Price diff calculation: (item.price - prices.first.price).toStringAsFixed(2) — prices list is sorted cheapest-first by provider"
  - "Chart always in SizedBox(height: 200) — required for fl_chart 0.69 in unbounded Column"

requirements-completed: [COMP-01, COMP-02]

# Metrics
duration: 2min
completed: 2026-03-29
---

# Phase 03 Plan 02: Price Comparison + History Chart Summary

**fl_chart LineChart price history widget with 1H/1A/3A/1Y range selector, touch tooltips, and +X.XX TL diff labels on non-cheapest market rows — both wired into ProductDetailPage**

## Performance

- **Duration:** 2 min
- **Started:** 2026-03-29T09:39:57Z
- **Completed:** 2026-03-29T09:41:56Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments

- ProductPriceSection now shows "+X.XX TL" diff label in muted grey on every non-cheapest market row, using prices.first.price (cheapest-first sort) as the baseline
- ProductPriceHistorySection created with full fl_chart LineChart, 4 time range tabs (1H/1A/3A/1Y), disabled tab handling, empty state message, and touch tooltips showing price + Turkish date
- ProductDetailPage placeholder text ("Bu alan ileride...") replaced with ProductPriceHistorySection wired to product.priceHistory

## Task Commits

Each task was committed atomically:

1. **Task 1: Add price diff label and build ProductPriceHistorySection** - `5ca1946` (feat)
2. **Task 2: Wire ProductPriceHistorySection into ProductDetailPage** - `a0f732f` (feat)

**Plan metadata:** _(to be committed next)_

## Files Created/Modified

- `lib/features/products/widgets/product_price_section.dart` - Added if (!isCheapest) diff label block after isDiscounted badge
- `lib/features/products/widgets/product_price_history_section.dart` - New StatefulWidget with LineChart, TimeRange enum, time range selector, empty state, touch tooltips
- `lib/features/products/product_detail_page.dart` - Added import, replaced placeholder text block with ProductPriceHistorySection

## Decisions Made

- filteredPoints list is reused for both FlSpot x-index generation and tooltip spotIndex lookup — if spots were built from the full priceHistory but tooltip used filteredPoints, the index would be off
- Disabled tabs use `onTap: null` not just visual greying — ensures GestureDetector does not fire, matching UI-SPEC D-09 interaction contract
- TimeRange enum co-located in product_price_history_section.dart — no cross-feature usage expected, separate file would add no isolation benefit

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None. The IDE warning "unused import" on product_price_history_section.dart appeared after adding the import before replacing the placeholder text — resolved immediately when the placeholder was replaced in the same editing session.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- COMP-01 and COMP-02 are complete: price diff labels and price history chart both ship in ProductDetailPage
- Plan 03 (market detail header branding) is independent of these widgets and can proceed
- Mock priceHistory data in mock_market_prices.dart contains data points across multiple time ranges — chart tabs will show real filtering behavior in the simulator

---
*Phase: 03-price-comparison-market-detail*
*Completed: 2026-03-29*
