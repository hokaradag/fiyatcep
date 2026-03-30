---
phase: 4
slug: cart-comparison
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-30
---

# Phase 4 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | flutter_test (SDK integrated) |
| **Config file** | pubspec.yaml |
| **Quick run command** | `flutter test test/features/cart/` |
| **Full suite command** | `flutter test` |
| **Estimated runtime** | ~30 seconds |

---

## Sampling Rate

- **After every task commit:** Run `flutter test test/features/cart/`
- **After every plan wave:** Run `flutter test`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 30 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 4-01-01 | 01 | 1 | COMP-03 | unit | `flutter test test/features/cart/cart_notifier_test.dart` | ❌ W0 | ⬜ pending |
| 4-01-02 | 01 | 1 | COMP-03 | unit | `flutter test test/features/cart/cart_notifier_test.dart` | ❌ W0 | ⬜ pending |
| 4-02-01 | 02 | 2 | COMP-03 | unit | `flutter test test/features/cart/cart_comparison_provider_test.dart` | ❌ W0 | ⬜ pending |
| 4-03-01 | 03 | 3 | COMP-03 | widget | `flutter test test/features/cart/cart_comparison_page_test.dart` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `test/features/cart/cart_notifier_test.dart` — stubs for CartNotifier add/remove/clear/persistence
- [ ] `test/features/cart/cart_comparison_provider_test.dart` — stubs for cartComparisonProvider aggregation logic
- [ ] `test/features/cart/cart_comparison_page_test.dart` — widget stubs for CartComparisonPage rendering

*Existing test infrastructure (flutter_test) covers all phase requirements — no new framework install needed.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Cart persists after app restart | COMP-03 | Requires device/emulator restart | 1. Add products to cart, 2. Kill app, 3. Reopen and verify cart items remain |
| Partial match honest display | COMP-03 | UI visual correctness | 1. Add products where some markets are missing, 2. Verify "X/N ürün" label shows, 3. Verify 0-match markets shown at bottom |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
