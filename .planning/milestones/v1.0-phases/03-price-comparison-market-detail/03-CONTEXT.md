# Phase 3: Price Comparison + Market Detail - Context

**Gathered:** 2026-03-29 (discuss mode)
**Status:** Ready for planning

<domain>
## Phase Boundary

Kullanıcı bir ürünün tüm marketlerdeki fiyatlarını ve geçmiş fiyat trendini görebilir; market detay sayfası görsel olarak zenginleştirilmiştir.

Covers: price comparison rows with price diff in ProductDetailPage (COMP-01), price history line chart with time selectors (COMP-02), market branding (logo/banner/color) in MarketDetailPage (MKTD-01).

Does NOT cover: cart comparison (Phase 4), push notifications (Phase 5), loyalty program details (v2).

</domain>

<decisions>
## Implementation Decisions

### Chart Library
- **D-01:** Add `fl_chart` as a new dependency for the price history chart. It is the only justified new library for this phase — CustomPainter alternative would require 200-300+ lines of fragile canvas code for touch-based tooltip interaction.
- **D-02:** Use `LineChart` from fl_chart with `LineTouchData` for tooltip support. Touch on any point shows exact price.

### Market Branding Source
- **D-03:** Brand colors, logos, and banners are hardcoded in Flutter as a static `Map<String, MarketBrand>` in a new `market_brand_config.dart` file. No backend changes, no MarketItem model extension. 7 markets defined at launch (migros, a101, bim, carrefoursa, sok, tarim-kredi, file-market).
- **D-04:** `MarketBrand` is a simple plain Dart class (not Freezed) with: `Color primaryColor`, `String logoAsset`, `String bannerAsset`. Logo and banner images stored in `assets/logos/` and `assets/banners/` respectively.
- **D-05:** `MarketDetailHeaderWidget` reads brand from the config map using `market.id` as key. Fallback: generic icon + grey color when market id not found.

### Price Difference Display (COMP-01)
- **D-06:** `ProductPriceSection` extended to show absolute TL price difference for non-cheapest markets: `+X.XX ₺` in a muted color. Percentage is NOT shown — TL difference is more intuitive for shopping decisions.
- **D-07:** Cheapest market row unchanged: shows "En Uygun" badge + green color. Non-cheapest rows add a small `+X.XX ₺` label next to the price.

### Price History Chart Time Ranges (COMP-02)
- **D-08:** Time range labels: 1H = 1 Hafta, 1A = 1 Ay, 3A = 3 Ay, 1Y = 1 Yıl.
- **D-09:** If the backend does not return data for a given range (e.g., not enough history for 1Y), that tab is shown as disabled/grayed-out. User cannot tap disabled tabs.
- **D-10:** If NO price history exists at all (priceHistory is empty), show an empty state message: "Fiyat geçmişi henüz mevcut değil" instead of the chart widget.
- **D-11:** Default selected range: 1A (1 month) — most relevant for routine shopping decisions.

### Widget Architecture
- **D-12:** Price history chart lives in a new `ProductPriceHistorySection` widget (`lib/features/products/widgets/product_price_history_section.dart`). It replaces the existing placeholder text in `ProductDetailPage`.
- **D-13:** Market branding enhancement lives in the existing `MarketDetailHeaderWidget` — no new widget file needed, just update the existing one to render logo + banner + brand color.

### Claude's Discretion
- Exact fl_chart version pinned (latest stable at implementation time)
- Visual styling of the chart (grid lines, dot radius, stroke width, color)
- Exact layout of the market detail header with banner (full-width banner image above info card, or side logo)
- Tooltip format: `"XX.XX ₺\ndd MMM"` vs just `"XX.XX ₺"` with date in subtitle
- How to handle missing logo/banner assets gracefully (placeholder color block vs icon)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Requirements
- `.planning/REQUIREMENTS.md` §Price Comparison — COMP-01, COMP-02 acceptance criteria
- `.planning/REQUIREMENTS.md` §Market Detail — MKTD-01 acceptance criteria
- `.planning/PROJECT.md` §Constraints — "yeni bağımlılıklar minimize edilecek", tech stack constraints

### Existing UI Code (read before modifying)
- `lib/features/products/product_detail_page.dart` — Current page structure; chart section replaces placeholder text block
- `lib/features/products/widgets/product_price_section.dart` — Existing price rows widget to extend with price diff
- `lib/features/markets/market_detail_page.dart` — Market detail page structure
- `lib/features/markets/widgets/market_detail_header_widget.dart` — Header widget to extend with branding

### Models
- `lib/features/products/models/market_price_item.dart` — MarketPriceItem (marketId, market, price, isDiscounted) — used in price comparison
- `lib/features/products/models/price_point.dart` — PricePoint (price, date) — used in chart
- `lib/features/products/models/product_item.dart` — ProductItem with `List<PricePoint> priceHistory` field
- `lib/features/markets/models/market_item.dart` — MarketItem; NOT extended for branding (hardcode approach chosen)

### Providers
- `lib/features/products/presentation/providers/products_provider.dart` — `productMarketPricesProvider(productId)` already wired

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `ProductPriceSection` (`lib/features/products/widgets/product_price_section.dart`): Already handles sorted list, "En Uygun" badge, "İndirimli" badge, Card layout per market. Extend with `+X.XX ₺` diff label — minimal change.
- `productMarketPricesProvider(product.id)`: Returns `List<MarketPriceItem>` sorted cheapest-first. Index 0 = cheapest. Price diff = `item.price - prices[0].price`.
- `ProductItem.priceHistory`: Already a `List<PricePoint>` with `@Default([])` (Phase 2). Chart widget reads this directly — no new provider needed.
- `MarketDetailHeaderWidget`: Already has the Card structure and brand chips. Logo/banner replaces or augments the top of the card.

### Established Patterns
- Widget decomposition: new widgets go in `lib/features/{feature}/widgets/` as `*_section.dart` or `*_widget.dart`
- Riverpod: `ref.watch(provider)` in ConsumerWidget; error state with retry button pattern already in `ProductDetailPage`
- Freezed models: don't add new fields to `MarketItem` (hardcode approach chosen — no Freezed regen needed for branding)
- Asset registration: new `assets/logos/` and `assets/banners/` directories must be registered in `pubspec.yaml` under `flutter: assets:`

### Integration Points
- `ProductDetailPage` line ~35: placeholder text block `"Bu alan ileride..."` — replace with `ProductPriceHistorySection(priceHistory: product.priceHistory)`
- `MarketDetailHeaderWidget.build()`: top of card — add banner image and logo rendering using `marketBrands[market.id]`
- `pubspec.yaml`: add `fl_chart: ^0.69.0` (or latest stable) and asset directories

</code_context>

<specifics>
## Specific Ideas

No specific external references — open to standard fl_chart LineChart patterns.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

### Reviewed Todos (not folded)
None — no pending todos matched this phase.

</deferred>

---

*Phase: 03-price-comparison-market-detail*
*Context gathered: 2026-03-29*
