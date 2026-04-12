# Phase 4: Cart Comparison - Context

**Gathered:** 2026-03-30 (discuss mode)
**Status:** Ready for planning

<domain>
## Phase Boundary

Kullanıcı birden fazla ürünü sepete ekleyerek her market için toplam fiyatı ve eşleşme oranını karşılaştırabilir.

Covers: cart state (add/remove unique products, SharedPreferences persistence), cart navigation (AppBar icon + badge), cart comparison page (per-market total + match rate + partial match display).

Does NOT cover: push notifications (Phase 5), price history/trend chart (Phase 3), loyalty program details (v2), quantity management.

</domain>

<decisions>
## Implementation Decisions

### Cart Navigation
- **D-01:** Cart accessed via a cart icon with item-count badge in the AppBar of ProductsPage and ProductDetailPage. Tapping pushes CartComparisonPage via Navigator.push. The 5-tab bottom navigation remains unchanged — no 6th tab added.
- **D-02:** AppBar cart icon is only shown when the cart has at least one item (hidden when empty) — OR shown always with badge hidden when count is 0. Claude's discretion on exact visibility rule.

### Cart State & Persistence
- **D-03:** Cart is a set of unique products — `List<ProductItem>` (or equivalent). Adding the same product twice is a no-op. No quantity field. This matches the scope of COMP-03: "birden fazla ürün ekleyerek sepet oluşturabilir".
- **D-04:** Cart state persists across app restarts using SharedPreferences — same pattern as `FavoritesNotifier` (AsyncNotifier + SharedPreferences). Cart products stored as JSON-serialized list under a new key (e.g., `'cart_products'`).

### Add-to-Cart UX
- **D-05:** On ProductDetailPage, a "Sepete Ekle" button is added below the existing "Favorilere Ekle" button. When the product is already in cart, button reads "Sepetten Çıkar" (toggle, same pattern as favorites).
- **D-06:** Tapping "Sepete Ekle" shows a snackbar: "Ürün sepete eklendi" with a "Sepete Git" action button. User stays on ProductDetailPage to continue browsing. The "Sepete Git" action navigates to CartComparisonPage.

### Comparison Page Layout
- **D-07:** CartComparisonPage shows one card per market, sorted by total price ascending (cheapest first). The cheapest market with full or best match is highlighted (green / "En Uygun" badge).
- **D-08:** Each market card shows: market logo + name, match fraction ("7/9 ürün"), and total price. Cards are expandable: tapping reveals matched products (with price) and unmatched products (marked "bulunamadı").
- **D-09:** Cart product list is shown at the top of the page so users can review/remove items before comparing.

### Partial Match Display
- **D-10:** Markets with missing products show the partial total honestly: "7/9 ürün | 131,20 ₺\*" with a note below the total: "2 ürün bu markette bulunamadı". The asterisk (*) or muted color signals incompleteness. No markets are hidden — all 7 markets always appear.
- **D-11:** Sorting is by partial total (sum of available products). User is expected to read the match fraction and judge accordingly. No threshold-based hiding.

### Claude's Discretion
- Whether AppBar cart icon is always visible (badge hidden when 0) or only visible when cart has items
- Exact SharedPreferences key for cart data
- Whether CartComparisonPage has a "Sepeti Temizle" button or per-item swipe-to-remove, or both
- Visual styling of matched (✓) vs unmatched (✗) product rows in the expanded card
- How to match cart products to market inventory (by product.id against MarketPriceItem.productId)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Requirements
- `.planning/REQUIREMENTS.md` §Price Comparison — COMP-03 acceptance criteria (the sole requirement for this phase)
- `.planning/PROJECT.md` §Constraints — "yeni bağımlılıklar minimize edilecek", SharedPreferences already in use

### Existing Cart-Adjacent Code (read before implementing)
- `lib/features/favorites/presentation/providers/favorites_notifier.dart` — AsyncNotifier + SharedPreferences pattern; cart notifier follows this exactly
- `lib/features/favorites/data/favorites_store.dart` — SharedPreferences key pattern, JSON serialization of ProductItem list
- `lib/features/products/product_detail_page.dart` — Add "Sepete Ekle" button here, below favorites button (line ~50-75)
- `lib/features/products/products_page.dart` — Add cart AppBar icon here
- `lib/shared/main_navigation.dart` — Navigation structure; NOT modified (5 tabs unchanged)

### Models
- `lib/features/products/models/product_item.dart` — ProductItem (id, name, brand, category, priceHistory) — cart stores List<ProductItem>
- `lib/features/products/models/market_price_item.dart` — MarketPriceItem (marketId, market, price) — used to compute per-market totals
- `lib/features/markets/data/market_brand_config.dart` — MarketBrand config — used for logo/color in CartComparisonPage market cards

### Providers
- `lib/features/products/presentation/providers/products_provider.dart` — `productMarketPricesProvider(productId)` — reuse this to fetch prices per cart item per market
- `lib/shared/providers/` — where new `cartNotifierProvider` should be registered

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `FavoritesNotifier` (`lib/features/favorites/presentation/providers/favorites_notifier.dart`): AsyncNotifier with `build()` loading from SharedPreferences, `toggle()` method, `_saveToPrefs()`. Cart notifier copies this pattern almost exactly — `add()`, `remove()`, `clear()` instead of `toggle()`.
- `productMarketPricesProvider(productId)`: Returns `List<MarketPriceItem>` sorted cheapest-first. For cart comparison, call this for each cart product, then group by marketId to compute per-market totals.
- `MarketBrand` config (`lib/features/markets/data/market_brand_config.dart`): `marketBrands[marketId]` → logo, banner, color. Reuse for market cards in cart comparison page.
- ProductDetailPage bottom button: ElevatedButton.icon with favorites toggle — add "Sepete Ekle" button in same style directly below it.

### Established Patterns
- AsyncNotifier + SharedPreferences: `build()` returns `Future<List<T>>`, state mutated via `update()`. See FavoritesNotifier.
- Widget decomposition: new widgets in `lib/features/cart/widgets/` (or `lib/features/products/widgets/` if cart is within products feature).
- Result<T> / FutureProvider: use `ref.watch(provider)` with `.when(data:, loading:, error:)` — same pattern as ProductDetailPage.
- AppBar actions: `AppBar(actions: [IconButton(...)])` — add cart icon here.

### Integration Points
- `ProductDetailPage.build()`: Add `CartNotifier` consumer below `FavoritesNotifier` consumer for the button row
- `ProductsPage`: Add `actions: [CartAppBarIcon()]` to AppBar
- Cart comparison needs prices for all cart items × all markets: `productMarketPricesProvider(productId)` called per product — aggregate results in CartComparisonPage provider
- New feature directory: `lib/features/cart/` — domain/data/presentation structure following existing features

</code_context>

<specifics>
## Specific Ideas

- Match fraction format: "7/9 ürün mevcut" (same phrasing as COMP-03 acceptance criteria)
- Partial total footnote: "2 ürün bu markette bulunamadı" — Turkish, honest, non-alarming tone
- "Sepete Git" snackbar action mirrors the "Sepete Ekle" → comparison flow; familiar to Turkish e-commerce users
- No quantity: keeps the scope focused and the state model minimal — explicit user decision

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 04-cart-comparison*
*Context gathered: 2026-03-30*
