---
phase: 02-data-layer
plan: 03
subsystem: api
tags: [flutter, riverpod, dio, datasource, remote, mock]

# Dependency graph
requires:
  - phase: 02-data-layer-02
    provides: Remote datasource implementations with Dio/ApiClient and getProductsByMarket endpoint
  - phase: 02-data-layer-01
    provides: ProductItem with priceHistory, DiscountItem with DateTime validUntil, ApiClient error handling
provides:
  - All three feature datasource providers wired to RemoteDataSourceImpl in production code
  - productsByMarketProvider calls repository.getProductsByMarket() via dedicated API call
  - api_client_provider.dart uses real-format base URL api.fiyatcep.com (no more example.com)
affects: [03-price-comparison, 04-notifications, testing]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Widget tests override productRepositoryProvider with mock via ProviderScope.overrides when production wiring is remote"

key-files:
  created: []
  modified:
    - lib/shared/providers/api_client_provider.dart
    - lib/shared/providers/repository_providers.dart
    - lib/features/products/presentation/providers/products_provider.dart
    - test/features/products/presentation/pages/products_page_test.dart

key-decisions:
  - "Widget tests must use ProviderScope.overrides to inject mock repository — global provider wiring is now remote, not mock"

patterns-established:
  - "Production wiring: all datasource providers get apiClient from ref.watch(apiClientProvider) and pass to *RemoteDataSourceImpl"
  - "Test isolation: widget tests override productRepositoryProvider with ProductRepositoryImpl(remoteDataSource: ProductMockDataSourceImpl())"

requirements-completed: [DATA-02, MKTD-02]

# Metrics
duration: 2min
completed: 2026-03-28
---

# Phase 02 Plan 03: Remote Datasource Wiring Summary

**All three datasource providers swapped from mock to RemoteDataSourceImpl via apiClientProvider; productsByMarketProvider calls repository.getProductsByMarket() directly instead of in-memory filtering**

## Performance

- **Duration:** 2 min
- **Started:** 2026-03-28T13:18:07Z
- **Completed:** 2026-03-28T13:20:08Z
- **Tasks:** 1
- **Files modified:** 4

## Accomplishments

- `repository_providers.dart` now wires all three datasource providers to `*RemoteDataSourceImpl(apiClient: apiClient)` — mock imports removed
- `api_client_provider.dart` uses `https://api.fiyatcep.com/api/v1` as base URL — no TODO, no example.com
- `productsByMarketProvider` calls `repository.getProductsByMarket(marketId)` following the same Result.when pattern as other providers

## Task Commits

1. **Task 1: Swap datasources to remote, update productsByMarketProvider** - `adb634e` (feat)

**Plan metadata:** (docs commit follows)

## Files Created/Modified

- `lib/shared/providers/api_client_provider.dart` - Base URL updated to api.fiyatcep.com, TODO removed
- `lib/shared/providers/repository_providers.dart` - All three datasources wired to RemoteDataSourceImpl with apiClient; mock imports removed
- `lib/features/products/presentation/providers/products_provider.dart` - productsByMarketProvider uses repository.getProductsByMarket() directly
- `test/features/products/presentation/pages/products_page_test.dart` - Widget tests override productRepositoryProvider with mock repository

## Decisions Made

- Widget tests that previously relied on global mock wiring now use `ProviderScope.overrides` to inject `ProductRepositoryImpl(remoteDataSource: ProductMockDataSourceImpl())` — this is the correct pattern for all future widget tests.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Widget test `products_page_test.dart` broke after global mock-to-remote swap**
- **Found during:** Task 1 verification (`flutter test`)
- **Issue:** `products_page_test.dart` used bare `ProviderScope` without overrides; after production wiring switched to remote, providers attempted real HTTP calls, returning no data — "Makarna 500g" and "Un 1kg" not found
- **Fix:** Added `ProviderScope.overrides` in all four test widgets, overriding `productRepositoryProvider` with `ProductRepositoryImpl(remoteDataSource: ProductMockDataSourceImpl())`; renamed local `_buildWithMock` to `buildWithMock` per linter; removed unused `product_repository.dart` import
- **Files modified:** `test/features/products/presentation/pages/products_page_test.dart`
- **Verification:** `flutter test` exits 0 (71 tests pass)
- **Committed in:** `adb634e` (Task 1 commit)

---

**Total deviations:** 1 auto-fixed (Rule 1 - bug)
**Impact on plan:** The fix is required for test correctness. No scope creep — mock files remain in codebase for test use per plan decision D-15.

## Issues Encountered

None beyond the widget test fix above.

## User Setup Required

**Backend URL must be updated before production use.** The base URL `https://api.fiyatcep.com/api/v1` in `lib/shared/providers/api_client_provider.dart` is a real-format placeholder. Update it to the actual backend deployment URL when the scraping service is deployed.

## Next Phase Readiness

- Flutter app is fully wired to remote backend — ready to connect to real scraping API when deployed
- All 71 tests pass; mock datasources remain available for test overrides
- Blocker: Backend scraping service must be deployed and URL updated before end-to-end data flow is testable

## Self-Check: PASSED

All key files exist. Commit adb634e verified in git log.

---
*Phase: 02-data-layer*
*Completed: 2026-03-28*
