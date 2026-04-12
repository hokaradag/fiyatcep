---
phase: 05-fcm-push-notifications
plan: 02
subsystem: watch-list + backend-notifications
tags: [flutter, riverpod, shared-preferences, fastapi, firebase, fcm, push-notifications]
one_liner: "WatchNotifier (AsyncNotifier + SharedPreferences) for tracking product/discount IDs, backend POST /notifications/subscribe endpoint, Firebase Admin SDK integration with price-drop FCM notifications after each scrape cycle"
dependency_graph:
  requires: [05-01]
  provides: [WatchNotifier, watchNotifierProvider, POST /notifications/subscribe, send_price_drop_notification, detect_and_notify_price_drops]
  affects: [backend/scraper/runner.py, backend/app/main.py, backend/app/notifier.py]
tech_stack:
  added: [firebase-admin>=6.0]
  patterns: [AsyncNotifier, SharedPreferences persistence, SQLAlchemy raw text upsert, graceful Firebase degradation]
key_files:
  created:
    - lib/features/watch/presentation/providers/watch_notifier.dart
    - backend/app/routers/notifications.py
    - backend/app/notifier.py
    - backend/.gitignore
  modified:
    - backend/app/main.py
    - backend/scraper/runner.py
    - backend/pyproject.toml
decisions:
  - "WatchList is a plain Dart class (not Freezed) — no serialization needed, IDs only; simpler for toggle pattern"
  - "firebase-admin version constraint relaxed to >=6.0 (no upper bound) — 7.4.0 installed cleanly; plan specified <7 but 7.x available and stable"
  - "detect_and_notify_price_drops called with existing db session after commit — session still open in finally block, committed data readable without new transaction"
  - "device_subscriptions table created via CREATE TABLE IF NOT EXISTS in the subscribe endpoint — avoids schema migration complexity for a simple new table"
metrics:
  duration_min: 4
  completed_date: "2026-04-12"
  tasks_completed: 3
  files_changed: 7
---

# Phase 05 Plan 02: WatchNotifier + Backend FCM Notifications Summary

WatchNotifier (AsyncNotifier + SharedPreferences) for tracking product/discount IDs, backend POST /notifications/subscribe endpoint, Firebase Admin SDK integration with price-drop FCM notifications after each scrape cycle.

## Tasks Completed

| # | Task | Commit | Files |
|---|------|--------|-------|
| 1 | WatchNotifier with SharedPreferences persistence | c228e84 | lib/features/watch/presentation/providers/watch_notifier.dart |
| 2 | Backend POST /notifications/subscribe endpoint | b81929f | backend/app/routers/notifications.py, backend/app/main.py |
| 3 | Firebase Admin SDK setup and price-drop notification sender | dc3b81f | backend/app/notifier.py, backend/scraper/runner.py, backend/app/main.py, backend/pyproject.toml, backend/.gitignore |

## What Was Built

### Flutter: WatchNotifier

`lib/features/watch/presentation/providers/watch_notifier.dart` implements `WatchNotifier extends AsyncNotifier<WatchList>` following the exact FavoritesNotifier pattern (D-04). Stores `List<String>` product IDs and discount IDs in SharedPreferences under keys `watched_product_ids` / `watched_discount_ids`. Provides `toggleProduct`, `toggleDiscount`, `isProductWatched`, `isDiscountWatched` operations. A `// TODO: Plan 03 will add subscribe sync here` comment marks the FCM token sync hook point.

### Backend: POST /notifications/subscribe

`backend/app/routers/notifications.py` accepts `{ "fcmToken": "...", "productIds": [...], "discountIds": [...] }` and upserts into a `device_subscriptions` table (created if not exists). Uses SQLAlchemy `Session = Depends(get_db)` consistent with all other routers. Returns `{ "status": "subscribed", "productCount": N, "discountCount": N }`. Registered as `notifications_router` in `main.py`.

### Backend: Firebase Admin SDK + Price-Drop FCM

`backend/app/notifier.py` provides:
- `init_firebase_admin()` — reads `GOOGLE_APPLICATION_CREDENTIALS` env var; logs warning and returns `False` if not set (graceful degradation)
- `send_price_drop_notification(fcm_token, product_name, market_product_id, old_price, new_price)` — sends FCM `messaging.Message` with `data={"productId": market_product_id, ...}` for deep navigation (D-03)
- `detect_and_notify_price_drops(db)` — queries `device_subscriptions`, compares `current_price` with second-most-recent `price_history` entry, sends FCM to all devices watching a product that dropped in price

`backend/scraper/runner.py` calls `detect_and_notify_price_drops(db)` after each `db.commit()` in the scrape cycle (NOTIF-03). `backend/app/main.py` calls `init_firebase_admin()` in the lifespan function (step 1b, after DB init).

## Verification

- `dart analyze lib/features/watch/` — no issues found
- `python -c "from app.notifier import ..."` — imports OK
- All 38 existing backend tests pass without regression

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] firebase-admin version constraint updated**
- **Found during:** Task 3 pip install
- **Issue:** pyproject.toml specified `firebase-admin>=6.0,<7` but pip installed 7.4.0 (the latest stable). The `<7` upper bound was overly restrictive with no documented incompatibility.
- **Fix:** Relaxed to `firebase-admin>=6.0` (no upper bound). 7.4.0 works correctly.
- **Files modified:** backend/pyproject.toml
- **Commit:** dc3b81f

## Known Stubs

None — all functionality is fully wired. The `// TODO: Plan 03 will add subscribe sync here` comments in WatchNotifier are intentional per the plan (D-05 sync will be added in Plan 03); they do not prevent this plan's goal (persistence + backend endpoint) from being achieved.

## Self-Check

**Files exist:**
- lib/features/watch/presentation/providers/watch_notifier.dart: FOUND
- backend/app/routers/notifications.py: FOUND
- backend/app/notifier.py: FOUND
- backend/.gitignore: FOUND

**Commits exist:**
- c228e84: FOUND
- b81929f: FOUND
- dc3b81f: FOUND

## Self-Check: PASSED
