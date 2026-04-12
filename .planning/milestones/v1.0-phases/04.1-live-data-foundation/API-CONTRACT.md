# FiyatCep API Contract

Phase 04.1: Live Data Foundation
Frozen contract — Phase 04.2 (backend) and Phase 04.3 (Flutter) implement against this.
Do not modify without explicit revision. (D-09)

---

## Base URL

```
{BASE_URL}/api/v1
```

The placeholder `BASE_URL` is replaced with the real backend URL in Phase 04.3 by updating
`lib/shared/providers/api_client_provider.dart` (currently `https://api.example.com/api/v1`).

---

## Response Envelope

All responses use a consistent envelope pattern. Flutter's `ApiClient` extracts `json['data']`
in every `fromJson` callback. This pattern is locked (D-10) — do not deviate.

**List response:**
```json
{ "data": [ { "..." }, { "..." } ] }
```

**Single-item response:**
```json
{ "data": { "..." } }
```

**Error response:**
```json
{ "error": { "message": "Not found", "code": "NOT_FOUND" } }
```

Flutter's `_handleDioException` extracts `error.message` and `error.code` from the error
envelope. Both fields are required for correct exception classification.

---

## Endpoints

### Products

#### 1. `GET /products` — List all products

Returns all products across all markets, each with embedded price history.

**Query parameters (all optional):**

| Parameter  | Type   | Description                                             |
|------------|--------|---------------------------------------------------------|
| `marketId` | string | Market slug — filters results to one market (see §1a)   |
| `limit`    | int    | Maximum number of records to return (v1: may be ignored)|
| `offset`   | int    | Number of records to skip for pagination (v1: may be ignored) |

**Response:** `200 OK`
```json
{
  "data": [
    {
      "id": "mp-migros-001",
      "marketId": "migros",
      "name": "Aycicek Yagi 1L",
      "brand": "Yudum",
      "market": "Migros",
      "price": 74.95,
      "isDiscounted": true,
      "priceHistory": [
        { "price": 76.50, "date": "2026-03-15T00:00:00.000Z" },
        { "price": 76.50, "date": "2026-03-22T00:00:00.000Z" },
        { "price": 74.95, "date": "2026-03-28T00:00:00.000Z" }
      ]
    },
    {
      "id": "mp-migros-002",
      "marketId": "migros",
      "name": "Sut 1L",
      "brand": "Pinar",
      "market": "Migros",
      "price": 32.50,
      "isDiscounted": false,
      "priceHistory": [
        { "price": 30.00, "date": "2026-03-01T00:00:00.000Z" },
        { "price": 32.50, "date": "2026-03-20T00:00:00.000Z" }
      ]
    }
  ]
}
```

> **priceHistory is MANDATORY in ALL product responses** (D-11). Do NOT omit it as a
> performance optimization for list endpoints. Flutter's `ProductItem` has `@Default([])`
> so deserialization succeeds silently if the field is missing — but the price history chart
> will show no data. See Notes §5.

Field reference (`ProductItem` Dart model):

| JSON field     | Dart type         | Maps from DB                                  |
|----------------|-------------------|-----------------------------------------------|
| `id`           | String            | `market_products.id`                          |
| `marketId`     | String            | `market_products.market_id`                   |
| `name`         | String            | `products.name`                               |
| `brand`        | String            | `products.brand`                              |
| `market`       | String            | `markets.name`                                |
| `price`        | double            | `market_products.current_price`               |
| `isDiscounted` | bool              | `market_products.is_discounted` (0/1 → bool)  |
| `priceHistory` | List\<PricePoint\>| `price_history` rows for this market_product  |

`priceHistory` items sorted ascending by `recorded_at` (oldest first).

---

#### 1a. `GET /products?marketId={slug}` — Products filtered by market

This is the same endpoint as §1 (`GET /products`) with the `marketId` query parameter.
It is NOT a separate route. Flutter calls this via `ProductRemoteDataSourceImpl.getProductsByMarket()`.

**Example:** `GET /products?marketId=migros`

Response shape is identical to §1. Each product in the response belongs to the specified market.

Valid `marketId` values: `migros`, `a101`, `bim`, `carrefoursa`, `sok`, `tarim-kredi`, `file-market`

---

#### 2. `GET /products/{id}` — Get single product

Returns a single product with its full price history for that market listing.

**Path parameter:**

| Parameter | Type   | Description                                             |
|-----------|--------|---------------------------------------------------------|
| `id`      | string | `market_products.id` — same as `ProductItem.id` in Flutter |

**Response:** `200 OK`
```json
{
  "data": {
    "id": "mp-migros-001",
    "marketId": "migros",
    "name": "Aycicek Yagi 1L",
    "brand": "Yudum",
    "market": "Migros",
    "price": 74.95,
    "isDiscounted": true,
    "priceHistory": [
      { "price": 79.90, "date": "2026-01-10T00:00:00.000Z" },
      { "price": 78.50, "date": "2026-02-01T00:00:00.000Z" },
      { "price": 76.50, "date": "2026-03-15T00:00:00.000Z" },
      { "price": 76.50, "date": "2026-03-22T00:00:00.000Z" },
      { "price": 74.95, "date": "2026-03-28T00:00:00.000Z" }
    ]
  }
}
```

**Error:** `404 Not Found`
```json
{ "error": { "message": "Product not found", "code": "NOT_FOUND" } }
```

---

#### 3. `GET /products/search?q={query}` — Search products

Searches `products.name` and `products.brand` in the canonical product catalog. Returns all
`market_products` rows for matching canonical products, each with `priceHistory`.

**Query parameters:**

| Parameter | Type   | Required | Description                                |
|-----------|--------|----------|--------------------------------------------|
| `q`       | string | yes      | Search term                                |

**Response:** `200 OK`
```json
{
  "data": [
    {
      "id": "mp-migros-001",
      "marketId": "migros",
      "name": "Aycicek Yagi 1L",
      "brand": "Yudum",
      "market": "Migros",
      "price": 74.95,
      "isDiscounted": true,
      "priceHistory": [
        { "price": 76.50, "date": "2026-03-22T00:00:00.000Z" },
        { "price": 74.95, "date": "2026-03-28T00:00:00.000Z" }
      ]
    },
    {
      "id": "mp-a101-001",
      "marketId": "a101",
      "name": "Aycicek Yagi 1L",
      "brand": "Yudum",
      "market": "A101",
      "price": 79.90,
      "isDiscounted": false,
      "priceHistory": [
        { "price": 79.90, "date": "2026-03-20T00:00:00.000Z" }
      ]
    }
  ]
}
```

Empty query (`q=`) returns an empty list `{ "data": [] }`.

---

#### 4. `GET /products/{id}/prices` — Cross-market prices (NEW — D-05)

Returns current prices for the same product across all markets where it is listed.

> **CRITICAL — ID semantics:** The `{id}` path parameter is `market_products.id`
> (the same value as `ProductItem.id` in Flutter). The backend resolves `products.id`
> internally by looking up the `market_products` row, then fetches `current_price` from all
> `market_products` rows sharing that canonical `product_id`. Flutter never sends or receives
> `products.id` directly (D-02, D-05).

> **WARNING for Phase 04.2 implementors:** Do NOT implement this as a lookup by `products.id`.
> Flutter always sends `market_products.id`. The correct backend query is:
> ```sql
> SELECT mp.market_id, m.name as market_name, mp.current_price, mp.is_discounted
> FROM market_products mp
> JOIN markets m ON mp.market_id = m.id
> WHERE mp.product_id = (
>   SELECT product_id FROM market_products WHERE id = :market_products_id
> )
> ```

**Path parameter:**

| Parameter | Type   | Description                                                    |
|-----------|--------|----------------------------------------------------------------|
| `id`      | string | `market_products.id` — NOT `products.id` (internal backend ID)|

**Response:** `200 OK`
```json
{
  "data": [
    { "marketId": "migros",      "market": "Migros",      "price": 74.95, "isDiscounted": true  },
    { "marketId": "a101",        "market": "A101",         "price": 79.90, "isDiscounted": false },
    { "marketId": "bim",         "market": "BIM",          "price": 77.50, "isDiscounted": false },
    { "marketId": "carrefoursa", "market": "CarrefourSA",  "price": 75.00, "isDiscounted": true  },
    { "marketId": "sok",         "market": "SOK",          "price": 78.00, "isDiscounted": false }
  ]
}
```

Field reference (`MarketPriceItem` Dart model):

| JSON field     | Dart type | Maps from DB                                 |
|----------------|-----------|----------------------------------------------|
| `marketId`     | String    | `market_products.market_id`                  |
| `market`       | String    | `markets.name`                               |
| `price`        | double    | `market_products.current_price`              |
| `isDiscounted` | bool      | `market_products.is_discounted` (0/1 → bool) |

Note: `MarketPriceItem` has no `id` field — this is an aggregation result, not a stored entity.

This endpoint is consumed by `productMarketPricesProvider` in Phase 04.3 (D-07). The Flutter
abstract method `Future<List<MarketPriceItem>> getProductPrices(String productId)` is added to
`ProductRemoteDataSource` in Phase 04.3 (D-06).

**Error:** `404 Not Found`
```json
{ "error": { "message": "Product not found", "code": "NOT_FOUND" } }
```

---

### Markets

#### 5. `GET /markets` — List all markets

Returns all 7 market chains.

**Query parameters (all optional):**

| Parameter | Type | Description                                              |
|-----------|------|----------------------------------------------------------|
| `limit`   | int  | Maximum number of records to return (v1: may be ignored) |
| `offset`  | int  | Number of records to skip (v1: may be ignored)           |

**Response:** `200 OK`
```json
{
  "data": [
    {
      "id": "migros",
      "name": "Migros",
      "description": "Turkiyenin koklu supermarket zinciri",
      "branchCount": 2500,
      "activeDiscountCount": 47,
      "supportsOnlineOrder": true,
      "hasLoyaltyProgram": true
    },
    {
      "id": "a101",
      "name": "A101",
      "description": "Turkiyenin en yaygin indirim marketi",
      "branchCount": 11000,
      "activeDiscountCount": 123,
      "supportsOnlineOrder": false,
      "hasLoyaltyProgram": false
    },
    {
      "id": "bim",
      "name": "BIM",
      "description": "Her mahallede bulunan indirim marketi",
      "branchCount": 10500,
      "activeDiscountCount": 89,
      "supportsOnlineOrder": false,
      "hasLoyaltyProgram": false
    },
    {
      "id": "carrefoursa",
      "name": "CarrefourSA",
      "description": "Fransiz kokenli hipermarket zinciri",
      "branchCount": 700,
      "activeDiscountCount": 34,
      "supportsOnlineOrder": true,
      "hasLoyaltyProgram": true
    },
    {
      "id": "sok",
      "name": "SOK",
      "description": "Hizla buyuyen indirim market zinciri",
      "branchCount": 9000,
      "activeDiscountCount": 67,
      "supportsOnlineOrder": false,
      "hasLoyaltyProgram": false
    },
    {
      "id": "tarim-kredi",
      "name": "Tarim Kredi",
      "description": "Kooperatif tabanli market zinciri",
      "branchCount": 2000,
      "activeDiscountCount": 12,
      "supportsOnlineOrder": false,
      "hasLoyaltyProgram": false
    },
    {
      "id": "file-market",
      "name": "File Market",
      "description": "Bolgesel supermarket zinciri",
      "branchCount": 500,
      "activeDiscountCount": 8,
      "supportsOnlineOrder": false,
      "hasLoyaltyProgram": false
    }
  ]
}
```

Field reference (`MarketItem` Dart model):

| JSON field             | Dart type | Maps from DB                                         |
|------------------------|-----------|------------------------------------------------------|
| `id`                   | String    | `markets.id` (slug)                                  |
| `name`                 | String    | `markets.name`                                       |
| `description`          | String    | `markets.description`                                |
| `branchCount`          | int       | `markets.branch_count`                               |
| `activeDiscountCount`  | int       | `markets.active_discount_count` (denormalized)       |
| `supportsOnlineOrder`  | bool      | `markets.supports_online_order` (0/1 → bool)         |
| `hasLoyaltyProgram`    | bool      | `markets.has_loyalty_program` (0/1 → bool)           |

Note: `activeDiscountCount` is a denormalized counter. The scraper must UPDATE
`markets.active_discount_count` after each scrape cycle (see DB-SCHEMA.sql Notes section).

---

#### 6. `GET /markets/{id}` — Get single market

**Path parameter:**

| Parameter | Type   | Description                                                        |
|-----------|--------|--------------------------------------------------------------------|
| `id`      | string | Market slug: `migros`, `a101`, `bim`, `carrefoursa`, `sok`, `tarim-kredi`, `file-market` |

**Response:** `200 OK`
```json
{
  "data": {
    "id": "migros",
    "name": "Migros",
    "description": "Turkiyenin koklu supermarket zinciri",
    "branchCount": 2500,
    "activeDiscountCount": 47,
    "supportsOnlineOrder": true,
    "hasLoyaltyProgram": true
  }
}
```

**Error:** `404 Not Found`
```json
{ "error": { "message": "Market not found", "code": "NOT_FOUND" } }
```

---

#### 7. `GET /markets/search?q={query}` — Search markets

Searches `markets.name`.

**Query parameters:**

| Parameter | Type   | Required | Description  |
|-----------|--------|----------|--------------|
| `q`       | string | yes      | Search term  |

**Response:** `200 OK`
```json
{
  "data": [
    {
      "id": "migros",
      "name": "Migros",
      "description": "Turkiyenin koklu supermarket zinciri",
      "branchCount": 2500,
      "activeDiscountCount": 47,
      "supportsOnlineOrder": true,
      "hasLoyaltyProgram": true
    }
  ]
}
```

---

### Discounts

#### 8. `GET /discounts` — List all active discounts

Returns all currently active discount records (`discounts.is_active = 1`).

**Query parameters (all optional):**

| Parameter  | Type   | Description                                                  |
|------------|--------|--------------------------------------------------------------|
| `marketId` | string | Market slug — filters results to one market (see §8a)        |
| `limit`    | int    | Maximum number of records to return (v1: may be ignored)     |
| `offset`   | int    | Number of records to skip (v1: may be ignored)               |

**Response:** `200 OK`
```json
{
  "data": [
    {
      "id": "d-001",
      "productId": "mp-migros-001",
      "marketId": "migros",
      "productName": "Aycicek Yagi 1L",
      "marketName": "Migros",
      "oldPrice": 79.90,
      "newPrice": 74.95,
      "validUntil": "2026-04-15T00:00:00.000Z",
      "note": "Haftalik indirim"
    },
    {
      "id": "d-002",
      "productId": "mp-migros-002",
      "marketId": "migros",
      "productName": "Sut 1L",
      "marketName": "Migros",
      "oldPrice": 35.00,
      "newPrice": 32.50,
      "validUntil": "2026-04-10T00:00:00.000Z",
      "note": null
    }
  ]
}
```

Field reference (`DiscountItem` Dart model):

| JSON field    | Dart type | Maps from DB                                                    |
|---------------|-----------|-----------------------------------------------------------------|
| `id`          | String    | `discounts.id`                                                  |
| `productId`   | String    | `discounts.market_product_id` (= `market_products.id`)          |
| `marketId`    | String    | `market_products.market_id` (resolved via JOIN)                 |
| `productName` | String    | `products.name` (resolved via JOIN)                             |
| `marketName`  | String    | `markets.name` (resolved via JOIN)                              |
| `oldPrice`    | double    | `discounts.old_price`                                           |
| `newPrice`    | double    | `discounts.new_price`                                           |
| `validUntil`  | DateTime  | `discounts.valid_until` (ISO 8601 UTC string)                   |
| `note`        | String?   | `discounts.note` — nullable; may be `null` or absent in JSON    |

Note: `productId` in Flutter's `DiscountItem` maps to `market_products.id` — the same value
as `ProductItem.id`. This is NOT `products.id` (which is internal to the backend).

---

#### 8a. `GET /discounts?marketId={slug}` — Discounts filtered by market

This is the same endpoint as §8 (`GET /discounts`) with the `marketId` query parameter.

**Example:** `GET /discounts?marketId=bim`

Response shape is identical to §8. Only discounts where `market_products.market_id = {slug}` are returned.

---

#### 9. `GET /discounts/search?q={query}` — Search discounts

Searches `products.name` (via JOIN) for discounts.

**Query parameters:**

| Parameter | Type   | Required | Description  |
|-----------|--------|----------|--------------|
| `q`       | string | yes      | Search term  |

**Response:** `200 OK`
```json
{
  "data": [
    {
      "id": "d-001",
      "productId": "mp-migros-001",
      "marketId": "migros",
      "productName": "Aycicek Yagi 1L",
      "marketName": "Migros",
      "oldPrice": 79.90,
      "newPrice": 74.95,
      "validUntil": "2026-04-15T00:00:00.000Z",
      "note": "Haftalik indirim"
    }
  ]
}
```

---

## Error Responses

All error responses use the locked envelope format:

```json
{ "error": { "message": "...", "code": "..." } }
```

Flutter's `_handleDioException` in all three remote datasource implementations extracts
`error.message` and `error.code`. Both fields are required.

**Standard error codes:**

| HTTP Status | `code`           | `message` (example)          | Flutter exception type  |
|-------------|------------------|-------------------------------|-------------------------|
| 400         | `INVALID_PARAM`  | "Invalid market ID"           | `ClientException`       |
| 404         | `NOT_FOUND`      | "Product not found"           | `ClientException`       |
| 500         | `INTERNAL_ERROR` | "Internal server error"       | `ServerException`       |

**Examples:**

`400 Bad Request`:
```json
{ "error": { "message": "Invalid market ID", "code": "INVALID_PARAM" } }
```

`404 Not Found`:
```json
{ "error": { "message": "Product not found", "code": "NOT_FOUND" } }
```

`500 Internal Server Error`:
```json
{ "error": { "message": "Internal server error", "code": "INTERNAL_ERROR" } }
```

---

## Notes

### 1. DateTime format

All datetime fields (`date` in `PricePoint`, `validUntil` in `DiscountItem`) MUST be UTC ISO 8601
with Z suffix:

```
"2026-03-22T00:00:00.000Z"
```

Dart's `DateTime.parse()` treats strings without Z as local time, not UTC. Flutter's `PricePoint`
uses `DateTime.utc()` throughout. Backend must emit UTC strings — Python equivalent:
`datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%S.000Z')` or a timezone-aware datetime object in UTC.

Strings like `"2026-03-22"`, `"2026-03-22T00:00:00"` (no Z), or `"22 Mart 2026"` are incorrect.

### 2. JSON field names

All field names are camelCase, matching Dart field names exactly. Flutter models use
`json_serializable` with NO `@JsonKey` overrides — the Dart field name IS the JSON key.

**Do NOT use snake_case.** `market_id` will silently deserialize to null; `marketId` is correct.

Affected fields: `marketId`, `isDiscounted`, `priceHistory`, `validUntil`, `oldPrice`, `newPrice`,
`branchCount`, `activeDiscountCount`, `supportsOnlineOrder`, `hasLoyaltyProgram`, `productId`,
`productName`, `marketName`.

### 3. ID semantics

| Flutter field              | Maps to                  | Never maps to     |
|----------------------------|--------------------------|-------------------|
| `ProductItem.id`           | `market_products.id`     | `products.id`     |
| `DiscountItem.productId`   | `market_products.id`     | `products.id`     |
| `MarketItem.id`            | `markets.id` (slug)      | —                 |

The canonical `products.id` is internal to the backend. Flutter never sees it.

### 4. Pagination (optional, v1 deferred)

List endpoints accept optional `limit` (int) and `offset` (int) query parameters. If omitted,
all records are returned. v1 backend implementations may ignore these parameters.

Pagination is explicitly out of scope for v1 per REQUIREMENTS.md (PERF-V2-01). These params are
defined in the contract so Phase 04.2 can add them later without a contract revision.

### 5. priceHistory embedding (D-11)

`priceHistory` is embedded in ALL product responses — list endpoints (`GET /products`,
`GET /products?marketId=...`), search (`GET /products/search`), and detail (`GET /products/{id}`).

- The array is per `market_products` row (not per canonical product)
- Sorted ascending by `recorded_at` (oldest first)
- Contains all available history points for that market listing
- If no history exists yet, return an empty array: `"priceHistory": []`

Phase 04.2 may add a configurable cap (e.g., last 365 days) only as an explicit contract revision.

### 6. Frozen contract (D-09)

Phase 04.2 implements the backend against `DB-SCHEMA.sql`.
Phase 04.3 implements Flutter integration against this `API-CONTRACT.md`.

Neither phase changes the contract without explicit revision to these documents.

---

## Endpoint Summary

| # | Method | Path                       | Flutter datasource method         | Model returned        |
|---|--------|----------------------------|-----------------------------------|-----------------------|
| 1 | GET    | /products                  | `getAllProducts()`                 | `List<ProductItem>`   |
| 1a| GET    | /products?marketId={slug}  | `getProductsByMarket(marketId)`    | `List<ProductItem>`   |
| 2 | GET    | /products/{id}             | `getProductById(id)`               | `ProductItem`         |
| 3 | GET    | /products/search?q={query} | `searchProducts(query)`            | `List<ProductItem>`   |
| 4 | GET    | /products/{id}/prices      | `getProductPrices(productId)` (D-06, Phase 04.3) | `List<MarketPriceItem>` |
| 5 | GET    | /markets                   | `getAllMarkets()`                   | `List<MarketItem>`    |
| 6 | GET    | /markets/{id}              | `getMarketById(id)`                | `MarketItem`          |
| 7 | GET    | /markets/search?q={query}  | `searchMarkets(query)`             | `List<MarketItem>`    |
| 8 | GET    | /discounts                 | `getAllDiscounts()`                 | `List<DiscountItem>`  |
| 8a| GET    | /discounts?marketId={slug} | `getDiscountsByMarket(marketId)`    | `List<DiscountItem>`  |
| 9 | GET    | /discounts/search?q={query}| `searchDiscounts(query)`            | `List<DiscountItem>`  |

Total: 9 distinct routes (11 when counting query-param variants as separate use cases).
