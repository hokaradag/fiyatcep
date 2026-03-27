# Phase 1: Quality Foundation - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions captured in CONTEXT.md — this log preserves the discussion.

**Date:** 2026-03-27
**Phase:** 01-quality-foundation
**Mode:** discuss
**Areas discussed:** Test mocking approach

## Gray Areas Presented

| Area | Status |
|------|--------|
| Test mocking approach | Discussed |
| FavoritesNotifier init | Claude's discretion |
| Widget extraction layout | Claude's discretion |
| Error display on UI | Claude's discretion |

## Decisions Made

### Test mocking approach
- **Question:** How should we mock dependencies in repository unit tests?
- **Decision:** Reuse existing mock datasources (`ProductMockDataSourceImpl` etc.) directly — no new mock library
- **Reason:** Zero new dependencies, consistent with existing datasource-swapping pattern, constraint "yeni bağımlılıklar minimize edilecek"

### Widget test coverage
- **Question:** What should widget tests cover?
- **Decision:** Products list + product detail page only
- **Reason:** Matches the requirement exactly ("en az ürün listesi ve ürün detay sayfası kapsanır")

## Deferred to Claude's Discretion

- **FavoritesNotifier init:** AsyncNotifier vs Notifier + init step — standard Riverpod pattern decision
- **Widget file layout:** `pages/` or `widgets/` dir for extracted widgets — consistency choice
- **Error display:** Whether page error builders show typed messages or just fix the throw — QUAL-02 requirement implies some UI update is needed
