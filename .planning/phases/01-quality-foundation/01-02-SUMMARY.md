---
phase: 01-quality-foundation
plan: 02
subsystem: ui
tags: [flutter, riverpod, shared_preferences, async_notifier, favorites]

# Dependency graph
requires: []
provides:
  - FavoritesNotifier AsyncNotifier managing favorites state via Riverpod
  - favoritesNotifierProvider wired to all consumer pages
  - FavoritesStore singleton removed from app startup path
affects: [DATA phase, testing, any page using favorites state]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - AsyncNotifier pattern for async-initialized Riverpod state
    - SharedPreferences accessed inside AsyncNotifier.build() instead of manual init()
    - Consumer widget used to scope provider watch within larger ConsumerWidget build()

key-files:
  created:
    - lib/features/favorites/presentation/providers/favorites_notifier.dart
  modified:
    - lib/features/favorites/favorites_page.dart
    - lib/features/home/home_page.dart
    - lib/features/products/product_detail_page.dart
    - lib/main.dart
    - lib/features/favorites/data/favorites_store.dart

key-decisions:
  - "AsyncNotifier used instead of Notifier because SharedPreferences.getInstance() is async — build() returns Future<List<ProductItem>>"
  - "Manual provider declaration (not @riverpod annotation) to avoid requiring build_runner for this file"
  - "Same SharedPreferences key 'favorite_products' preserved — existing user favorites survive migration"
  - "FavoritesStore kept with deprecation comment rather than deleted — safe deletion deferred to Phase 1 verification"
  - "Consumer widget (not ref.watch at page level) used in product_detail_page.dart to scope favorites watch within existing ConsumerWidget"

patterns-established:
  - "AsyncNotifier pattern: async-initialized state goes in build(), no manual init() needed in main()"
  - "Provider watch pattern: ref.watch for reads, ref.read(provider.notifier).method() for mutations"
  - "Favorites isFavorite check: favorites.any((p) => p == product) using Freezed equality"

requirements-completed: [QUAL-06]

# Metrics
duration: 4min
completed: 2026-03-27
---

# Phase 01 Plan 02: FavoritesStore to Riverpod AsyncNotifier Migration Summary

**FavoritesStore ValueNotifier singleton replaced by Riverpod AsyncNotifier with identical SharedPreferences persistence and no manual init() at app startup**

## Performance

- **Duration:** ~4 min
- **Started:** 2026-03-27T19:48:05Z
- **Completed:** 2026-03-27T19:51:43Z
- **Tasks:** 2
- **Files modified:** 6

## Accomplishments

- Created `FavoritesNotifier` AsyncNotifier with `build()` handling async SharedPreferences load — no `FavoritesStore.init()` needed
- Migrated all three consumer pages (favorites_page, home_page, product_detail_page) and main.dart to use `favoritesNotifierProvider`
- `FavoritesPage` converted from `StatelessWidget` to `ConsumerWidget`, `main()` no longer async
- Data migration safe: same `'favorite_products'` SharedPreferences key and JSON format preserved

## Task Commits

Each task was committed atomically:

1. **Task 1: Create FavoritesNotifier AsyncNotifier and provider** - `7034ffa` (feat)
2. **Task 2: Migrate all FavoritesStore consumers to FavoritesNotifier** - `5602134` (feat)

**Plan metadata:** (docs commit follows)

## Files Created/Modified

- `lib/features/favorites/presentation/providers/favorites_notifier.dart` - New AsyncNotifier with add/remove/toggle/isFavorite/_save methods
- `lib/features/favorites/favorites_page.dart` - Converted to ConsumerWidget, uses ref.watch(favoritesNotifierProvider)
- `lib/features/home/home_page.dart` - Replaced two ValueListenableBuilder blocks with favoritesAsync ref.watch pattern
- `lib/features/products/product_detail_page.dart` - Replaced ValueListenableBuilder with Consumer widget using favoritesNotifierProvider
- `lib/main.dart` - Removed FavoritesStore.init() and import; main() is now synchronous
- `lib/features/favorites/data/favorites_store.dart` - Added deprecation comment; file retained for Phase 1 verification

## Decisions Made

- Used `AsyncNotifier` (not `Notifier`) because `SharedPreferences.getInstance()` is async; `build()` returns `Future<List<ProductItem>>` and Riverpod manages the loading state automatically
- Used manual `AsyncNotifierProvider` declaration instead of `@riverpod` annotation to avoid adding build_runner dependency for this single file
- `Consumer` widget used inside `product_detail_page.dart` (which is already a `ConsumerWidget`) to scope the favorites watch close to where it is used
- `FavoritesStore` retained with `// DEPRECATED` comment; deletion deferred until Phase 1 verification confirms no regressions

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Favorites state is now fully Riverpod-managed and testable via ProviderScope overrides
- `FavoritesStore` can be deleted after Phase 1 verification; the deprecation comment documents this
- Plans 01-03 (TextNormalizer) and 01-04 (typed errors) have no dependencies on this plan and can proceed independently

---
*Phase: 01-quality-foundation*
*Completed: 2026-03-27*
