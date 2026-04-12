# Project Retrospective

*A living document updated after each milestone. Lessons feed forward into future planning.*

## Milestone: v1.0 — MVP

**Shipped:** 2026-04-12
**Phases:** 8 (5 planned + 3 decimal insertions) | **Plans:** 25 | **Commits:** 157

### What Was Built
- **Quality foundation** — TextNormalizer, widget decomposition (3 large pages → 9 widgets), FavoritesStore → Riverpod AsyncNotifier, typed errors, 90+ tests
- **Live data pipeline** — Python FastAPI + SQLAlchemy + SQLite backend; Migros JSON API scraper (178 products); APScheduler daily refresh; JSONL audit log
- **Flutter → backend integration** — All 3 datasources swapped from mock to remote; camelCase JSON envelope; `productsByMarketProvider` calling real API
- **Price comparison UI** — Multi-market sorted price view (cheapest highlighted), fl_chart price history (4 time windows + touch tooltip), 7-retailer brand theming
- **Cart comparison** — CartNotifier with SharedPreferences, CartComparisonPage with per-market totals and match rate ("7/9 ürün mevcut")
- **FCM push notifications** — Full subscription loop: Takip Et UI → WatchNotifier → POST /notifications/subscribe → Firebase Admin price-drop detection → FCM delivery

### What Worked
- **API contract first (Phase 4.1)** — Freezing DB-SCHEMA.sql and API-CONTRACT.md before backend implementation eliminated ambiguity and made parallel development possible
- **Decimal phases for urgent insertions** — 4.1/4.2/4.3 cleanly split "what the backend should expose" from "how to build it" from "how Flutter integrates it"; scope stayed tight
- **Migros JSON API discovery** — Avoiding HTML scraping entirely saved significant complexity; REST endpoint was stable and fast
- **Mock→remote single-point swap** — `repository_providers.dart` as sole wiring point meant the 04.3 datasource switch touched ~5 lines across all features
- **Best-effort backend sync pattern** — FCM subscribe call silently ignores network errors; UX is never blocked by infra issues

### What Was Inefficient
- **minSdk revert artifact** — Worktree isolation left an unstaged `flutter.minSdkVersion` revert in the main tree after parallel agents merged; required manual `git restore` before verification passed
- **ROADMAP.md stale status** — Progress table showed Phase 1 as "In Progress" and Phase 4 without completion date; accumulated across sessions without auto-fix
- **Missing MKTD-02 in Phase 2 details** — Market detail real product list requirement was in traceability but not reflected in ROADMAP phase details; caused minor verifier confusion
- **firebase-admin version constraint** — Initial plan set `>=6.0,<7`; executor auto-relaxed to `>=6.0` — constraint had no documented reason, could have been open from the start

### Patterns Established
- **DB-SCHEMA + API-CONTRACT before backend coding** — Write spec documents as the first plan in any backend phase; never start implementation without frozen contract
- **Decimal phase for scope creep** — When a phase grows a dependency arm (e.g., "need a real backend for this"), insert a decimal phase rather than expanding the parent phase scope
- **camelCase JSON at API boundary** — Backend returns camelCase; Flutter Dart convention aligns without extra serialization layer
- **Best-effort fire-and-forget for non-critical syncs** — Background POSTs (subscribe, analytics) should never throw to the UI; catch all and log silently
- **FIREBASE_SETUP.md alongside code** — Document credential placement requirements in the repo when a build gate is imposed by external credentials

### Key Lessons
1. **Discover API endpoints before writing scrapers** — Migros.com.tr had a clean JSON REST API behind the UI. Check XHR traffic first; HTML scraping should be last resort.
2. **Freeze contracts before parallel work** — The 04.1 API contract phase paid off immediately in 04.2/04.3: no back-and-forth, no field name mismatches.
3. **Worktree parallel execution leaves dirty working trees** — After parallel agents merge, always run `git status` before verification; unstaged file reverts are a known artifact.
4. **Mock data needs to match real API shape early** — Price history mock data (Phase 3.4 gap closure) had to be added retroactively; if `priceHistory: []` is a valid mock shape, charts that depend on it fail silently.
5. **FCM E2E is a human gate, not a code gate** — All automated checks can pass; the real test (cold start, background tap, live push) requires credentials + device. Plan for this handoff explicitly.

### Cost Observations
- Model mix: ~100% sonnet (all executor/verifier agents on sonnet profile)
- Sessions: ~10 across 16 days
- Notable: Parallel Wave 1 execution (05-01 + 05-02 simultaneously) saved ~4 minutes on the FCM phase; worktree isolation prevented commit conflicts

---

## Cross-Milestone Trends

### Process Evolution

| Milestone | Phases | Plans | Key Change |
|-----------|--------|-------|------------|
| v1.0 | 8 | 25 | First milestone — baseline established |

### Cumulative Quality

| Milestone | Flutter Tests | Backend Tests | Notes |
|-----------|--------------|---------------|-------|
| v1.0 | ~90 | 38 | Dart analyze 0 issues; all tests green on ship |

### Top Lessons (Verified Across Milestones)

1. Freeze API contracts before parallel implementation work — eliminates coordination cost
2. Best-effort fire-and-forget for non-critical background syncs — UX never blocked by infra
