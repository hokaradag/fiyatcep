# Phase 2: Data Layer - Context

**Gathered:** 2026-03-28 (discuss mode)
**Status:** Ready for planning

<domain>
## Phase Boundary

Wire the real scraping backend API into the Flutter app; extend ProductItem with price history; convert DiscountItem.validUntil to DateTime; activate market detail product loading by market. No new user-facing UI features — this phase is data plumbing and model extension.

Covers: activate remote datasources (products, markets, discounts), define API contract, create PricePoint Freezed model, extend ProductItem with priceHistory, convert DiscountItem.validUntil String → DateTime, add getProductsByMarket() datasource method, update repository_providers.dart to wire remote datasources.

</domain>

<decisions>
## Implementation Decisions

### API Contract & Base URL
- **D-01:** Base URL is hardcoded in `lib/shared/providers/api_client_provider.dart` — replace the placeholder with the real backend URL. No build flavor or config file. Single source of truth.
- **D-02:** API version prefix: `/api/v1/...` — keep the existing convention.
- **D-03:** No pagination for v1 — backend returns full lists for `/products`, `/markets`, `/discounts`. Pagination is deferred to v2 (PERF-V2-01).
- **D-04:** Error response shape: `{"error": {"code": "NOT_FOUND", "message": "..."}}` — structured error object. Remote datasource `_handleDioException()` methods must parse `e.response?.data['error']['message']` and map `code` to typed AppException subtypes.
- **D-05:** No API spec exists yet — Flutter defines the contract here; backend implements to match.

### PricePoint Model
- **D-06:** New Freezed model `PricePoint` with exactly two fields: `price: double` and `date: DateTime`. Lives at `lib/features/products/models/price_point.dart`.
- **D-07:** Backend date format: ISO 8601 string (`"2026-03-28T14:00:00Z"`) for ALL date fields (PricePoint.date and DiscountItem.validUntil). Dart's `DateTime.parse()` handles this natively.
- **D-08:** Price history is inline in the product object: `{"id":"...", "priceHistory": [{"price": 10.5, "date": "2026-03-28T14:00:00Z"}]}`. Single API call returns product + history together.
- **D-09:** `ProductItem` gets `List<PricePoint> priceHistory` added as a Freezed field — default to empty list (`@Default([])`) so existing UI code doesn't break.

### DiscountItem Date Migration
- **D-10:** `DiscountItem.validUntil` changes from `String` to `DateTime`. Backend sends ISO 8601 string; Freezed uses a custom `fromJson` converter (`DateTime.parse(json['validUntil'] as String)`).
- **D-11:** Existing `discountAmount` and `discountPercent` computed getters are unaffected. UI display of validUntil uses `DateFormat` or manual formatting — formatter choice is Claude's discretion.

### Market Products Endpoint (MKTD-02)
- **D-12:** Backend endpoint: `GET /products?marketId={slug}` — query param on the existing products endpoint, not a nested route.
- **D-13:** Market IDs are slug strings: `migros`, `a101`, `bim`, `carrefoursa`, `sok`, `tarim-kredi`, `file-market`. Human-readable, no UUID mapping table needed.
- **D-14:** Add `getProductsByMarket(String marketId)` method to `ProductRemoteDataSource` abstract class and `ProductRemoteDataSourceImpl`. This method calls `GET /products?marketId={marketId}`.

### Datasource Swap Strategy
- **D-15:** Full swap — `repository_providers.dart` wires all three datasources to their `*RemoteDataSourceImpl` implementations. TODO comments are removed. Mock datasource files remain in the codebase (still used by unit tests).
- **D-16:** No mock fallback toggle, no feature flag. Clean cut to real data.
- **D-17:** On backend unreachable: existing error state + retry button. The typed error handling from Phase 1 (QUAL-02) already covers this via `AsyncValue.error` + `ref.invalidate()`. No new work needed.

### Claude's Discretion
- Exact `DateFormat` pattern for displaying `DiscountItem.validUntil` in the UI (e.g., `dd MMM yyyy` or `d MMMM yyyy`)
- Whether to add a `displayDate` computed getter to `DiscountItem` or handle formatting at the widget layer
- Order of datasource activation (all at once or sequential — all at once is fine given same pattern)
- JSON field name casing convention for priceHistory (camelCase assumed to match existing API stubs)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Requirements
- `.planning/REQUIREMENTS.md` §Data Layer — DATA-01 through DATA-04, MKTD-02 acceptance criteria
- `.planning/PROJECT.md` §Constraints — "yeni bağımlılıklar minimize edilecek", tech stack constraints

### Existing Data Layer (critical files to read before modifying)
- `lib/features/products/data/datasources/product_datasource.dart` — Abstract interface; add `getProductsByMarket()` here
- `lib/features/products/data/datasources/product_remote_datasource.dart` — Stub implementation to extend and activate
- `lib/features/products/data/datasources/product_mock_datasource.dart` — Must remain unchanged (used by unit tests)
- `lib/features/markets/data/datasources/market_remote_datasource.dart` — Activate (currently wired to mock)
- `lib/features/discounts/data/datasources/discount_remote_datasource.dart` — Activate; update error parsing
- `lib/features/products/data/repositories/product_repository_impl.dart` — Will need `getProductsByMarket()` delegation

### Models to modify
- `lib/features/products/models/product_item.dart` — Add `List<PricePoint> priceHistory` field
- `lib/features/discounts/models/discount_item.dart` — Change `validUntil: String` → `validUntil: DateTime`

### Configuration & wiring
- `lib/shared/providers/repository_providers.dart` — All three TODO comments → replace mock with remote datasource
- `lib/shared/providers/api_client_provider.dart` — Replace placeholder base URL with real backend URL

### Architecture context
- `.planning/codebase/ARCHITECTURE.md` — Datasource pattern, Result<T> type, error handling chain
- `.planning/codebase/INTEGRATIONS.md` — Current endpoint stubs, HTTP client config, response format `{"data": [...]}`

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `ProductRemoteDataSourceImpl` (`lib/features/products/data/datasources/product_remote_datasource.dart`): Already handles `/products`, `/products/{id}`, `/products/search`. Only needs `getProductsByMarket()` and error parsing update.
- `MarketRemoteDataSourceImpl` and `DiscountRemoteDataSourceImpl`: Both are complete stubs — activation is purely a wiring change in `repository_providers.dart`.
- `_handleDioException()` pattern: All three remote datasources have this private method. Update all three to parse `data['error']['message']` instead of `data['message']`.
- Freezed code generation: `product_item.freezed.dart` and `product_item.g.dart` will be regenerated by `flutter pub run build_runner build`. Same for discount_item and new price_point.

### Established Patterns
- Remote datasource pattern: `ApiClient.get(endpoint:, fromJson:)` → map JSON list to model list. PricePoint mapping follows the same `list.cast<Map<String, dynamic>>().map(PricePoint.fromJson).toList()` pattern.
- Repository wiring: `Provider<X>((ref) { return XRemoteDataSourceImpl(apiClient: ref.watch(apiClientProvider)); })` in `repository_providers.dart` — the TODO comments show exactly where to change.
- Freezed `@Default([])`: Used for optional list fields in existing models — apply same for `priceHistory`.

### Integration Points
- `lib/features/markets/presentation/pages/market_detail_page.dart`: Currently loads products from `productsProvider`. After DATA-02, it should call a new `productsByMarketProvider(marketId)` that uses `getProductsByMarket()`.
- `lib/features/discounts/presentation/`: Any widget displaying `validUntil` needs updated display logic after the String → DateTime migration.

</code_context>

<specifics>
## Specific Ideas

No specific references — decisions above define the full contract.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

### Reviewed Todos (not folded)
None — no pending todos matched this phase.

</deferred>

---

*Phase: 02-data-layer*
*Context gathered: 2026-03-28*
