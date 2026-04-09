# Phase 5: FCM Push Notifications - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-10
**Phase:** 05-fcm-push-notifications
**Areas discussed:** Notification tap routing, iOS scope

---

## Notification tap routing

| Option | Description | Selected |
|--------|-------------|----------|
| GlobalKey navigator | Add GlobalKey<NavigatorState> to MaterialApp. Handle all 3 app states with firebase_messaging callbacks. No new packages. | ✓ |
| go_router deep links | Add go_router for URL-based deep linking. Requires refactoring current page-array navigation. | |
| Background + cold start only | Handle only cold start and background tap. Foreground notifications arrive silently. | |

**User's choice:** GlobalKey navigator (Recommended)
**Notes:** Fits minimal-dependency philosophy already established across prior phases.

---

## Notification payload

| Option | Description | Selected |
|--------|-------------|----------|
| Product ID only | Payload contains productId string. App fetches product detail on tap via existing providers. | ✓ |
| Full product data in payload | Embed product name and price in notification. Instant navigation but payload bloat and stale data risk. | |
| Product ID + market slug | Contains productId + marketId. Pre-scrolls to specific market's price row. | |

**User's choice:** Product ID only (Recommended)
**Notes:** Consistent with how product detail pages already load data through providers.

---

## iOS scope

| Option | Description | Selected |
|--------|-------------|----------|
| Android-first, iOS follow-up | Phase 5 verifies on Android. iOS wiring documented as follow-up once APNs key provisioned. | ✓ |
| Both platforms in Phase 5 | APNs key ready before Phase 5 starts. Full iOS setup in scope. | |
| Android only (permanent) | iOS notifications out of scope for v1. | |

**User's choice:** Android-first, iOS follow-up (Recommended)
**Notes:** APNs Auth Key provisioning is an external blocker (Apple Developer account). Android demo unblocked.

---

## Areas not selected for discussion

The following gray areas were presented but not selected by the user — treated as Claude's discretion or locked by prior decisions:

- **Watch list visibility**: No dedicated screen in Phase 5; watch state visible via toggle on detail pages only. Dedicated screen deferred to Phase 6 / v2.
- **Watch entry points**: Locked to product detail + discount detail pages per NOTIF-02. No quick-watch from list cards.

## Deferred Ideas

- Dedicated "Takip Listesi" screen — future phase
- iOS APNs verification — post-Phase-5 follow-up
- Price-drop threshold (NOTIF-V2-01)
- Watch button on list-view cards
