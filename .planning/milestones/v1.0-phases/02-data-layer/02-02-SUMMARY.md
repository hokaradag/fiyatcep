---
phase: 02-data-layer
plan: 02
subsystem: data-layer
tags: [api, error-handling, products, repository, datasource]
dependency_graph:
  requires: ["02-01"]
  provides: ["error-envelope-parsing", "getProductsByMarket"]
  affects: ["lib/core/network/api_client.dart", "lib/features/products/**", "lib/features/markets/data/datasources/market_remote_datasource.dart", "lib/features/discounts/data/datasources/discount_remote_datasource.dart"]
tech_stack:
  added: []
  patterns: ["error-envelope-extraction", "queryParameters-market-filter"]
key_files:
  created: []
  modified:
    - lib/core/network/api_client.dart
    - lib/features/products/data/datasources/product_datasource.dart
    - lib/features/products/data/datasources/product_remote_datasource.dart
    - lib/features/products/data/datasources/product_mock_datasource.dart
    - lib/features/markets/data/datasources/market_remote_datasource.dart
    - lib/features/discounts/data/datasources/discount_remote_datasource.dart
    - lib/features/products/domain/repositories/product_repository.dart
    - lib/features/products/data/repositories/product_repository_impl.dart
    - test/features/products/data/repositories/product_repository_test.dart
decisions:
  - "Error envelope extraction placed before status-code branch to avoid repeating body/errorObj locals in each branch"
  - "Backward-compat fallback to body['message'] preserved so non-conforming responses still produce readable errors"
  - "getProductsByMarket added only to ProductRemoteDataSource, not ProductLocalDataSource — market-filtered lists are always fetched live"
  - "Mock impl filters getAllProducts() in-memory by marketId — no separate mock data set needed"
metrics:
  duration: "3 min"
  completed_date: "2026-03-28"
  tasks_completed: 2
  files_modified: 9
---

# Phase 02 Plan 02: API Error Envelope Parsing + getProductsByMarket Summary

Updated error response parsing to match new API envelope shape `{error:{code,message}}` in all 4 locations (ApiClient + 3 remote datasources), and wired `getProductsByMarket(marketId)` from abstract datasource through repository impl with a passing test.

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Update error response parsing in ApiClient and all remote datasources | 7e11398 | api_client.dart, product_remote_datasource.dart, market_remote_datasource.dart, discount_remote_datasource.dart |
| 2 | Add getProductsByMarket across abstract, remote, mock, repository interface, repository impl | 558fbda | product_datasource.dart, product_remote_datasource.dart, product_mock_datasource.dart, product_repository.dart, product_repository_impl.dart, product_repository_test.dart |

## Verification

- `flutter test` passed: 71 tests (70 pre-existing + 1 new `getProductsByMarket` test)
- All acceptance criteria met for both tasks

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed double-underscore lint warning in test**
- **Found during:** Task 2 (IDE diagnostic on commit)
- **Issue:** `failure: (_, __) => fail(...)` triggered "Unnecessary use of multiple underscores" lint
- **Fix:** Changed `__` to `_` — Dart allows duplicate `_` wildcards in modern versions but the linter flagged it
- **Files modified:** test/features/products/data/repositories/product_repository_test.dart
- **Commit:** 558fbda (included in task commit)

## Known Stubs

None — no UI-facing stubs introduced. `getProductsByMarket` is wired end-to-end through the data layer; the presentation layer will consume it in a future plan (MKTD-02).

## Self-Check: PASSED

All key files present. Both task commits verified in git log.
