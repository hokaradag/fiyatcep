# Phase 4: Cart Comparison — Research

**Researched:** 2026-03-30
**Domain:** Flutter state management (AsyncNotifier + SharedPreferences), multi-provider aggregation, CartComparisonPage layout
**Confidence:** HIGH

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- **D-01:** Cart accessed via a cart icon with item-count badge in the AppBar of ProductsPage and ProductDetailPage. Tapping pushes CartComparisonPage via Navigator.push. The 5-tab bottom navigation remains unchanged — no 6th tab added.
- **D-02:** AppBar cart icon is only shown when the cart has at least one item (hidden when empty) — OR shown always with badge hidden when count is 0. Claude's discretion on exact visibility rule.
- **D-03:** Cart is a set of unique products — `List<ProductItem>` (or equivalent). Adding the same product twice is a no-op. No quantity field.
- **D-04:** Cart state persists across app restarts using SharedPreferences — same pattern as `FavoritesNotifier` (AsyncNotifier + SharedPreferences). Cart products stored as JSON-serialized list under a new key (e.g., `'cart_products'`).
- **D-05:** On ProductDetailPage, a "Sepete Ekle" button is added below the existing "Favorilere Ekle" button. When the product is already in cart, button reads "Sepetten Çıkar" (toggle, same pattern as favorites).
- **D-06:** Tapping "Sepete Ekle" shows a snackbar: "Ürün sepete eklendi" with a "Sepete Git" action button. User stays on ProductDetailPage to continue browsing. The "Sepete Git" action navigates to CartComparisonPage.
- **D-07:** CartComparisonPage shows one card per market, sorted by total price ascending (cheapest first). The cheapest market with full or best match is highlighted (green / "En Uygun" badge).
- **D-08:** Each market card shows: market logo + name, match fraction ("7/9 ürün"), and total price. Cards are expandable: tapping reveals matched products (with price) and unmatched products (marked "bulunamadı").
- **D-09:** Cart product list is shown at the top of the page so users can review/remove items before comparing.
- **D-10:** Markets with missing products show the partial total honestly: "7/9 ürün | 131,20 ₺\*" with a note below the total: "2 ürün bu markette bulunamadı". The asterisk (*) or muted color signals incompleteness. No markets are hidden — all 7 markets always appear.
- **D-11:** Sorting is by partial total (sum of available products). User is expected to read the match fraction and judge accordingly. No threshold-based hiding.

### Claude's Discretion

- Whether AppBar cart icon is always visible (badge hidden when 0) or only visible when cart has items
- Exact SharedPreferences key for cart data
- Whether CartComparisonPage has a "Sepeti Temizle" button or per-item swipe-to-remove, or both
- Visual styling of matched (✓) vs unmatched (✗) product rows in the expanded card
- How to match cart products to market inventory (by product.id against MarketPriceItem.productId)

### Deferred Ideas (OUT OF SCOPE)

None — discussion stayed within phase scope.

</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| COMP-03 | Kullanıcı birden fazla ürün ekleyerek sepet oluşturabilir ve her market için toplam fiyatı karşılaştırabilir (eşleşme oranı açıkça gösterilir — örn. "7/9 ürün mevcut") | CartNotifier (AsyncNotifier+SharedPreferences) handles cart state and persistence; per-market aggregation uses existing `productMarketPricesProvider`; partial match displayed per D-10; all three success criteria (add-to-cart, total+match-rate display, partial match honesty) are satisfied by the architecture researched. |

</phase_requirements>

---

## Summary

Phase 4 builds a cart comparison feature on top of the existing Flutter Clean Architecture + Riverpod stack. There are no new pub.dev dependencies: SharedPreferences is already in `pubspec.yaml`, Flutter Material 3 covers all UI needs, and the existing `productMarketPricesProvider(productId)` FutureProvider.family is reused to fetch per-market prices for each cart item.

The entire cart state layer is a near-copy of `FavoritesNotifier` — an `AsyncNotifier<List<ProductItem>>` that reads/writes a JSON-encoded list to SharedPreferences. The only structural difference is that `FavoritesNotifier.toggle()` becomes three discrete methods (`add`, `remove`, `clear`) because cart operations are asymmetric (a "Sepeti Temizle" bulk clear is needed). The comparison logic — grouping `MarketPriceItem` results by `marketId`, computing partial totals, and calculating match fractions — is pure Dart and lives in a new `cartComparisonProvider` FutureProvider that fans out to `productMarketPricesProvider` for each cart item.

The key architectural challenge is that `cartComparisonProvider` must wait on N concurrent `productMarketPricesProvider` futures (one per cart item) and then fold the results. The correct Flutter/Riverpod pattern is `Future.wait([...])` inside the FutureProvider body, with `ref.watch` replaced by `ref.read` inside the async body to avoid re-subscribing during the fan-out. The UI must handle the aggregate loading state with a single `CircularProgressIndicator` and the aggregate error state with a retry button.

**Primary recommendation:** Implement `CartNotifier` as a direct clone of `FavoritesNotifier`, place it in `lib/features/cart/presentation/providers/cart_notifier.dart`, and build `cartComparisonProvider` as a FutureProvider that fans out via `Future.wait` over `productMarketPricesProvider`. No new dependencies. No new data models beyond an aggregation record (`CartMarketResult`).

---

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| flutter_riverpod | 2.6.1 (already in project) | AsyncNotifier for CartNotifier; FutureProvider for cartComparisonProvider | Established project-wide state management |
| shared_preferences | 2.5.4 (already in project) | Persist cart as JSON list under `'cart_products'` key | Already used by FavoritesNotifier — zero new dependency |
| freezed / json_serializable | 2.4.0 / 6.7.0 (already in project) | ProductItem already has `toJson`/`fromJson` — no new model needed for cart items | Immutable data models already generated |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Flutter Material Icons (built-in) | SDK | `Icons.shopping_cart_outlined`, `Icons.remove_shopping_cart`, `Icons.remove_circle_outline` | Cart icon, toggle button, per-item remove |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| SharedPreferences JSON list | Hive or SQLite | Overkill — project out-of-scope for Hive/SQLite (see REQUIREMENTS.md "Offline destek" row); SharedPreferences is already present and proven for this pattern |
| FutureProvider fan-out | StateNotifier aggregation | Fan-out keeps comparison logic pure/testable without side effects; no advantage to StateNotifier here |

**Installation:** No new packages. All dependencies already in `pubspec.yaml`.

---

## Architecture Patterns

### Recommended Project Structure

```
lib/features/cart/
├── presentation/
│   └── providers/
│       └── cart_notifier.dart          # CartNotifier + cartNotifierProvider + cartComparisonProvider
├── widgets/
│   ├── cart_app_bar_icon.dart          # IconButton with badge Stack
│   ├── cart_product_list_section.dart  # "Sepetim" header + removable product rows
│   └── cart_market_comparison_card.dart # Expandable market card
└── cart_comparison_page.dart           # Full page
```

No `domain/` or `data/` subdirectories are needed: the cart feature has no repository, no datasource, and no abstract interface. State lives entirely in the Riverpod notifier layer. This is consistent with the `FavoritesNotifier` which also has no repository layer.

### Pattern 1: CartNotifier — AsyncNotifier + SharedPreferences

**What:** AsyncNotifier<List<ProductItem>> that loads on build, mutates state via add/remove/clear, and persists to SharedPreferences after every mutation.

**When to use:** Any feature that stores a user-managed list persistently across restarts. Directly mirrors FavoritesNotifier.

**Example (based on verified FavoritesNotifier source):**

```dart
// Source: lib/features/favorites/presentation/providers/favorites_notifier.dart
class CartNotifier extends AsyncNotifier<List<ProductItem>> {
  static const String _cartKey = 'cart_products';

  @override
  Future<List<ProductItem>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_cartKey) ?? [];
    try {
      return stored
          .map((item) => ProductItem.fromJson(jsonDecode(item) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> add(ProductItem product) async {
    final current = await future;
    if (current.any((p) => p.id == product.id)) return; // dedup by id
    final updated = [...current, product];
    state = AsyncData(updated);
    await _save(updated);
  }

  Future<void> remove(ProductItem product) async {
    final current = await future;
    final updated = current.where((p) => p.id != product.id).toList();
    state = AsyncData(updated);
    await _save(updated);
  }

  Future<void> clear() async {
    state = const AsyncData([]);
    await _save([]);
  }

  Future<void> _save(List<ProductItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _cartKey,
      items.map((p) => jsonEncode(p.toJson())).toList(),
    );
  }
}

final cartNotifierProvider =
    AsyncNotifierProvider<CartNotifier, List<ProductItem>>(CartNotifier.new);
```

**Important:** Dedup uses `p.id == product.id` (not `p == product`). `FavoritesNotifier` uses Freezed equality (`p == product`) which compares all fields including `priceHistory`. For cart dedup the intent is "same product entity" regardless of which market's price snapshot was used, so id-based dedup is safer. Either works if cart items are always added from the same `ProductItem` constructor, but id-based is more explicit and matches D-03 semantics.

### Pattern 2: cartComparisonProvider — FutureProvider fan-out

**What:** A FutureProvider that reads the current cart, fans out to `productMarketPricesProvider` for each product, then aggregates results into a list of `CartMarketResult` objects (one per market).

**When to use:** Aggregating multiple FutureProvider.family results into a single computed async value.

**Example:**

```dart
// CartMarketResult — a plain Dart class, no Freezed needed (not serialized)
class CartMarketResult {
  final String marketId;
  final String marketName;
  final int matchedCount;
  final int totalCount;
  final double partialTotal;
  final List<({ProductItem product, double? price})> rows;

  const CartMarketResult({
    required this.marketId,
    required this.marketName,
    required this.matchedCount,
    required this.totalCount,
    required this.partialTotal,
    required this.rows,
  });

  bool get isCheapest => false; // set by sort step
  bool get isFullMatch => matchedCount == totalCount;
  String get matchFraction => '$matchedCount/$totalCount ürün mevcut';
}

final cartComparisonProvider =
    FutureProvider<List<CartMarketResult>>((ref) async {
  // Use ref.watch so provider rebuilds when cart changes
  final cartAsync = ref.watch(cartNotifierProvider);
  final cart = cartAsync.valueOrNull ?? [];

  if (cart.isEmpty) return [];

  // Fan-out: fetch prices for all cart items concurrently
  final allPrices = await Future.wait(
    cart.map((product) => ref.read(productMarketPricesProvider(product.id).future)),
  );

  // Aggregate by marketId
  final Map<String, List<MarketPriceItem>> byMarket = {};
  for (var i = 0; i < cart.length; i++) {
    for (final priceItem in allPrices[i]) {
      byMarket.putIfAbsent(priceItem.marketId, () => []).add(priceItem);
    }
  }

  // All known market IDs from marketBrands
  final allMarketIds = marketBrands.keys.toList();

  final results = allMarketIds.map((marketId) {
    final prices = byMarket[marketId] ?? [];
    final matchedCount = prices.length;
    final partialTotal = prices.fold(0.0, (sum, p) => sum + p.price);
    final marketName = prices.isNotEmpty ? prices.first.market : marketId;

    final rows = cart.map((product) {
      final priceItem = prices.cast<MarketPriceItem?>().firstWhere(
        (p) => p?.marketId == marketId,
        orElse: () => null,
      );
      // Actually need price lookup by product.id — see Pitfall 1
      return (product: product, price: null as double?);
    }).toList();

    return CartMarketResult(
      marketId: marketId,
      marketName: marketName,
      matchedCount: matchedCount,
      totalCount: cart.length,
      partialTotal: partialTotal,
      rows: rows,
    );
  }).toList();

  // Sort cheapest partial total first
  results.sort((a, b) => a.partialTotal.compareTo(b.partialTotal));
  return results;
});
```

**Note:** The snippet above is illustrative. See Pitfall 1 for the correct per-product price lookup within a market.

### Pattern 3: CartAppBarIcon — Stack-based badge

**What:** An `IconButton` wrapped in a `Stack` with a positioned `CircleAvatar` badge. The badge is conditionally rendered based on `cartCount > 0`.

**Example:**

```dart
// Source: UI-SPEC.md Component Inventory §1
class CartAppBarIcon extends ConsumerWidget {
  const CartAppBarIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount =
        ref.watch(cartNotifierProvider).valueOrNull?.length ?? 0;
    return Tooltip(
      message: 'Sepeti Aç',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: Icon(
              Icons.shopping_cart_outlined,
              color: cartCount > 0 ? Colors.green : null,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartComparisonPage()),
            ),
          ),
          if (cartCount > 0)
            Positioned(
              right: 4,
              top: 4,
              child: CircleAvatar(
                radius: 8,
                backgroundColor: Colors.red,
                child: Text(
                  '$cartCount',
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

### Pattern 4: Expandable market card — local bool state

**What:** A `StatefulWidget` (or `ConsumerStatefulWidget`) with a single `bool isExpanded` field. Tapping the card calls `setState(() => isExpanded = !isExpanded)`. The expanded content is rendered conditionally with `if (isExpanded)`.

**When to use:** Expansion state is local to the widget, not shared across pages. No `AnimatedCrossFade` required (UI-SPEC allows simple conditional render).

### Anti-Patterns to Avoid

- **Calling `ref.watch` inside `Future.wait` fan-out:** Use `ref.read(provider.future)` inside the async body. Using `ref.watch` inside async gaps causes undefined behavior in Riverpod. The `ref.watch(cartNotifierProvider)` call must happen synchronously at the top of the FutureProvider body.
- **Building CartMarketResult across all 7 `marketBrands` including markets with no price data AND no name:** The `marketName` field cannot be derived from `marketBrands` alone (it only stores color/logo). Derive `marketName` from the first `MarketPriceItem` in the market's price list if available; fall back to `marketId` capitalized only when the market has no prices for any cart item.
- **Using Freezed equality for cart dedup when ProductItem carries priceHistory:** `ProductItem` equality is Freezed-generated and compares all fields. Two instances of "p1" from different datasource calls may differ in `priceHistory` field length, causing dedup to fail silently. Use `.id`-based lookup for all cart operations.
- **Forgetting to rebuild `cartComparisonProvider` when cart changes:** Use `ref.watch(cartNotifierProvider)` at the top of `cartComparisonProvider` — this creates a dependency that invalidates and re-runs the provider whenever the cart mutates.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Persistent list across restarts | Custom file I/O or SQLite | SharedPreferences + `getStringList` / `setStringList` | Already in project, battle-tested, handles JSON list encoding — mirrors FavoritesNotifier exactly |
| JSON encoding/decoding ProductItem | Manual map construction | `ProductItem.toJson()` / `ProductItem.fromJson()` (Freezed + json_serializable generated) | Already generated, already used by FavoritesNotifier |
| Concurrent async fetches | Sequential await loop | `Future.wait([...])` | Runs N price fetches in parallel, reduces total wait from N×400ms to ~400ms |
| AppBar badge | Custom overlay | `Stack` + `Positioned` + `CircleAvatar` | Flutter built-in, 5 lines — no library needed |
| Market brand color/name lookup | Hardcoded switch | `marketBrands[marketId]` from `market_brand_config.dart` | Already defined for all 7 markets, already used in Phase 3 market detail |

**Key insight:** This phase is almost entirely composition of already-proven patterns. The complexity is in the aggregation logic, not in any novel infrastructure.

---

## Common Pitfalls

### Pitfall 1: Incorrect per-product price lookup within a market

**What goes wrong:** When building `CartMarketResult.rows`, developers may try to look up a product's price by iterating `byMarket[marketId]` — but `byMarket[marketId]` is a flat list of `MarketPriceItem` for that market across all products. There is no `productId` field on `MarketPriceItem` to match against.

**Why it happens:** `MarketPriceItem` (verified in `lib/features/products/models/market_price_item.dart`) has fields `marketId`, `market`, `price`, `isDiscounted` — no `productId`. The fan-out in `cartComparisonProvider` uses `allPrices[i]` which is indexed to `cart[i]`, so the product identity comes from the index, not from a field.

**How to avoid:** Maintain a parallel data structure `Map<String, Map<String, double>> priceMap` where outer key is `product.id` and inner key is `marketId`:

```dart
// Build priceMap: productId → marketId → price
final Map<String, Map<String, double>> priceMap = {};
for (var i = 0; i < cart.length; i++) {
  final productId = cart[i].id;
  priceMap[productId] = {};
  for (final priceItem in allPrices[i]) {
    priceMap[productId]![priceItem.marketId] = priceItem.price;
  }
}
```

Then build rows per market: `priceMap[product.id]?[marketId]` gives the price or null if not available.

**Warning signs:** Comparison totals show 0.0 for markets that should have prices; match counts are always 0.

### Pitfall 2: Riverpod ref.watch inside async body

**What goes wrong:** Calling `ref.watch(someProvider)` inside an `async` function body after an `await` point causes a Riverpod assertion error in debug mode and silent undefined behavior in release mode.

**Why it happens:** Riverpod's `ref.watch` is only valid in synchronous build contexts (widget `build()`) or at the synchronous top of a provider body before the first `await`.

**How to avoid:** At the top of `cartComparisonProvider`, synchronously call `ref.watch(cartNotifierProvider)` to establish the dependency. Then use `ref.read(productMarketPricesProvider(id).future)` inside the `Future.wait` list — `ref.read` is safe anywhere.

**Warning signs:** Riverpod assertion: "ref.watch was called after an await statement".

### Pitfall 3: productMarketPricesProvider fan-out with empty cart

**What goes wrong:** `Future.wait([])` on an empty list returns immediately with `[]`, which is correct — but if `cartComparisonProvider` is not guarded, it attempts to map over `allMarketIds` with zero price data and produces 7 cards with 0/0 match and 0.00 ₺ totals — not an empty/loading state.

**How to avoid:** Add `if (cart.isEmpty) return [];` before the fan-out. CartComparisonPage should render an empty state when the provider returns `[]`.

**Warning signs:** Comparison page shows 7 market cards all saying "0/0 ürün mevcut | 0,00 ₺" instead of the empty cart state.

### Pitfall 4: pumpAndSettle() required in widget tests for async providers

**What goes wrong:** Widget tests that don't call `pumpAndSettle()` after initial `pumpWidget` will find CircularProgressIndicator instead of the loaded content. This caused failures in Phase 1 and Phase 2.

**How to avoid:** All widget tests must call `await tester.pumpAndSettle()` after `pumpWidget`. Tests that need SharedPreferences must call `SharedPreferences.setMockInitialValues({})` in `setUp`.

**Warning signs:** `findsOneWidget` assertions fail on text that should be visible after loading.

### Pitfall 5: "Sepeti Temizle" then Navigator.pop order

**What goes wrong:** If `cartNotifier.clear()` is called and then `Navigator.pop(context)` pops only the confirmation dialog, `CartComparisonPage` remains open showing an empty comparison list. The page has no defined empty state transition.

**How to avoid:** After confirming "Temizle" in the dialog:
1. Call `cartNotifier.clear()`
2. `Navigator.pop(context)` to close dialog
3. `Navigator.pop(context)` again to pop `CartComparisonPage` back to `ProductsPage`

Per UI-SPEC D "Sepeti Temizle" section: "pops dialog, Navigator.pop back to previous page".

### Pitfall 6: marketName resolution for markets with no inventory coverage

**What goes wrong:** For a market that has no `MarketPriceItem` for any cart product, `byMarket[marketId]` returns null/empty. If `marketName` is derived from `prices.first.market`, this throws a RangeError on an empty list.

**How to avoid:** Provide a fallback: if the prices list is empty, use `marketId` as display name (or a hardcoded name map). Since `marketBrands` only stores color/logo, a minimal `marketNames` map keyed by slug is the cleanest fix:

```dart
const Map<String, String> _marketNames = {
  'migros': 'Migros', 'a101': 'A101', 'bim': 'BİM',
  'carrefoursa': 'CarrefourSA', 'sok': 'ŞOK',
  'tarim-kredi': 'Tarım Kredi', 'file-market': 'File Market',
};
```

---

## Code Examples

### CartNotifier — complete minimal implementation

```dart
// Source: FavoritesNotifier pattern (lib/features/favorites/presentation/providers/favorites_notifier.dart)
// Key differences: add/remove/clear instead of toggle; dedup by id

class CartNotifier extends AsyncNotifier<List<ProductItem>> {
  static const String _cartKey = 'cart_products';

  @override
  Future<List<ProductItem>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_cartKey) ?? [];
    try {
      return stored
          .map((item) => ProductItem.fromJson(jsonDecode(item) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  bool isInCart(List<ProductItem> cart, ProductItem product) =>
      cart.any((p) => p.id == product.id);

  Future<void> add(ProductItem product) async {
    final current = await future;
    if (current.any((p) => p.id == product.id)) return;
    final updated = [...current, product];
    state = AsyncData(updated);
    await _save(updated);
  }

  Future<void> remove(ProductItem product) async {
    final current = await future;
    final updated = current.where((p) => p.id != product.id).toList();
    state = AsyncData(updated);
    await _save(updated);
  }

  Future<void> clear() async {
    state = const AsyncData([]);
    await _save([]);
  }

  Future<void> _save(List<ProductItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _cartKey,
      items.map((p) => jsonEncode(p.toJson())).toList(),
    );
  }
}

final cartNotifierProvider =
    AsyncNotifierProvider<CartNotifier, List<ProductItem>>(CartNotifier.new);
```

### cartComparisonProvider — fan-out aggregation

```dart
// Correct pattern: ref.watch at top (synchronous), ref.read inside Future.wait
final cartComparisonProvider =
    FutureProvider<List<CartMarketResult>>((ref) async {
  final cart = ref.watch(cartNotifierProvider).valueOrNull ?? [];
  if (cart.isEmpty) return [];

  final allPrices = await Future.wait(
    cart.map((p) => ref.read(productMarketPricesProvider(p.id).future)),
  );

  // Build priceMap: productId → marketId → price
  final Map<String, Map<String, double>> priceMap = {};
  for (var i = 0; i < cart.length; i++) {
    priceMap[cart[i].id] = {
      for (final m in allPrices[i]) m.marketId: m.price,
    };
  }

  // Build one result per market across all 7 known markets
  final results = marketBrands.keys.map((marketId) {
    double total = 0.0;
    int matchedCount = 0;
    final rows = <({ProductItem product, double? price})>[];

    for (final product in cart) {
      final price = priceMap[product.id]?[marketId];
      rows.add((product: product, price: price));
      if (price != null) {
        total += price;
        matchedCount++;
      }
    }

    // Derive display name from first matched product's MarketPriceItem,
    // falling back to slug-based name map
    final marketName = _resolveMarketName(marketId, allPrices, cart);

    return CartMarketResult(
      marketId: marketId,
      marketName: marketName,
      matchedCount: matchedCount,
      totalCount: cart.length,
      partialTotal: total,
      rows: rows,
    );
  }).toList();

  results.sort((a, b) => a.partialTotal.compareTo(b.partialTotal));
  return results;
});
```

### "Sepete Ekle" button in ProductDetailPage

```dart
// Added below the existing FavoritesNotifier Consumer widget
// Source: product_detail_page.dart Consumer pattern (lines 41-75)
Consumer(
  builder: (context, ref, child) {
    final cart = ref.watch(cartNotifierProvider).valueOrNull ?? [];
    final inCart = cart.any((p) => p.id == product.id);
    final notifier = ref.read(cartNotifierProvider.notifier);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          if (inCart) {
            await notifier.remove(product);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ürün sepetten çıkarıldı'),
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            await notifier.add(product);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Ürün sepete eklendi'),
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: 'Sepete Git',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CartComparisonPage(),
                    ),
                  ),
                ),
              ),
            );
          }
        },
        icon: Icon(inCart
            ? Icons.remove_shopping_cart
            : Icons.shopping_cart_outlined),
        label: Text(inCart ? 'Sepetten Çıkar' : 'Sepete Ekle'),
      ),
    );
  },
),
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| FavoritesStore (static singleton + ValueNotifier) | FavoritesNotifier (AsyncNotifier + Riverpod) | Phase 1 | AsyncNotifier is the project-established standard — CartNotifier must follow the new pattern, not the deprecated singleton |
| Numeric market IDs (m1-m5) | Slug IDs (migros, a101, bim, sok, carrefoursa) | Phase 3 | `marketBrands` map uses slug keys; `MarketPriceItem.marketId` uses slugs; cart comparison must key by slug |

**Deprecated/outdated:**
- `FavoritesStore` singleton: still present with deprecation comment in `lib/features/favorites/data/favorites_store.dart`; do not clone this for CartNotifier — clone `FavoritesNotifier` instead.

---

## Open Questions

1. **What marketName to display for a market that stocks zero cart items?**
   - What we know: `MarketPriceItem.market` carries the display name, but only for markets that have at least one price entry. `marketBrands` only carries color/logo. There is no separate `Market` model with a name field in the cart context.
   - What's unclear: Whether a market with 0/N match should be shown at all (D-10 says yes — all 7 always appear), but its name can't be derived from prices.
   - Recommendation: Planner includes a `_marketDisplayNames` const map in `cart_notifier.dart` (7 entries, matches slugs exactly) as the fallback. Alternatively, derive from the markets feature model — but that adds a provider dependency.

2. **Should `cartComparisonProvider` include markets with 0/N match in the sorted results?**
   - What we know: D-10 and D-11 say all markets appear and sorting is by partial total. A market with 0/N has partialTotal = 0.0, which sorts to the top — making it appear cheapest, which is misleading.
   - Recommendation: Sort markets with `matchedCount == 0` to the bottom regardless of partial total. Planner should codify this sort tiebreaker. The requirement says "honest" display — showing a 0/9-match market as cheapest contradicts that.

---

## Environment Availability

Step 2.6: SKIPPED — this phase has no external dependencies beyond the project's own code. All required packages are already in `pubspec.yaml` and the build system is fully configured.

---

## Project Constraints (from CLAUDE.md)

These directives are extracted from `CLAUDE.md` and must be enforced by the planner:

| Constraint | Directive |
|------------|-----------|
| Tech stack | Flutter + Dart (Riverpod, Freezed, Dio) — existing architecture preserved, new dependencies minimized |
| No new dependencies | SharedPreferences already in use; no new packages needed for Phase 4 |
| Naming: files | snake_case (e.g. `cart_notifier.dart`, `cart_comparison_page.dart`, `cart_app_bar_icon.dart`) |
| Naming: classes | PascalCase (`CartNotifier`, `CartComparisonPage`, `CartAppBarIcon`) |
| Naming: providers | `cartNotifierProvider` (camelCase) |
| Naming: private | Underscore prefix (`_cartKey`, `_save()`) |
| Feature structure | `lib/features/cart/` with `presentation/providers/`, `widgets/`, root page file |
| State management | AsyncNotifier pattern (not BLoC, not StateNotifier, not ChangeNotifier) |
| Error handling | Providers throw `AppException` on failure; use `.when(data:, loading:, error:)` in UI |
| Constants | `SCREAMING_SNAKE_CASE` with `const`: `const String _cartKey = 'cart_products'` |
| Import style | Relative imports with `../`, package imports as `package:fiyatcep/` |
| Platform parity | Android + iOS simultaneously; no platform-specific code needed for this phase |
| GSD workflow | All code changes through `/gsd:execute-phase` — no direct repo edits outside GSD |

---

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | flutter_test (SDK integrated, no version pin needed) |
| Config file | None — uses `flutter test` CLI directly |
| Quick run command | `flutter test test/features/cart/ -r compact` |
| Full suite command | `flutter test --reporter compact` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| COMP-03 | CartNotifier.add() appends product and persists to SharedPreferences | unit | `flutter test test/features/cart/presentation/providers/cart_notifier_test.dart -r compact` | Wave 0 |
| COMP-03 | CartNotifier deduplicates — adding same product.id twice is no-op | unit | same file | Wave 0 |
| COMP-03 | CartNotifier.remove() removes product by id | unit | same file | Wave 0 |
| COMP-03 | CartNotifier.clear() empties list and persists | unit | same file | Wave 0 |
| COMP-03 | CartNotifier.build() restores cart from SharedPreferences after restart | unit | same file | Wave 0 |
| COMP-03 | cartComparisonProvider returns one result per market in 7-market set | unit | `flutter test test/features/cart/presentation/providers/cart_comparison_provider_test.dart -r compact` | Wave 0 |
| COMP-03 | cartComparisonProvider computes correct partial total per market | unit | same file | Wave 0 |
| COMP-03 | cartComparisonProvider match fraction is correct for partial coverage | unit | same file | Wave 0 |
| COMP-03 | CartComparisonPage renders market cards after loading | widget | `flutter test test/features/cart/cart_comparison_page_test.dart -r compact` | Wave 0 |
| COMP-03 | ProductDetailPage shows "Sepete Ekle" button | widget | `flutter test test/features/products/presentation/pages/product_detail_page_test.dart -r compact` | exists (extension needed) |

### Sampling Rate

- **Per task commit:** `flutter test test/features/cart/ -r compact`
- **Per wave merge:** `flutter test --reporter compact`
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps

- [ ] `test/features/cart/presentation/providers/cart_notifier_test.dart` — covers COMP-03 CartNotifier unit tests (model `test/features/favorites/presentation/providers/favorites_notifier_test.dart` exactly)
- [ ] `test/features/cart/presentation/providers/cart_comparison_provider_test.dart` — covers COMP-03 aggregation logic (priceMap, match counts, partial totals)
- [ ] `test/features/cart/cart_comparison_page_test.dart` — covers COMP-03 widget render (follows `product_detail_page_test.dart` pattern; uses `SharedPreferences.setMockInitialValues({})` in setUp)

---

## Sources

### Primary (HIGH confidence)

- `lib/features/favorites/presentation/providers/favorites_notifier.dart` — verified AsyncNotifier + SharedPreferences pattern; CartNotifier copies this directly
- `lib/features/favorites/data/favorites_store.dart` — verified deprecated singleton pattern; confirmed NOT to copy
- `lib/features/products/models/market_price_item.dart` — verified field set: marketId, market, price, isDiscounted (no productId field — drives Pitfall 1)
- `lib/features/products/models/product_item.dart` — verified Freezed model with toJson/fromJson
- `lib/features/products/presentation/providers/products_provider.dart` — verified `productMarketPricesProvider` is FutureProvider.family<List<MarketPriceItem>, String>
- `lib/features/markets/data/market_brand_config.dart` — verified 7 slug keys, only color/logo (no display name)
- `lib/features/products/product_detail_page.dart` — verified ElevatedButton.icon favorites pattern; "Sepete Ekle" button goes below line 75
- `lib/features/products/products_page.dart` — verified AppBar has no `actions:` currently; CartAppBarIcon goes in `AppBar(actions: [CartAppBarIcon()])`
- `.planning/phases/04-cart-comparison/04-CONTEXT.md` — locked decisions D-01 through D-11
- `.planning/phases/04-cart-comparison/04-UI-SPEC.md` — component specs, spacing exceptions, copywriting contract
- `test/features/favorites/presentation/providers/favorites_notifier_test.dart` — verified test pattern: ProviderContainer + SharedPreferences.setMockInitialValues({})

### Secondary (MEDIUM confidence)

- Riverpod documentation (training data, Riverpod 2.x): `ref.watch` synchronous-only rule, `Future.wait` fan-out pattern, `AsyncNotifier.future` getter for awaiting current state in mutation methods

---

## Metadata

**Confidence breakdown:**

- Standard stack: HIGH — no new packages; all libraries verified present in pubspec.yaml
- Architecture: HIGH — CartNotifier pattern verified against existing FavoritesNotifier source; fan-out pattern verified against Riverpod 2.x semantics
- Pitfalls: HIGH — Pitfall 1 (no productId on MarketPriceItem) verified by reading the model file; Pitfall 2 (ref.watch in async) is established Riverpod constraint; Pitfalls 3-6 derived from direct code reading
- Test patterns: HIGH — verified against existing test files in the project

**Research date:** 2026-03-30
**Valid until:** 2026-04-30 (stable stack — no fast-moving dependencies)
