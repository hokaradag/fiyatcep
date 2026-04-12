---
status: partial
phase: 05-fcm-push-notifications
source: [05-VERIFICATION.md]
started: 2026-04-12T11:00:00Z
updated: 2026-04-12T11:00:00Z
---

## Current Test

[awaiting human testing]

## Tests

### 1. End-to-end FCM push notification flow
expected: Tap Takip Et -> SnackBar shows 'X takibe alındı' -> backend log shows POST /notifications/subscribe -> restart app -> watch state persists -> trigger price drop via scrape -> push notification arrives -> tap notification -> navigates to product detail
result: [pending]

### 2. FCM cold start navigation
expected: App terminated, notification arrives, user taps it, app opens directly to ProductDetailPage for the notified product
result: [pending]

### 3. Background notification tap navigation
expected: App backgrounded, notification arrives, user taps it, app foregrounds and navigates to ProductDetailPage for the notified product
result: [pending]

### 4. Foreground SnackBar with Görüntüle action
expected: App in foreground, price-drop notification received, SnackBar with title/body and Görüntüle button appears, tapping Görüntüle navigates to ProductDetailPage
result: [pending]

## Summary

total: 4
passed: 0
issues: 0
pending: 4
skipped: 0
blocked: 0

## Gaps
