---
phase: quick
plan: 260329-ogy
subsystem: data
tags: [mock, datasources, uat, phase3]
key-files:
  modified:
    - lib/shared/providers/repository_providers.dart
decisions:
  - Repository providers now instantiate MockDataSourceImpl directly — remote providers retained as dormant dead code with UAT comment
metrics:
  duration: 5min
  completed: 2026-03-29
---

# Quick Task 260329-ogy: Restore Mock Datasources for Phase 3 UAT Summary

**One-liner:** Rewired all three repository providers to use MockDataSourceImpl so Phase 3 UAT proceeds without a live backend, while remote datasource providers remain intact for easy reactivation.

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Wire mock datasources in repository_providers.dart | 35ba4e3 | lib/shared/providers/repository_providers.dart |
| 2 | Run full analyze and tests, then commit | 35ba4e3 | (analyze + test only) |

## Changes

`lib/shared/providers/repository_providers.dart`:
- Added imports for `product_mock_datasource.dart`, `market_mock_datasource.dart`, `discount_mock_datasource.dart`
- `productRepositoryProvider` now uses `ProductMockDataSourceImpl()` directly
- `marketRepositoryProvider` now uses `MarketMockDataSourceImpl()` directly
- `discountRepositoryProvider` now uses `DiscountMockDataSourceImpl()` directly
- Remote datasource providers (`productRemoteDataSourceProvider`, `marketRemoteDataSourceProvider`, `discountRemoteDataSourceProvider`) retained with UAT comment

## Verification

- `grep MockDataSourceImpl`: 3 matches (one per feature)
- `grep RemoteDataSourceImpl`: 3 matches (remote providers retained)
- `flutter analyze`: No issues
- `flutter test`: 74/74 tests passed

## Deviations from Plan

None — plan executed exactly as written.

## Self-Check: PASSED
