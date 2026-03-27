# Feature Research

**Domain:** Mobile grocery price comparison app (Turkish market)
**Researched:** 2026-03-27
**Confidence:** MEDIUM — based on training knowledge of comparable apps (Cimri, Akakce, Idealo, Trolley.co.uk, MySupermarket, Amazon price history UX); WebSearch unavailable. Patterns are well-established and stable across the industry.

---

## Context: What Already Exists

The app already ships:
- Product listing + search with market filter
- Market listing + detail (product list + active discounts per market, stats)
- Discount listing
- Favorites (SharedPreferences)
- 5-tab navigation

This milestone adds: price history charts, cart comparison, FCM push notifications, enriched market detail, and quality/refactor work. The research below focuses on those additions.

---

## Feature Landscape

### Table Stakes (Users Expect These)

Features users assume exist in any price comparison app. Missing these = product feels incomplete or untrustworthy.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Price history chart on product detail | Industry standard since Amazon/Camelcamelcamel established the pattern; Turkish apps (Akakce, Cimri) all show it | MEDIUM | Line chart, time selector (1W / 1M / 3M / 1Y), tap-to-see-exact-price interaction. Requires `PricePoint` data from backend (DATA-03 in PROJECT.md). |
| Side-by-side market prices on product detail | Already partially built (price list exists); users expect visual ranking not just a list | LOW | Already exists as a list. The enhancement is visual ranking clarity — cheapest highlighted, price difference shown as "X ₺ daha ucuz". |
| "Cheapest market" summary badge | Users should not need to read through a list to find the answer | LOW | Already exists as "En Uygun Fiyat" card at top of ProductDetailPage. Keep and refine. |
| Push notification for tracked items | Users who can't check prices daily need to be alerted; this is the primary re-engagement mechanism | HIGH | Requires FCM + backend watch list + price diff computation server-side. Two-sided complexity. |
| Market logo / branding on market detail | Without visuals, market pages feel like raw database records | LOW | Image assets can be bundled or served by backend. 7 Turkish chains have well-known logos. |
| Loyalty program / card info | Turkish market chains (BIM kart, Migros Money, A101 kart) are prominent; users specifically look for card discounts | LOW | Static or semi-static data. Does not need real-time scraping — update monthly. |

### Differentiators (Competitive Advantage)

Features that serve FiyatCep's core value: "gerçek fiyat farkını ve trend değişimini görünür kılmak."

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Cart comparison across markets | Answers "where should I do my weekly shop?" — the most practical, decision-enabling feature. Cimri/Akakce do not do full basket comparison. | HIGH | State-heavy: cart is a list of (productId, quantity) pairs. Each market total = sum of matched product prices. Match rate matters — not all products are stocked everywhere. |
| Price trend direction indicator | Arrow up/down + % change on product list row — faster signal than opening detail | LOW | Derives from price history data. No extra backend calls needed. |
| "X ₺ tasarruf" savings summary in cart | Motivational: shows concrete money saved by choosing the cheapest market for the whole basket | LOW | Computed from cart comparison data. Difference between cheapest total and most expensive total. |
| Notification threshold customization | "Notify me when below X ₺" vs blanket "any price drop" — reduces notification fatigue | MEDIUM | Server-side: stored threshold per (user_token, product_id). App side: UI for setting threshold. |
| Price drop percent context on notification | "Süt 15% düştü — şimdi 32,90 ₺" is more actionable than "Süt fiyatı değişti" | LOW | Backend enriches push payload with old_price, new_price, pct_change. |

### Anti-Features (Commonly Requested, Often Problematic)

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| User accounts / login for demo | Seems needed for personalized notifications | No-auth is explicitly Out of Scope (PROJECT.md). FCM device token is sufficient for anonymous notification targeting. Adding auth doubles scope. | Use FCM device token as anonymous identity. Store watch list server-side keyed on token. |
| Real-time price updates (WebSocket/polling) | Users want "live" prices | Turkish supermarket prices change at most once per day. Polling every 30s burns battery, creates server load, and provides zero real benefit. Scraper cadence is daily/weekly. | Timestamp "last updated X saat önce" on each price. Refresh-on-pull. |
| Offline mode with full data cache | Users request it for poor connectivity | Adds Hive/SQLite dependency, cache invalidation complexity, and storage management. Explicitly Out of Scope for this milestone. | Show cached data from last API call naturally (Riverpod state persists in session). Graceful error state with retry. |
| Price alerts via SMS | Higher reach for users without the app open | Requires SMS gateway cost, phone number collection, privacy policy update, KVKK implications. Far outside scope. | FCM push is sufficient. |
| Product image scraping and display | Makes product cards richer | Supermarket product images are copyrighted assets on retailer sites. Legal risk + scraping complexity. Image matching across markets is unsolved. | Use category icons or placeholder illustrations. Focus on price data quality. |
| "Best deal" automated recommendations | "AI recommends X" is trendy | Recommendation quality depends entirely on scraping completeness. With 7 markets and partial data, recommendations would be misleading. Trust risk. | Surface data; let users decide. Price history + market comparison gives all the information needed. |

---

## Feature Behavior Details

### 1. Price History Chart

**Expected UX behavior:**
- Displayed below the market price comparison list on ProductDetailPage
- Time selectors: 1H (1 Hafta), 1A (1 Ay), 3A (3 Ay), 1Y (1 Yıl) — tap chips to switch
- Default view: 1 month (most useful for grocery items; prices rarely have 1-year trends)
- Chart type: line chart, single line (per-product, not per-market; showing best available price over time)
- Interaction: tap/long-press on a data point shows tooltip with exact price and date
- Empty state: "Fiyat geçmişi henüz yok — veriler birikince burada gösterilecek" (data accumulates over time)
- Granularity: daily data points. Weekly aggregates acceptable for 3M/1Y views to reduce payload.

**What NOT to show:**
- Do not show per-market price history lines on the same chart (too cluttered for mobile; N markets = N lines = unreadable). If differentiation is needed later, add a market filter chip.
- Do not animate chart on every rebuild — animate once on mount only.

**Flutter implementation note:** `fl_chart` is the standard choice in the Flutter ecosystem for this. No chart library is currently in pubspec.yaml — this is a new dependency.

---

### 2. Cart Comparison

**Expected UX behavior:**

**Building the cart:**
- "Sepete Ekle" button added to ProductDetailPage (alongside Favorites button)
- Cart is accessible from a persistent icon in the AppBar or as a 6th tab (consider carefully — 6 tabs is crowded; AppBar icon preferred)
- Cart shows: product name, brand, quantity stepper (+/-), remove button
- Products from any market can be added; the cart is market-agnostic (it represents "I want these items")

**The comparison view:**
- Dedicated CartComparisonPage
- For each market: total cost IF that market stocks all (or most) items in the cart
- Ranked list: cheapest market at top, most expensive at bottom
- Each market row shows: logo, market name, total price, number of items it stocks (e.g., "7/9 ürün mevcut"), missing items flagged
- Missing items handling: if a market doesn't stock a product, it's excluded from that market's total with a note. Don't pretend the total is complete.
- "Toplam tasarruf" banner: difference between cheapest and most expensive market totals
- Tap a market row to see item-by-item breakdown for that market

**Key UX decision — match rate:** Turkish discount markets (BIM, A101, Şok) have limited and rotating SKUs. A product in Migros may simply not exist in BIM. The comparison must be honest about this — show "5/9 ürün" clearly. Never show a misleadingly low total by omitting non-stocked items silently.

**State management:** Cart state must survive navigation (not just widget state). A Riverpod provider with SharedPreferences persistence is appropriate. Cart does not need to sync to backend.

---

### 3. Price Drop Notifications

**Trigger mechanism:**
- User taps "Takip Et" on a product or discount (on ProductDetailPage or DiscountsPage)
- Watch list stored server-side, keyed by FCM device token (no user auth needed)
- Backend scraper, after each scrape cycle, compares new prices to previous prices for all watched products
- If price drops for any watched product, backend sends FCM push notification

**Notification payload expected by app:**
```
title: "Fiyat Düştü: Sütaş Süt 1L"
body: "Migros'ta 38,90 ₺ → 32,90 ₺ (%15 indirim)"
data: { product_id: "...", market_id: "...", type: "price_drop" }
```
- Tapping notification navigates to ProductDetailPage for that product

**Threshold setting:**
- v1: Any price drop triggers notification (binary — track / don't track)
- v1.x: "X ₺ altına düşünce haber ver" threshold per product (more complex, lower priority)
- Rationale: Get the basic loop working first; threshold adds value only after users have seen the notifications

**iOS APN requirement:** Needs Apple Developer account + APN certificates. This is a known constraint in PROJECT.md. Cannot be bypassed.

**Notification permission:** Must request at a meaningful moment (not on app launch). Request permission when user first taps "Takip Et." Explain why: "Fiyat düşünce haberdar olabilmek için bildirime izin ver."

---

### 4. Market Detail Enrichment

**What users expect to see on a market detail page:**

| Section | Content | Priority | Data type |
|---------|---------|----------|-----------|
| Market logo + brand color header | Visual identity, trust signal | HIGH | Static asset bundled in app |
| Market banner image | Promotional visual (optional) | LOW | Remote URL, can be null |
| Branch count + city coverage | "1000+ şube, 81 ilde" | MEDIUM | Static/semi-static |
| Online ordering info | URL or "app mevcut" with link | MEDIUM | Static |
| Loyalty / card program name + benefits | "BIM Kart: %5 ek indirim", "Migros Money puan" | HIGH | Static/semi-static |
| Card requirements | "Ücretsiz, şubeden alınır" | MEDIUM | Static |
| Active discounts list | Already built | DONE | Live |
| Product list for this market | Already built | DONE | Live |

**What users do NOT need on market detail:**
- Store locator / map (requires location permission, maps SDK, significant complexity — defer to v2)
- Opening hours (hard to scrape accurately, varies by branch)
- Customer reviews (requires UGC infrastructure)

---

## Feature Dependencies

```
[Price History Chart]
    └──requires──> [DATA-03: ProductItem.priceHistory from backend]
                       └──requires──> [DATA-01: Scraping backend delivers price history]

[Cart Comparison]
    └──requires──> [Cart State (Riverpod + SharedPreferences)]
    └──requires──> [COMP-01: Market prices per product already loaded]
    └──enhances──> [Price History Chart] (adds context to price trends)

[FCM Push Notifications]
    └──requires──> [NOTIF-01: FCM SDK integration (firebase_messaging)]
    └──requires──> [NOTIF-02: Watch list UI + server-side storage endpoint]
    └──requires──> [Backend: price comparison after scrape cycle]
    └──enhances──> [Favorites] (tracked items are a superset of favorites UX)

[Market Detail Enrichment — Logo/Banner]
    └──no external dependencies (static assets bundled)

[Market Detail Enrichment — Card/Loyalty Info]
    └──no external dependencies (static data, update manually)

[Cart State]
    └──requires──> [Product data loaded] (products must exist to add to cart)
```

### Dependency Notes

- **Price History Chart requires backend price history:** The chart is useless without `List<PricePoint>` per product. If the scraping backend is delayed, the chart must degrade gracefully to an empty state. Build the UI before the data is ready; connect when DATA-03 is available.
- **Cart Comparison requires COMP-01 (market prices per product):** Market prices are already fetched on ProductDetailPage. Cart comparison reuses the same data shape — no new API endpoints needed for the basic comparison, only aggregation logic on the client.
- **FCM requires two-sided work:** The app can integrate the SDK and display notifications it receives, but triggers depend entirely on the backend sending them. These two sides must be coordinated. The Flutter side can be validated with manual FCM test messages.
- **Favorites and Watch List are related but distinct:** Favorites = local bookmark (no backend). Watch List = notification subscription (backend). They can coexist. Do not merge them — different intent.

---

## MVP Definition

### Launch With (v1 — this milestone)

- [ ] Price history chart on ProductDetailPage — empty state if no data; ready to populate when backend delivers history
- [ ] Market price comparison (already partially exists) — enhance with savings delta ("X ₺ daha ucuz") and discount badge
- [ ] Cart comparison — build cart, compare totals per market, show match rate, show savings
- [ ] FCM push notification integration — SDK, permission request at right moment, notification routing to product detail
- [ ] Product/discount watch (track) — UI to subscribe/unsubscribe, synced to backend watch list endpoint
- [ ] Market detail logo + loyalty/card info — static assets, no new API needed
- [ ] Error handling typed errors + widget refactor + repository tests (QUAL-01 through QUAL-06)

### Add After Validation (v1.x)

- [ ] Price trend direction indicator on product list row — quick win once price history data is flowing
- [ ] Notification threshold ("X ₺ altına düşünce") — add when users report notification fatigue
- [ ] Cart persistence across sessions — add if users complain of losing their cart (SharedPreferences already available)

### Future Consideration (v2+)

- [ ] Per-market price history overlay on chart — useful for power users; defer until basic chart is validated
- [ ] Store locator / maps — requires significant new permissions and SDK; out of scope for this milestone
- [ ] Offline cache (Hive/SQLite) — explicitly deferred in PROJECT.md
- [ ] User accounts / auth — explicitly deferred in PROJECT.md

---

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| Market price side-by-side (enhance existing) | HIGH | LOW | P1 |
| Market detail logo + loyalty info | MEDIUM | LOW | P1 |
| Price history chart (UI + empty state) | HIGH | MEDIUM | P1 |
| Cart comparison | HIGH | HIGH | P1 |
| FCM integration + watch list UI | HIGH | HIGH | P1 |
| Price trend arrow on product list | MEDIUM | LOW | P2 |
| Notification threshold setting | MEDIUM | MEDIUM | P2 |
| Per-market chart overlay | LOW | MEDIUM | P3 |
| Store locator | LOW | HIGH | P3 |

**Priority key:**
- P1: Must have for this milestone (demo/beta)
- P2: Should have, add when possible within milestone
- P3: Nice to have, future consideration

---

## Competitor Feature Analysis

| Feature | Cimri / Akakce (Turkish) | Idealo (EU) | Trolley.co.uk (UK grocery) | Our Approach |
|---------|--------------------------|-------------|----------------------------|--------------|
| Price history chart | Yes, line chart, 1M/3M/1Y | Yes, detailed | Limited | Line chart, 1W/1M/3M/1Y, daily granularity |
| Cart/basket comparison | No (product-level only) | No | Yes (basket builder) | Yes — key differentiator for Turkish grocery context |
| Push notifications | Price drop alerts | Price drop alerts | Weekly deals digest | Price drop per tracked product; any drop in v1, threshold in v1.x |
| Market branding on detail | Yes, logo prominent | Yes | Yes, logo + banner | Logo + brand color; banner optional |
| Loyalty card info | No | No | Yes (Tesco Clubcard, etc.) | Yes — BIM kart, Migros Money, A101 kart; static data |
| Match rate in basket | N/A | N/A | Implicit (items available) | Explicit "7/9 ürün mevcut" — honest about partial stock |

---

## Sources

- App behavior observed in: Cimri (cimri.com), Akakce (akakce.com), Trolley.co.uk, MySupermarket, Amazon price history (via camelcamelcamel.com), Idealo — training knowledge, confidence MEDIUM
- PROJECT.md requirements and constraints — authoritative for this project
- Existing codebase (ProductDetailPage, MarketDetailPage) — direct inspection
- Turkish grocery chains loyalty programs (BIM Kart, Migros Money, A101 Kart, CarrefourSA Kart) — training knowledge, confidence MEDIUM
- Flutter ecosystem chart libraries — `fl_chart` is the dominant choice per pub.dev rankings; not verified via Context7 due to tool unavailability

---

*Feature research for: FiyatCep — Turkish grocery price comparison app*
*Researched: 2026-03-27*
