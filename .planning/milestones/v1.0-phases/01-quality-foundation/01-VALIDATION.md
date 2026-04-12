---
phase: 1
slug: quality-foundation
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-27
---

# Phase 1 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | flutter test (SDK integrated) |
| **Config file** | none — uses pubspec.yaml test config |
| **Quick run command** | `flutter test test/` |
| **Full suite command** | `flutter test` |
| **Estimated runtime** | ~30 seconds |

---

## Sampling Rate

- **After every task commit:** Run `flutter test test/`
- **After every plan wave:** Run `flutter test`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 30 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 1-01-01 | 01 | 1 | QUAL-01 | unit | `flutter test test/core/utils/text_normalizer_test.dart` | ❌ W0 | ⬜ pending |
| 1-01-02 | 01 | 1 | QUAL-02 | unit | `flutter test test/features/products/` | ❌ W0 | ⬜ pending |
| 1-02-01 | 02 | 1 | QUAL-03 | unit | `flutter test test/features/favorites/` | ❌ W0 | ⬜ pending |
| 1-02-02 | 02 | 1 | QUAL-04 | integration | `flutter test test/` | ❌ W0 | ⬜ pending |
| 1-03-01 | 03 | 2 | QUAL-05 | widget | `flutter test test/features/home/` | ❌ W0 | ⬜ pending |
| 1-03-02 | 03 | 2 | QUAL-06 | widget | `flutter test test/features/products/` | ❌ W0 | ⬜ pending |
| 1-04-01 | 04 | 2 | QUAL-07 | widget | `flutter test` | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `test/core/utils/text_normalizer_test.dart` — unit tests for TextNormalizer (QUAL-01)
- [ ] `test/features/products/data/repositories/product_repository_test.dart` — repository unit tests (QUAL-02)
- [ ] `test/features/favorites/presentation/providers/favorites_notifier_test.dart` — NotifierProvider tests (QUAL-03)
- [ ] `test/features/home/presentation/home_page_test.dart` — widget test stub (QUAL-05)
- [ ] `test/widget_test.dart` — fix existing test (add ProviderScope wrapper, currently failing)

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Türkçe karakter arama tutarlılığı (tüm ekranlar) | QUAL-01 | Cross-screen UX check requires running app | Search "sut" → verify "Süt" results appear on Products, Markets, Discounts screens |
| CarrefourSA görsel tutarlılığı | QUAL-04 | Display string; not asserted in unit tests | Open Markets tab → verify "CarrefourSA" appears consistently (not "Carrefoursa") |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
