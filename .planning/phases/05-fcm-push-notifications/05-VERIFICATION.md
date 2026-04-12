---
phase: 05-fcm-push-notifications
verified: 2026-04-12T11:00:00Z
status: human_needed
score: 4/4 success criteria verified
re_verification:
  previous_status: gaps_found
  previous_score: 3/4
  gaps_closed:
    - "android/app/build.gradle.kts minSdk restored to 21 (git restore confirmed working tree now matches committed state)"
  gaps_remaining: []
  regressions: []
human_verification:
  - test: "End-to-end FCM push notification flow on physical Android device or emulator"
    expected: "Tap Takip Et -> SnackBar shows 'X takibe alindi' -> backend log shows POST /notifications/subscribe -> restart app -> watch state persists -> trigger price drop via scrape -> push notification arrives -> tap notification -> navigates to product detail"
    why_human: "Requires google-services.json, Firebase service account credentials, running backend, and Android device/emulator"
  - test: "FCM cold start navigation"
    expected: "App terminated, notification arrives, user taps it, app opens directly to ProductDetailPage for the notified product"
    why_human: "Requires full FCM setup and testing on physical device or emulator with app in killed state"
  - test: "Background notification tap navigation"
    expected: "App backgrounded, notification arrives, user taps it, app foregrounds and navigates to ProductDetailPage for the notified product"
    why_human: "Requires real FCM delivery to a device in background state"
  - test: "Foreground SnackBar with Goruntule action"
    expected: "App in foreground, price-drop notification received, SnackBar with title/body and Goruntule button appears, tapping Goruntule navigates to ProductDetailPage"
    why_human: "Requires real FCM delivery to foreground app"
---

# Phase 5: FCM Push Notifications Verification Report

**Phase Goal:** Kullanici takip ettigi urun veya indirimde fiyat dususu oldugunda push bildirim alir (User receives push notification when tracked product or discount has a price drop)
**Verified:** 2026-04-12T11:00:00Z
**Status:** human_needed
**Re-verification:** Yes — after gap closure (minSdk = 21 restored)

## Goal Achievement

### Observable Truths (from ROADMAP.md Success Criteria)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | Firebase Cloud Messaging Android ve iOS cihazlarda calisir; FCM token yonetimi yapilir | VERIFIED | firebase_core + firebase_messaging in pubspec.yaml; all notification handlers wired in main.dart and notification_handler.dart; minSdk = 21 confirmed in android/app/build.gradle.kts line 28 |
| 2 | Kullanici urun veya indirim detay sayfasindan "Takip Et" / "Takibi Birak" ile takip listesini yonetebilir | VERIFIED | WatchNotifier + watchNotifierProvider in watch_notifier.dart; Takip Et/Takibi Birak button with SnackBar feedback in product_detail_page.dart; SharedPreferences persistence; discounts_page navigates to ProductDetailPage which has the watch button |
| 3 | Takip edilen urunde fiyat dususu oldugunda kullanici push bildirim alir | VERIFIED | detect_and_notify_price_drops in notifier.py called from runner.py after each scrape commit; send_price_drop_notification sends FCM with productId data payload; POST /notifications/subscribe stores device subscriptions; backend sync wired in WatchNotifier._syncWithBackend |
| 4 | Bildirime tiklandiginda uygulama ilgili urun sayfasina yonlendirir | VERIFIED | notification_handler.dart handles all 3 states: cold start (getInitialMessage + addPostFrameCallback), background (onMessageOpenedApp), foreground (onMessage + SnackBar with action); _handleNotificationTap navigates to ProductDetailPage with productId; navigatorKey wired into MaterialApp |

**Score:** 4/4 truths verified

---

## Required Artifacts

### Plan 01: Firebase SDK Integration

| Artifact | Expected | Status | Details |
|----------|---------|--------|---------|
| `lib/shared/providers/fcm_token_provider.dart` | FCM token retrieval and refresh logic | VERIFIED | fcmTokenProvider (FutureProvider), listenForTokenRefresh(), _fcmTokenKey, persists to SharedPreferences, re-syncs via Dio on token refresh |
| `lib/shared/providers/notification_handler.dart` | Notification tap routing for all three app states | VERIFIED | navigatorKey, setupNotificationHandlers(), getInitialMessage, onMessageOpenedApp, onMessage, _handleNotificationTap, _handleForegroundMessage, ProductDetailPage navigation |
| `lib/app.dart` | navigatorKey wired into MaterialApp | VERIFIED | navigatorKey: navigatorKey present; imports notification_handler.dart. GlobalKey defined in notification_handler.dart by design — avoids circular imports |
| `lib/main.dart` | Firebase init, FCM setup, notification handler wiring | VERIFIED | Firebase.initializeApp(), setupNotificationHandlers(), listenForTokenRefresh(), async main() |
| `android/app/build.gradle.kts` | minSdk = 21, google-services plugin | VERIFIED | minSdk = 21 confirmed at line 28 (working tree matches committed state); google-services plugin present at line 6 |
| `pubspec.yaml` | firebase_core + firebase_messaging | VERIFIED | firebase_core: ^3.13.0, firebase_messaging: ^15.2.5 |
| `ios/Runner/Info.plist` | UIBackgroundModes with remote-notification | VERIFIED | UIBackgroundModes array with fetch and remote-notification present |
| `android/settings.gradle.kts` | google-services classpath | VERIFIED | id("com.google.gms.google-services") version "4.4.2" apply false |

### Plan 02: WatchNotifier + Backend Notifications

| Artifact | Expected | Status | Details |
|----------|---------|--------|---------|
| `lib/features/watch/presentation/providers/watch_notifier.dart` | Watch list state management with SharedPreferences persistence | VERIFIED | WatchNotifier extends AsyncNotifier<WatchList>, toggleProduct, toggleDiscount, isProductWatched, isDiscountWatched, _save, _watchedProductIdsKey, _watchedDiscountIdsKey |
| `backend/app/routers/notifications.py` | POST /notifications/subscribe endpoint | VERIFIED | @router.post("/subscribe") with prefix /notifications, SubscribeRequest model, fcmToken/productIds/discountIds, device_subscriptions upsert, ON CONFLICT DO UPDATE |
| `backend/app/main.py` | Notifications router registered | VERIFIED | from app.routers.notifications import router as notifications_router, app.include_router(notifications_router) |
| `backend/app/notifier.py` | Firebase Admin SDK init and FCM sender | VERIFIED | init_firebase_admin(), send_price_drop_notification(), detect_and_notify_price_drops(), messaging.Message with data={"productId": ...}, graceful degradation |
| `backend/scraper/runner.py` | Price-drop detection hook after scrape | VERIFIED | from app.notifier import detect_and_notify_price_drops; called after db.commit() in run_scrape_cycle() |
| `backend/pyproject.toml` | firebase-admin dependency | VERIFIED | firebase-admin>=6.0 |

### Plan 03: Watch UI Buttons and Backend Sync

| Artifact | Expected | Status | Details |
|----------|---------|--------|---------|
| `lib/features/products/product_detail_page.dart` | Watch button alongside favorites and cart | VERIFIED | Consumer widget with watchNotifierProvider, toggleProduct(product.id), Icons.notifications_active/outlined, Takip Et/Takibi Birak, SnackBar feedback |
| `lib/features/watch/presentation/providers/watch_notifier.dart` | Backend sync on watch list change | VERIFIED | _syncWithBackend() called after _save() in both toggleProduct and toggleDiscount; Dio POST to /notifications/subscribe with fcmToken, productIds, discountIds |
| `lib/shared/providers/api_client_provider.dart` | apiBaseUrl constant | VERIFIED | const String apiBaseUrl = 'http://10.0.2.2:8000/api/v1'; used by provider and imported by fcm_token_provider and watch_notifier |

---

## Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| lib/main.dart | lib/shared/providers/notification_handler.dart | setupNotificationHandlers() call | WIRED | main.dart imports and calls setupNotificationHandlers() after Firebase.initializeApp() |
| lib/shared/providers/notification_handler.dart | lib/app.dart | navigatorKey.currentState?.push | WIRED | navigatorKey exported from notification_handler.dart, imported in app.dart as MaterialApp.navigatorKey |
| lib/main.dart | lib/shared/providers/fcm_token_provider.dart | listenForTokenRefresh() call | WIRED | main.dart imports and calls listenForTokenRefresh() |
| lib/features/watch/presentation/providers/watch_notifier.dart | SharedPreferences | setStringList/getStringList | WIRED | _save() calls prefs.setStringList for both _watchedProductIdsKey and _watchedDiscountIdsKey; build() calls getStringList |
| backend/app/routers/notifications.py | device_subscriptions table | SQLAlchemy Session | WIRED | CREATE TABLE IF NOT EXISTS + ON CONFLICT upsert via Depends(get_db) |
| backend/scraper/runner.py | backend/app/notifier.py | detect_and_notify_price_drops | WIRED | imported at top of runner.py, called after db.commit() |
| backend/app/notifier.py | firebase_admin.messaging | messaging.send | WIRED (conditional) | messaging.Message with productId data payload; guarded by _firebase_initialized flag |
| lib/features/products/product_detail_page.dart | lib/features/watch/presentation/providers/watch_notifier.dart | toggleProduct(product.id) | WIRED | Consumer watches watchNotifierProvider, calls notifier.toggleProduct on button press |
| lib/features/watch/presentation/providers/watch_notifier.dart | backend/app/routers/notifications.py | Dio POST /notifications/subscribe | WIRED | _syncWithBackend() constructs Dio with apiBaseUrl and posts; called after every toggle |
| lib/shared/providers/fcm_token_provider.dart | lib/features/watch/presentation/providers/watch_notifier.dart | token refresh triggers subscribe re-sync | WIRED | listenForTokenRefresh() reads watched_product_ids/watched_discount_ids from SharedPreferences and POSTs to /notifications/subscribe |

---

## Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
|----------|--------------|--------|--------------------|--------|
| `product_detail_page.dart` watch button | `watchList.productIds` | WatchNotifier.build() reads SharedPreferences | Yes — SharedPreferences stores real persisted IDs | FLOWING |
| `WatchNotifier._syncWithBackend` | `watchList.productIds/discountIds` | State from toggle operations | Yes — current state after toggle | FLOWING |
| `backend/app/notifier.py detect_and_notify_price_drops` | `current_price, previous_price` | DB queries on market_products + price_history | Yes — real DB queries with JOIN | FLOWING |
| `fcm_token_provider.dart listenForTokenRefresh` | `productIds, discountIds` | SharedPreferences read on token refresh | Yes — reads persisted IDs, posts if non-empty | FLOWING |

---

## Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Backend notifier imports cleanly | `python -c "from app.notifier import init_firebase_admin, send_price_drop_notification, detect_and_notify_price_drops; print('imports OK')"` | imports OK | PASS |
| Backend tests pass without regression | `python -m pytest tests/ -x -q` | 38 passed in 3.79s | PASS |
| Dart analyze on all modified files | `dart analyze lib/shared/providers/ lib/main.dart lib/app.dart lib/features/watch/presentation/providers/watch_notifier.dart lib/features/products/product_detail_page.dart` | No issues found | PASS |
| All documented commits exist | git log with 9 commit hashes | All 9 commits present: 02896c7, 90be8f5, c228e84, b81929f, dc3b81f, 588f0cb, d955d2c, 6aa1144, bd04ba0 | PASS |
| minSdk in working tree | `grep minSdk android/app/build.gradle.kts` | minSdk = 21 (line 28) | PASS — gap closed |

---

## Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|------------|-------------|--------|----------|
| NOTIF-01 | 05-01-PLAN.md | Firebase Cloud Messaging Android ve iOS'ta calisir; FCM token yonetimi | SATISFIED | firebase_core + firebase_messaging integrated, FCM token persisted, notification handlers wired, minSdk = 21 confirmed |
| NOTIF-02 | 05-02-PLAN.md, 05-03-PLAN.md | Kullanici urun veya indirim detay sayfasindan "Takip Et" ile takibe alabilir | SATISFIED | WatchNotifier with SharedPreferences persistence; Takip Et/Takibi Birak button on ProductDetailPage; discounts_page navigates to ProductDetailPage |
| NOTIF-03 | 05-02-PLAN.md, 05-03-PLAN.md | Takip edilen urunde fiyat dususu oldugunda push bildirim alir; tap -> urun sayfasi | SATISFIED | detect_and_notify_price_drops called after scrape; FCM send with productId; _handleNotificationTap routes to ProductDetailPage |

---

## Anti-Patterns Found

No blocker anti-patterns. No TODO/FIXME stubs in phase-delivered files. All `// TODO: Plan 03 will add` comments from Plan 02 have been replaced with real implementations in Plan 03.

The previously flagged `minSdk = flutter.minSdkVersion` working-tree issue is resolved — `android/app/build.gradle.kts` now correctly shows `minSdk = 21`.

---

## Human Verification Required

### 1. End-to-End FCM Push Notification Flow

**Test:** Start backend with `GOOGLE_APPLICATION_CREDENTIALS=./firebase-service-account.json uvicorn app.main:app --reload`. Run Flutter app on Android emulator with `google-services.json` placed. Navigate to product detail page, tap "Takip Et", verify SnackBar appears, verify backend log shows `POST /notifications/subscribe`. Restart app, verify watch state persists.
**Expected:** Watch button shows "Takibi Birak" after tap and after restart. Backend log confirms subscription received.
**Why human:** Requires Firebase project setup (google-services.json, service account JSON), running backend, and Android emulator/device.

### 2. FCM Cold Start Navigation

**Test:** With Firebase configured, ensure app is fully closed. Use Firebase Console or backend scrape trigger to send a push notification with `productId` data payload to the device's FCM token. Tap the notification.
**Expected:** App opens directly to `ProductDetailPage` for the notified product ID (handled by `getInitialMessage()` + `addPostFrameCallback`).
**Why human:** Requires real FCM credentials, push delivery, and verifying app navigation on device/emulator.

### 3. Background Notification Tap Navigation

**Test:** With app backgrounded (not killed), receive a push notification. Tap it.
**Expected:** App comes to foreground and navigates to `ProductDetailPage` for the product (handled by `onMessageOpenedApp` listener).
**Why human:** Requires real FCM delivery to a device in background state.

### 4. Foreground SnackBar with Navigate Action

**Test:** With app in foreground, trigger a price-drop notification (via backend scrape or Firebase Console test message with `productId` in data).
**Expected:** In-app SnackBar appears with title/body and "Goruntule" action button. Tapping "Goruntule" navigates to `ProductDetailPage`.
**Why human:** Requires real FCM delivery to foreground app.

---

## Gaps Summary

No automated gaps remain. The single blocker from the initial verification (minSdk revert in working tree) has been resolved — `android/app/build.gradle.kts` line 28 reads `minSdk = 21`, matching the committed state.

All NOTIF-01, NOTIF-02, and NOTIF-03 requirements are fully satisfied at the code level. The complete notification subscription loop (UI tap -> WatchNotifier -> backend sync -> scrape price-drop detection -> FCM send -> app navigation) is implemented and wired end-to-end.

The four human verification items listed above require real Firebase credentials and a device/emulator and cannot be verified programmatically. They are the only remaining open items for this phase.

---

_Verified: 2026-04-12T11:00:00Z_
_Verifier: Claude (gsd-verifier)_
