---
phase: 05-fcm-push-notifications
plan: 03
subsystem: ui
tags: [flutter, fcm, firebase, watch, notifications, riverpod, dio]

requires:
  - phase: 05-01-fcm-sdk-setup
    provides: FCM token provider, notification handlers, navigatorKey
  - phase: 05-02-watch-notifier-backend
    provides: WatchNotifier with SharedPreferences persistence, POST /notifications/subscribe backend endpoint

provides:
  - Watch button (Takip Et / Takibi Birak) on product detail page
  - Backend sync on watch list change via POST /notifications/subscribe
  - FCM token refresh triggers re-sync of watch list to backend
  - apiBaseUrl constant extracted as shared source of truth

affects:
  - Any feature adding product detail page actions
  - Backend notifications endpoint consumers

tech-stack:
  added: []
  patterns:
    - Consumer widget wrapping ElevatedButton.icon for reactive watch state toggle
    - Best-effort backend sync pattern (try-catch silently ignores network failures, non-blocking)
    - apiBaseUrl constant in api_client_provider.dart as single source of truth for base URL
    - Direct Dio call in listenForTokenRefresh (outside Riverpod context) reuses apiBaseUrl constant

key-files:
  created: []
  modified:
    - lib/features/products/product_detail_page.dart
    - lib/features/watch/presentation/providers/watch_notifier.dart
    - lib/shared/providers/fcm_token_provider.dart
    - lib/shared/providers/api_client_provider.dart

key-decisions:
  - "apiBaseUrl extracted as top-level constant in api_client_provider.dart — avoids URL duplication between Riverpod provider and listenForTokenRefresh outside-context Dio call"
  - "Best-effort sync in _syncWithBackend and listenForTokenRefresh — transient network failures must not block watch toggle user action"
  - "Watch button placed after cart button in product detail page Column — follows existing Favorilere Ekle / Sepete Ekle layout order"
  - "discounts_page tap navigates to ProductDetailPage — no separate discount watch button needed, single implementation covers both use cases"

patterns-established:
  - "Best-effort backend sync: wrap in try-catch, silently ignore errors, user action never blocked by network failure"
  - "Outside-Riverpod-context HTTP: import shared constant (apiBaseUrl) and create direct Dio instance rather than hardcoding URL"
  - "Consumer + ElevatedButton.icon pattern for reactive toggle buttons mirroring favorites button"

requirements-completed: [NOTIF-02, NOTIF-03]

duration: 35min
completed: 2026-04-12
---

# Phase 05 Plan 03: Watch UI Buttons and Backend Sync Summary

**Watch button (Takip Et/Takibi Birak) wired to product detail page with best-effort POST /notifications/subscribe backend sync on each toggle and FCM token refresh**

## Performance

- **Duration:** ~35 min
- **Started:** 2026-04-12T00:00:00Z
- **Completed:** 2026-04-12
- **Tasks:** 3 (2 auto + 1 human-verify)
- **Files modified:** 4

## Accomplishments

- Extracted `apiBaseUrl` constant in `api_client_provider.dart` — single source of truth for base URL used by both Riverpod provider and outside-context token refresh
- Added `_syncWithBackend(WatchList)` to `WatchNotifier` — called after every `toggleProduct` / `toggleDiscount`, reads FCM token from SharedPreferences and POSTs to `/notifications/subscribe`
- Updated `listenForTokenRefresh` to re-sync watched IDs with new FCM token on token rotation
- Added Takip Et / Takibi Birak toggle button to product detail page with SnackBar feedback and live watch state from `watchNotifierProvider`
- User approved end-to-end verification of complete FCM push notification flow

## Task Commits

1. **Task 1: Wire backend sync into WatchNotifier and FCM token refresh** - `588f0cb` (feat)
2. **Task 2: Add watch button to product detail page** - `d955d2c` (feat)
3. **Task 3: Verify complete FCM push notification flow** - Human-verify checkpoint (user approved)

## Files Created/Modified

- `lib/shared/providers/api_client_provider.dart` - Added `const String apiBaseUrl` constant; provider uses constant instead of inline string
- `lib/features/watch/presentation/providers/watch_notifier.dart` - Added `_syncWithBackend()` method, calls after each toggle; imports api_client_provider and shared_preferences
- `lib/shared/providers/fcm_token_provider.dart` - Updated `listenForTokenRefresh` to re-sync watch list with new token; uses `apiBaseUrl` constant via direct Dio call
- `lib/features/products/product_detail_page.dart` - Added Consumer/ElevatedButton.icon watch toggle after cart button

## Decisions Made

- `apiBaseUrl` extracted as top-level constant in `api_client_provider.dart` — avoids URL duplication between Riverpod provider and `listenForTokenRefresh` which runs outside Riverpod context
- Best-effort sync pattern throughout — try-catch silently ignores errors, preventing network failures from blocking watch toggle user action (per decision D-05)
- Watch button placed after cart button in product detail page Column — follows existing Favorilere Ekle / Sepete Ekle layout order
- No separate discount watch button needed — `discounts_page` tap navigates to `ProductDetailPage`, single implementation covers both product and discount watch scenarios

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

**External services require manual configuration.** See [05-USER-SETUP.md](./05-USER-SETUP.md) for:
- `google-services.json` placement in `android/app/`
- Firebase service account JSON for backend
- `GOOGLE_APPLICATION_CREDENTIALS` environment variable

## Next Phase Readiness

- Complete FCM push notification loop is functional: user taps "Takip Et" -> WatchNotifier updates -> backend receives subscription with FCM token -> backend sends push on price drop -> tap navigates to product detail
- All NOTIF-01, NOTIF-02, NOTIF-03 requirements are complete
- Phase 5 is the final phase — project is ready for demo/beta deployment
- Physical device testing requires updating `apiBaseUrl` from `10.0.2.2` (Android emulator) to LAN IP

---
*Phase: 05-fcm-push-notifications*
*Completed: 2026-04-12*
