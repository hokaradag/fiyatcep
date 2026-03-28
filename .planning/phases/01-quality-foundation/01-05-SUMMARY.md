---
phase: 01-quality-foundation
plan: 05
subsystem: testing
tags: [dart, flutter, text-normalization, turkish, search, unicode]

# Dependency graph
requires:
  - phase: 01-quality-foundation
    provides: TextNormalizer utility extracted in plan 01-01; test infrastructure from plan 01-04
provides:
  - Correct uppercase Turkish character normalization (İ, Ç, Ğ, Ö, Ş, Ü) in TextNormalizer.normalize()
  - Elimination of duplicate _normalizeText() in discounts_page.dart
  - 7 new tests covering uppercase Turkish char normalization and UAT ŞOK scenario
affects: [discounts-search, any future search/filter code using TextNormalizer]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Pre-toLowerCase uppercase Turkish replacement: replaceAll uppercase chars before calling toLowerCase() to handle platform-inconsistent Unicode folding"
    - "Single-source normalization: all search normalization delegates to TextNormalizer.normalize() — no private duplicate normalizers"

key-files:
  created: []
  modified:
    - lib/core/utils/text_normalizer.dart
    - lib/features/discounts/discounts_page.dart
    - test/core/utils/text_normalizer_test.dart

key-decisions:
  - "Uppercase Turkish replacements placed BEFORE toLowerCase() — platform-inconsistent Unicode folding means İ.toLowerCase() may not yield i on all targets"
  - "Added .trim() to TextNormalizer.normalize() to match discounts_page original behavior, preventing regression when duplicate was removed"

patterns-established:
  - "Pre-lowercase uppercase normalization: Turkish uppercase chars must be replaced before toLowerCase() call in text normalization chains"

requirements-completed: [QUAL-01]

# Metrics
duration: 15min
completed: 2026-03-28
---

# Phase 01 Plan 05: Turkish İ Normalization Fix Summary

**TextNormalizer now handles all uppercase Turkish chars (İ,Ç,Ğ,Ö,Ş,Ü) via pre-toLowerCase replacement, eliminating discounts search defect and duplicate _normalizeText()**

## Performance

- **Duration:** ~15 min
- **Started:** 2026-03-28
- **Completed:** 2026-03-28
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments

- Fixed root-cause Unicode defect: uppercase Turkish characters (İ, Ç, Ğ, Ö, Ş, Ü) are now replaced before `toLowerCase()` in `TextNormalizer.normalize()`, preventing platform-inconsistent folding
- Added `.trim()` to `TextNormalizer.normalize()` to preserve discounts_page original behavior when duplicate was removed
- Eliminated private `_normalizeText()` duplicate from `discounts_page.dart`; all 3 call sites now delegate to `TextNormalizer.normalize()`
- Added 7 new tests covering uppercase Turkish character cases and real-world UAT scenario (`ŞOK` -> `sok`)

## Task Commits

Each task was committed atomically:

1. **Task 1: Fix TextNormalizer uppercase Turkish character handling** - `55feab6` (feat)
2. **Task 2: Replace duplicate _normalizeText in discounts_page.dart with TextNormalizer** - `49d84b4` (feat)

**Plan metadata:** (final docs commit — see below)

## Files Created/Modified

- `lib/core/utils/text_normalizer.dart` - Added uppercase Turkish replacements (İ→i, Ç→c, Ğ→g, Ö→o, Ş→s, Ü→u) before `.toLowerCase()`, added `.trim()`
- `lib/features/discounts/discounts_page.dart` - Removed `_normalizeText()` method, added import for TextNormalizer, replaced 3 call sites with `TextNormalizer.normalize()`
- `test/core/utils/text_normalizer_test.dart` - Added 7 new tests: uppercase Turkish chars group (İ, Ç, Ğ, Ö, Ş, Ü), İstanbul full-word test, ŞOK UAT scenario

## Decisions Made

- Uppercase Turkish replacements placed before `toLowerCase()` — this is the fix for the root defect. On some Flutter target platforms, `İ.toLowerCase()` produces a two-character sequence (`i` + combining dot) rather than plain `i`. Explicit string replacement avoids relying on platform-specific Unicode case-folding.
- `.trim()` added to `TextNormalizer.normalize()` to preserve behavior parity with the original `_normalizeText()` in discounts_page (which already had `.trim()`). Without this, removing the duplicate would silently drop whitespace trimming from all three filter call sites.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- UAT issue 8 (Turkish character search) is resolved; the UAT sheet can be updated to mark it passed
- TextNormalizer is now the single source of truth for text normalization across all features
- Phase 01 quality-foundation is complete; all 5 plans executed

---
*Phase: 01-quality-foundation*
*Completed: 2026-03-28*
