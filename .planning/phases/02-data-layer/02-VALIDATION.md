---
phase: 2
slug: data-layer
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-28
---

# Phase 2 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | flutter_test (SDK integrated) |
| **Config file** | `pubspec.yaml` (flutter_test SDK dependency) |
| **Quick run command** | `flutter test test/features/` |
| **Full suite command** | `flutter test` |
| **Estimated runtime** | ~10 seconds |

---

## Sampling Rate

- **After every task commit:** Run `flutter test test/features/`
- **After every plan wave:** Run `flutter test`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 30 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 2-01-01 | 01 | 1 | DATA-03 | unit | `flutter test test/features/products/models/` | ❌ W0 | ⬜ pending |
| 2-01-02 | 01 | 1 | DATA-03 | unit | `flutter test test/features/products/models/` | ❌ W0 | ⬜ pending |
| 2-02-01 | 02 | 1 | DATA-04 | unit | `flutter test test/features/discounts/models/` | ❌ W0 | ⬜ pending |
| 2-03-01 | 03 | 1 | DATA-01 | unit | `flutter test test/features/products/datasources/` | ❌ W0 | ⬜ pending |
| 2-03-02 | 03 | 1 | DATA-01 | unit | `flutter test test/features/` | ❌ W0 | ⬜ pending |
| 2-04-01 | 04 | 2 | MKTD-02 | unit | `flutter test test/features/products/` | ❌ W0 | ⬜ pending |
| 2-05-01 | 05 | 2 | DATA-02 | integration | manual | N/A | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `test/features/products/models/price_point_test.dart` — unit tests for PricePoint Freezed model (DATA-03)
- [ ] `test/features/products/models/product_item_test.dart` — unit tests for ProductItem.priceHistory field (DATA-03)
- [ ] `test/features/discounts/models/discount_item_test.dart` — unit tests for DiscountItem.validUntil DateTime migration (DATA-04)
- [ ] `test/features/products/datasources/product_remote_datasource_test.dart` — unit tests for getProductsByMarket() (MKTD-02, DATA-01)
- [ ] `test/features/products/datasources/product_mock_datasource_test.dart` — verify mock datasource still compiles after interface change

*Existing infrastructure: flutter_test is already integrated. Test directory structure at `test/features/` follows mirror of `lib/features/`.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| App shows real prices from API for all 7 markets | DATA-01, DATA-02 | Requires live backend | Run app, navigate to each market, verify real products appear |
| Market detail page loads products filtered by marketId | MKTD-02 | Requires live backend with market-filtered data | Navigate to market detail, verify products match that market only |
| discounts page shows formatted date for validUntil | DATA-04 | UI rendering verification | Open discounts tab, verify date format is human-readable (e.g., "30 Mar 2026") |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
