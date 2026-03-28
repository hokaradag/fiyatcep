---
phase: 3
slug: price-comparison-market-detail
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-29
---

# Phase 3 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | flutter test (SDK integrated) |
| **Config file** | none — existing test/ directory |
| **Quick run command** | `flutter test --name "price_comparison"` |
| **Full suite command** | `flutter test` |
| **Estimated runtime** | ~30 seconds |

---

## Sampling Rate

- **After every task commit:** Run `flutter test --name "price_comparison"`
- **After every plan wave:** Run `flutter test`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 30 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 3-01-01 | 01 | 0 | COMP-01 | unit | `flutter test test/features/products/` | ❌ W0 | ⬜ pending |
| 3-01-02 | 01 | 1 | COMP-01 | widget | `flutter test test/features/products/presentation/` | ❌ W0 | ⬜ pending |
| 3-02-01 | 02 | 1 | COMP-02 | widget | `flutter test test/features/products/presentation/` | ❌ W0 | ⬜ pending |
| 3-03-01 | 03 | 1 | MKTD-01 | widget | `flutter test test/features/markets/presentation/` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `test/features/products/presentation/price_comparison_widget_test.dart` — stubs for COMP-01 price list widget
- [ ] `test/features/products/presentation/price_history_chart_test.dart` — stubs for COMP-02 chart widget
- [ ] `test/features/markets/presentation/market_detail_page_test.dart` — stubs for MKTD-01 visual enhancement
- [ ] Verify `PricePoint.displayDate` getter exists in model

*Existing test infrastructure (flutter test) covers all phase requirements — no new framework install needed.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Touch a chart data point and verify exact price tooltip | COMP-02 | Gesture interaction not easily testable in widget tests | Run app, navigate to product detail, tap chart point, verify price popover |
| Price difference label shows "X TL daha ucuz" for cheapest market | COMP-01 | Visual highlight + computed label | Run app, verify cheapest market row has distinct visual treatment and TL diff |
| Market detail shows brand color as background | MKTD-01 | Color rendering visual check | Run app, navigate to market detail, verify brand color fills header |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
