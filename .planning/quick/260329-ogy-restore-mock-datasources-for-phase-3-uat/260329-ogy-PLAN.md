---
phase: quick
plan: 260329-ogy
type: execute
wave: 1
depends_on: []
files_modified:
  - lib/shared/providers/repository_providers.dart
autonomous: true
requirements: []
must_haves:
  truths:
    - "App loads products, markets, and discounts from mock data without network errors"
    - "Phase 3 UI (market detail, price chart, brand banner) is fully navigable"
    - "Remote datasource classes remain in the codebase, untouched"
  artifacts:
    - path: "lib/shared/providers/repository_providers.dart"
      provides: "Repository wiring that points to mock datasource implementations"
      contains: "MockDataSourceImpl"
  key_links:
    - from: "lib/shared/providers/repository_providers.dart"
      to: "ProductMockDataSourceImpl / MarketMockDataSourceImpl / DiscountMockDataSourceImpl"
      via: "Provider instantiation"
      pattern: "MockDataSourceImpl"
---

<objective>
Restore mock datasources in repository_providers.dart so all three feature repositories
(products, markets, discounts) use mock data instead of the unreachable remote API.

Purpose: Phase 3 UAT and demo cannot proceed while the app calls https://api.fiyatcep.com/api/v1,
which is not yet live. Swapping back to mocks unblocks UI verification without removing any
remote datasource code.

Output: Updated repository_providers.dart; remote datasource providers remain as dead code for
easy reactivation once the backend is live.
</objective>

<execution_context>
@C:/dev/fiyatcep/.claude/get-shit-done/workflows/execute-plan.md
</execution_context>

<context>
@.planning/STATE.md
@lib/shared/providers/repository_providers.dart
</context>

<tasks>

<task type="auto">
  <name>Task 1: Wire mock datasources in repository_providers.dart</name>
  <files>lib/shared/providers/repository_providers.dart</files>
  <action>
    Replace the active datasource used by each repository provider with its mock counterpart.
    Keep the existing remote datasource providers in the file as dormant providers (commented-out
    or simply unused) so they can be reactivated without any code archaeology.

    Concrete changes:
    1. Add imports for the three mock datasource files:
       - `../../features/products/data/datasources/product_mock_datasource.dart`
       - `../../features/markets/data/datasources/market_mock_datasource.dart`
       - `../../features/discounts/data/datasources/discount_mock_datasource.dart`

    2. Replace the body of `productRepositoryProvider` so it creates
       `ProductRepositoryImpl(remoteDataSource: ProductMockDataSourceImpl())` — drop the
       dependency on `productRemoteDataSourceProvider`.

    3. Replace the body of `marketRepositoryProvider` so it creates
       `MarketRepositoryImpl(remoteDataSource: MarketMockDataSourceImpl())` — drop the
       dependency on `marketRemoteDataSourceProvider`.

    4. Replace the body of `discountRepositoryProvider` so it creates
       `DiscountRepositoryImpl(remoteDataSource: DiscountMockDataSourceImpl())` — drop the
       dependency on `discountRemoteDataSourceProvider`.

    5. Retain `productRemoteDataSourceProvider`, `marketRemoteDataSourceProvider`, and
       `discountRemoteDataSourceProvider` in the file with a comment:
       `// UAT: remote datasource providers kept for easy reactivation once API is live`

    Do NOT delete any existing remote datasource class files. Do NOT modify any datasource or
    repository implementation files — this change is limited to repository_providers.dart only.
  </action>
  <verify>
    <automated>cd C:/dev/fiyatcep && flutter analyze lib/shared/providers/repository_providers.dart</automated>
  </verify>
  <done>
    repository_providers.dart compiles cleanly; each repository provider instantiates its
    MockDataSourceImpl; remote providers remain in file with UAT comment.
  </done>
</task>

<task type="auto">
  <name>Task 2: Run full analyze and tests, then commit</name>
  <files></files>
  <action>
    1. Run `flutter analyze` across the whole project and resolve any new warnings introduced
       by the import or unused-variable changes in Task 1 (e.g., unused `apiClientProvider`
       reference if api_client_provider import is no longer needed — remove the import only if
       flutter analyze flags it; otherwise leave it).

    2. Run widget/unit tests:
       `flutter test`
       All tests must pass. If any test previously used `ProviderScope.overrides` to inject a
       mock because global wiring was remote (see STATE.md decision "[Phase 02-data-layer]:
       Widget tests must use ProviderScope.overrides..."), those overrides are now redundant but
       harmless — do not remove them; tests should still pass as-is.

    3. Commit with the exact message:
       `fix(data): restore mock datasources for Phase 3 UAT`

       Stage only: `lib/shared/providers/repository_providers.dart`
  </action>
  <verify>
    <automated>cd C:/dev/fiyatcep && flutter analyze && flutter test</automated>
  </verify>
  <done>
    `flutter analyze` exits 0. `flutter test` exits 0. Commit created with the prescribed
    message containing only repository_providers.dart.
  </done>
</task>

</tasks>

<verification>
After both tasks complete:
- `grep MockDataSourceImpl lib/shared/providers/repository_providers.dart` returns 3 matches
  (one per feature).
- `grep RemoteDataSourceImpl lib/shared/providers/repository_providers.dart` still returns 3
  matches (remote providers retained).
- `flutter analyze` exits 0.
- `flutter test` exits 0.
</verification>

<success_criteria>
The app serves products, markets, and discounts from mock data. No network calls are made to
the API. The remote datasource providers and all remote datasource class files are intact.
Phase 3 UAT can proceed without a live backend.
</success_criteria>

<output>
No SUMMARY.md needed for a quick task. The commit itself serves as the record.
</output>
