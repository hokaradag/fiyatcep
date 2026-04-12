# Phase 2: Data Layer - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions captured in CONTEXT.md — this log preserves the discussion.

**Date:** 2026-03-28
**Phase:** 02-data-layer
**Mode:** discuss
**Areas covered:** API contract & base URL config, PricePoint model design, Market products endpoint (MKTD-02), Datasource swap & fallback strategy

---

## Discussion Log

### API contract & base URL config

| Question | Options presented | Selected |
|----------|-------------------|----------|
| How should the real backend base URL be configured? | Hardcode in api_client_provider.dart / --dart-define / config file | **Hardcode in api_client_provider.dart** |
| Is there an API spec or contract document? | No spec / backend README / match existing patterns | **No spec — define contract here** |
| API versioning prefix? | /api/v1/ / /api/ / You decide | **/api/v1/** |
| Pagination strategy? | No pagination (full list) / page+limit / cursor | **No pagination — full list** |
| Error response shape? | structured {error:{code,message}} / {message} / match stubs | **{error: {code, message}}** |

### PricePoint model design

| Question | Options presented | Selected |
|----------|-------------------|----------|
| PricePoint fields? | price+date only / price+date+marketId / price+date+marketId+source | **price + date only** |
| Date/time format? | ISO 8601 / Unix timestamp / date-only string | **ISO 8601 (2026-03-28T14:00:00Z)** |
| PricePoint location? | features/products/models/ / core/models/ | **lib/features/products/models/price_point.dart** |
| priceHistory in API response? | Inline in product / separate endpoint / You decide | **Inline in product object** |

### Market products endpoint (MKTD-02)

| Question | Options presented | Selected |
|----------|-------------------|----------|
| Backend endpoint pattern? | GET /products?marketId={id} / GET /markets/{id}/products | **GET /products?marketId={slug}** |
| Market ID format? | Slug strings / UUID/integer / numeric codes | **Slug strings (migros, a101, etc.)** |

### Datasource swap & fallback strategy

| Question | Options presented | Selected |
|----------|-------------------|----------|
| Mock fallback? | Full swap / feature flag toggle / env-based | **Full swap** |
| Backend unreachable UX? | Existing error state + retry / stale cache banner / You decide | **Existing error state + retry** |

---

## Corrections Made

No corrections — all decisions confirmed on first selection.

---

## User-added topics (resolved inline above)

- API versioning strategy → /api/v1/ (D-02)
- Pagination strategy → no pagination, full list (D-03)
- Error model consistency → {error: {code, message}} (D-04)
- Date/time format normalization → ISO 8601 for all date fields (D-07)
- Market ID standardization → slug strings (D-13)
