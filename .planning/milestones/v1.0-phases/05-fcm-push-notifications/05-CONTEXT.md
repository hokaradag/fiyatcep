# Phase 5: FCM Push Notifications - Context

**Gathered:** 2026-04-10
**Status:** Ready for planning

<domain>
## Phase Boundary

Kullanıcı takip ettiği ürün veya indirimde fiyat düşüşü olduğunda push bildirim alır.

Delivers: Firebase Cloud Messaging SDK integration (android-first), watch list UI on product and discount detail pages, backend-triggered price-drop alerts, and notification tap deep navigation to the relevant product page.

Out of scope: user accounts, cross-device watch list sync, notification scheduling UI, iOS APNs full setup (documented as follow-up).

</domain>

<decisions>
## Implementation Decisions

### Notification Tap Routing
- **D-01:** Use `GlobalKey<NavigatorState>` stored in `main.dart` — passed to `MaterialApp.navigatorKey`. No new navigation packages. Fits minimal-dependency philosophy already established.
- **D-02:** Handle all three app states via `firebase_messaging` callbacks:
  - **Cold start** (app terminated): check `FirebaseMessaging.instance.getInitialMessage()` after widget tree builds; if non-null, call `navigatorKey.currentState?.push(...)`.
  - **Background** (app suspended): subscribe to `FirebaseMessaging.onMessageOpenedApp` stream in `main()`.
  - **Foreground** (app open): subscribe to `FirebaseMessaging.onMessage` stream; show an in-app `SnackBar` or `MaterialBanner` with a tap-to-navigate action.
- **D-03:** Notification payload contains `productId` (string) only. On tap, the app calls the existing `productMarketPricesProvider` / navigation flow — same path as pressing a product card. No product data embedded in payload (avoids stale data risk).

### Watch List Storage
- **D-04:** Watch list stored locally in `SharedPreferences` via a new `WatchNotifier extends AsyncNotifier<List<String>>` (stores product IDs and/or discount IDs). Follows the exact same pattern as `FavoritesNotifier`.
- **D-05:** On any change to the watch list (add/remove), Flutter sends the updated list + current FCM token to a backend endpoint (`POST /notifications/subscribe`) so the backend knows which products to monitor for this device. Token refresh also triggers a re-sync.
- **D-06:** FCM token management: retrieve token in `main()` after `Firebase.initializeApp()`, store in a simple `SharedPreferences` key, and refresh via `FirebaseMessaging.instance.onTokenRefresh` stream.

### Watch UI Placement
- **D-07:** "Takip Et" / "Takibi Bırak" button on **product detail page** and **discount detail page** only (per NOTIF-02). No quick-watch from list cards — detail-page-only keeps scope contained.
- **D-08:** Watch button placement mirrors the favorites button pattern already in `product_detail_page.dart` — icon button in the app bar row alongside the existing favorites and cart buttons.

### Watch List Visibility
- **D-09:** No dedicated "Takip Listesi" screen in Phase 5. Users see watch state via the "Takip Et" / "Takibi Bırak" toggle on each detail page. A dedicated tracked-items screen is a natural Phase 6 / v2 addition.

### iOS Scope
- **D-10:** Phase 5 targets **Android only** for FCM verification. Firebase setup uses `google-services.json` on Android; `GoogleService-Info.plist` and APNs Auth Key (p8) for iOS are documented as a follow-up task to complete once the Apple Developer provisioning is done.
- **D-11:** iOS code paths (permission request via `requestPermission()`, `Info.plist` background mode keys, APN entitlements) are added to the codebase but **not verified** in Phase 5 — they should not break the build on either platform. Verification on a real iOS device is a post-Phase-5 task.

### Android Build Prerequisites
- **D-12:** `android/app/build.gradle.kts` `minSdk` must be bumped to **21** before adding `firebase_messaging` — FCM HTTP v1 API requires API 21+. Current config uses `flutter.minSdkVersion` (default 16); override it explicitly.

### Claude's Discretion
- Exact SnackBar vs MaterialBanner UX for foreground notifications
- Notification channel name and importance level (`NotificationChannel` for Android 8+)
- Watch button icon choice (e.g., `Icons.notifications_outlined` / `Icons.notifications_active`)
- Error handling if FCM token retrieval fails on first launch

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Requirements
- `.planning/REQUIREMENTS.md` §Notifications — NOTIF-01, NOTIF-02, NOTIF-03 acceptance criteria

### Architecture
- `lib/features/favorites/presentation/providers/favorites_notifier.dart` — AsyncNotifier + SharedPreferences pattern; WatchNotifier should mirror this exactly
- `lib/shared/main_navigation.dart` — current navigation structure; GlobalKey<NavigatorState> hooks in here
- `lib/main.dart` — app entry point; Firebase.initializeApp(), FCM setup, and getInitialMessage() check go here
- `lib/shared/providers/api_client_provider.dart` — existing Dio client; POST /notifications/subscribe reuses this

### No external specs
No dedicated FCM spec or ADR — requirements fully captured in decisions above.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `FavoritesNotifier` (`lib/features/favorites/presentation/providers/favorites_notifier.dart`): AsyncNotifier<List<ProductItem>> with SharedPreferences persistence. `WatchNotifier` should follow the same structure but store IDs (List<String>) rather than full models.
- `ApiClient` (`lib/shared/providers/api_client_provider.dart`): Dio-based HTTP client already wired. The new `POST /notifications/subscribe` call reuses it directly.
- Favorites button in `product_detail_page.dart` (line 50–75 approx): icon button pattern in app bar row; watch button slots in alongside it.

### Established Patterns
- **AsyncNotifier + SharedPreferences**: phase 1 migrated FavoritesStore to this; follow it exactly for WatchNotifier.
- **ProviderScope.overrides in tests**: phase 2 established this for widget tests — FCM-related providers must be overridable for widget tests.
- **Minimal dependencies**: prior phases explicitly avoided adding packages (e.g., intl avoided for Turkish month names). FCM requires `firebase_core` + `firebase_messaging` — these are the only new pub.dev dependencies expected.
- **Result<T> error propagation**: providers use typed AppException, not raw `throw Exception(message)` (phase 1 decision).

### Integration Points
- `lib/main.dart`: `Firebase.initializeApp()`, `FCM token retrieval`, `getInitialMessage()` check, `onMessageOpenedApp` subscription, `onMessage` subscription.
- `lib/shared/main_navigation.dart` OR `lib/main.dart`: `navigatorKey` passed to `MaterialApp`.
- `lib/features/products/product_detail_page.dart`: watch button added alongside existing favorites/cart buttons.
- Discount detail page (if one exists, otherwise the discount card itself): watch button entry point for discounts.
- Backend: new `POST /notifications/subscribe` endpoint (body: `{ "fcmToken": "...", "productIds": [...], "discountIds": [...] }`).

</code_context>

<specifics>
## Specific Ideas

No specific UI references provided — open to standard approaches.

</specifics>

<deferred>
## Deferred Ideas

- Dedicated "Takip Listesi" screen — natural Phase 6 / v2 addition once watch list has more functionality
- iOS APNs full verification — follow-up task after Apple Developer p8 key provisioning
- Price-drop threshold setting (e.g., "notify only if drops below X ₺") — NOTIF-V2-01 in requirements
- Watch button on list-view cards (quick-watch without opening detail) — detail pages only for Phase 5

</deferred>

---

*Phase: 05-fcm-push-notifications*
*Context gathered: 2026-04-10*
