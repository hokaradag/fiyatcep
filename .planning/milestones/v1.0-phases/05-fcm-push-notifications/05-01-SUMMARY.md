---
phase: 05-fcm-push-notifications
plan: 01
subsystem: notifications
tags: [firebase, fcm, push-notifications, android, ios]
dependency_graph:
  requires: []
  provides: [fcm-sdk-initialized, fcm-token-managed, notification-tap-routing]
  affects: [lib/main.dart, lib/app.dart, android/app/build.gradle.kts, android/settings.gradle.kts, ios/Runner/Info.plist]
tech_stack:
  added: [firebase_core ^3.13.0, firebase_messaging ^15.2.5]
  patterns: [GlobalKey<NavigatorState> for deep navigation, FutureProvider for async token retrieval, onTokenRefresh stream for token refresh]
key_files:
  created:
    - lib/shared/providers/fcm_token_provider.dart
    - lib/shared/providers/notification_handler.dart
    - .planning/phases/05-fcm-push-notifications/FIREBASE_SETUP.md
  modified:
    - pubspec.yaml
    - pubspec.lock
    - android/app/build.gradle.kts
    - android/settings.gradle.kts
    - ios/Runner/Info.plist
    - lib/main.dart
    - lib/app.dart
    - .gitignore
decisions:
  - "navigatorKey exported from notification_handler.dart and imported in app.dart — single source of truth for global navigation key avoids circular imports"
  - "google-services.json added to .gitignore — contains Firebase API keys, must never be committed"
  - "minSdk = 21 hardcoded (not flutter.minSdkVersion) — FCM HTTP v1 API requires API 21+, overrides Flutter default"
  - "ProductItem with empty fields used for notification tap navigation — detail page fetches real data via productMarketPricesProvider, minimal stub satisfies constructor"
metrics:
  duration_minutes: 3
  completed_date: "2026-04-12"
  tasks_completed: 2
  files_changed: 8
requirements_satisfied: [NOTIF-01, NOTIF-03]
---

# Phase 05 Plan 01: Firebase FCM SDK Integration Summary

Firebase Cloud Messaging SDK integrated with full notification tap routing across cold start, background, and foreground app states using GlobalKey<NavigatorState> and Riverpod FutureProvider for token management.

## Tasks Completed

| # | Task | Commit | Files |
|---|------|--------|-------|
| 1 | Firebase SDK setup and Android build configuration | 02896c7 | pubspec.yaml, build.gradle.kts, settings.gradle.kts, Info.plist, FIREBASE_SETUP.md |
| 2 | FCM token provider, notification handlers, and main.dart/app.dart wiring | 90be8f5 | fcm_token_provider.dart, notification_handler.dart, main.dart, app.dart, .gitignore |

## What Was Built

### FCM Token Provider (`lib/shared/providers/fcm_token_provider.dart`)

- `fcmTokenProvider` — Riverpod `FutureProvider<String?>` that retrieves the FCM registration token on first call and persists it to `SharedPreferences` under key `fcm_token`.
- `listenForTokenRefresh()` — standalone function wired in `main()` that subscribes to `FirebaseMessaging.instance.onTokenRefresh` and persists updated tokens. Includes a TODO marker for Plan 03 backend re-sync.

### Notification Handler (`lib/shared/providers/notification_handler.dart`)

- `navigatorKey` — `GlobalKey<NavigatorState>` exported here, imported by `app.dart` for `MaterialApp.navigatorKey`.
- `setupNotificationHandlers()` — async function called once in `main()` after `Firebase.initializeApp()`:
  - Requests notification permission (iOS required, Android harmless)
  - Cold start: `getInitialMessage()` + `addPostFrameCallback` to delay until navigator is ready
  - Background: `onMessageOpenedApp` listener
  - Foreground: `onMessage` listener shows `SnackBar` with optional "Goruntule" action button
- `_handleNotificationTap()` — extracts `productId` from `message.data`, pushes `ProductDetailPage` with a minimal `ProductItem` shell (detail page loads real data via `productMarketPricesProvider`)
- `_handleForegroundMessage()` — shows `SnackBar` with title/body and tap-to-navigate action

### Android Build Configuration

- `android/app/build.gradle.kts`: `id("com.google.gms.google-services")` added to plugins block; `minSdk = 21` (was `flutter.minSdkVersion`)
- `android/settings.gradle.kts`: `id("com.google.gms.google-services") version "4.4.2" apply false` added to plugins block

### iOS Configuration

- `ios/Runner/Info.plist`: `UIBackgroundModes` array with `fetch` and `remote-notification` added — prevents iOS from suspending the app before FCM can deliver background messages

### App Wiring

- `lib/app.dart`: `navigatorKey: navigatorKey` added to `MaterialApp` — enables programmatic navigation from notification taps when app is in background/cold start
- `lib/main.dart`: `async main()` with `Firebase.initializeApp()`, `setupNotificationHandlers()`, `listenForTokenRefresh()` before `runApp()`

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| `navigatorKey` exported from `notification_handler.dart` | Single file owns all notification + navigation concerns; avoids a separate `keys.dart` file for one key |
| `google-services.json` + `GoogleService-Info.plist` added to `.gitignore` | These files contain Firebase API keys and must never reach source control |
| `minSdk = 21` hardcoded | FCM HTTP v1 API requires API 21+; `flutter.minSdkVersion` resolves to 16 which would cause runtime failures |
| Empty `ProductItem` shell for notification navigation | `ProductDetailPage` already fetches full data from `productMarketPricesProvider(product.id)` — only the `id` field is needed for the navigation dispatch |

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Security] Added google-services.json and GoogleService-Info.plist to .gitignore**
- **Found during:** Task 2
- **Issue:** `.gitignore` had Firebase Admin SDK entries but no Flutter client config entries; real `google-services.json` placed by users would have been tracked by git
- **Fix:** Added `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist` to `.gitignore`
- **Files modified:** `.gitignore`
- **Commit:** 90be8f5

## User Setup Required

The app **cannot build** without `android/app/google-services.json`. See `.planning/phases/05-fcm-push-notifications/FIREBASE_SETUP.md` for step-by-step instructions.

## Known Stubs

None — all FCM wiring is real code. Token persistence is fully functional. Navigation routing is complete. The only intentional placeholder is the `TODO` comment in `fcm_token_provider.dart` marking where Plan 03 will add backend token sync.

## Verification Results

- `flutter pub get` — passed (firebase_core and firebase_messaging resolved)
- `dart analyze lib/shared/providers/ lib/main.dart lib/app.dart` — no issues found
- Android: `minSdk = 21`, Google Services plugin configured
- iOS: `UIBackgroundModes` with `remote-notification` added to Info.plist
- All 3 notification app states handled: cold start (`getInitialMessage`), background (`onMessageOpenedApp`), foreground (`onMessage` + SnackBar)
