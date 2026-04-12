---
phase: 03-price-comparison-market-detail
plan: 05
subsystem: mock-data
tags: [bug-fix, mock-data, market-ids, brand-colors]
dependency_graph:
  requires: []
  provides: [slug-market-ids-in-all-mock-data]
  affects: [market-detail-header-widget, product-market-filter, discount-market-filter]
tech_stack:
  added: []
  patterns: [slug-ID-as-primary-key]
key_files:
  created: []
  modified:
    - lib/features/markets/data/datasources/market_mock_datasource.dart
    - lib/features/markets/data/mock_markets.dart
    - lib/features/products/data/datasources/product_mock_datasource.dart
    - lib/features/products/data/mock_products.dart
    - lib/features/products/data/mock_market_prices.dart
    - lib/features/discounts/data/datasources/discount_mock_datasource.dart
    - lib/features/discounts/data/mock_discounts.dart
    - test/features/markets/data/repositories/market_repository_test.dart
    - test/features/discounts/data/repositories/discount_repository_test.dart
    - test/features/discounts/models/discount_item_test.dart
    - test/features/products/data/repositories/product_repository_test.dart
    - test/features/products/presentation/pages/product_detail_page_test.dart
    - test/features/favorites/presentation/providers/favorites_notifier_test.dart
decisions:
  - "Slug IDs (migros, a101, bim, sok, carrefoursa) replace numeric IDs (m1-m5) as primary keys — aligns mock data with marketBrands map keys in market_brand_config.dart"
metrics:
  duration: 5min
  completed_date: "2026-03-29"
  tasks_completed: 3
  files_modified: 13
---

# Phase 03 Plan 05: Market Brand Color ID Gap Closure Summary

**One-liner:** Replaced numeric mock market IDs (m1-m5) with brand-name slug IDs (migros, a101, bim, sok, carrefoursa) so `marketBrands[market.id]` lookup succeeds and renders correct brand colors on market detail page.

## What Was Built

The `MarketDetailHeaderWidget` performs `marketBrands[market.id]` to look up brand color configuration. The `marketBrands` map (in `market_brand_config.dart`) uses string keys `'migros'`, `'a101'`, `'bim'`, `'sok'`, `'carrefoursa'`. Mock market IDs were previously `'m1'`–`'m5'`, causing every lookup to return `null` and fall back to `Colors.grey.shade300` (banner) and `Colors.grey.shade600` (icon).

This plan surgically replaced all ID values across 7 mock data files and updated 6 test files to match.

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Update market mock data files with slug IDs | cef7c46 | market_mock_datasource.dart, mock_markets.dart |
| 2 | Update product and discount mock files with slug marketIds | e2d5e4d | product_mock_datasource.dart, mock_products.dart, mock_market_prices.dart, discount_mock_datasource.dart, mock_discounts.dart |
| 3 | Update tests to use slug IDs and run full test suite | 7b3e409 | 6 test files, all 74 tests pass |

## Verification Results

- `grep -rn "id: 'm[0-9]'" lib/features/markets/` — no matches
- `grep -rn "marketId: 'm[0-9]'" lib/` — no matches
- `grep -rn "'m[0-9]'" test/` — no matches
- `flutter analyze lib/` — No issues found
- `flutter test --no-pub` — 74 tests passed (0 failures)

## Deviations from Plan

None — plan executed exactly as written.

## Known Stubs

None — this plan resolved data wiring that was previously broken (stub-causing gap). The fix ensures `marketBrands[market.id]` returns a valid `MarketBrand` for all 5 markets, activating the brand color rendering path already implemented in Plans 02/03.

## Self-Check: PASSED

- [x] lib/features/markets/data/datasources/market_mock_datasource.dart — modified (verified)
- [x] lib/features/markets/data/mock_markets.dart — modified (verified)
- [x] lib/features/products/data/datasources/product_mock_datasource.dart — modified (verified)
- [x] lib/features/products/data/mock_products.dart — modified (verified)
- [x] lib/features/products/data/mock_market_prices.dart — modified (verified)
- [x] lib/features/discounts/data/datasources/discount_mock_datasource.dart — modified (verified)
- [x] lib/features/discounts/data/mock_discounts.dart — modified (verified)
- [x] 6 test files updated — verified
- [x] Commits cef7c46, e2d5e4d, 7b3e409 exist in git log
- [x] 74 tests pass with 0 failures
