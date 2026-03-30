import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../markets/data/market_brand_config.dart';
import '../../../products/models/product_item.dart';
import '../../../products/presentation/providers/products_provider.dart';
import 'cart_notifier.dart';

/// Fallback display names for each market slug ID.
const Map<String, String> _marketDisplayNames = {
  'migros': 'Migros',
  'a101': 'A101',
  'bim': 'BIM',
  'carrefoursa': 'CarrefourSA',
  'sok': 'SOK',
  'tarim-kredi': 'Tarim Kredi',
  'file-market': 'File Market',
};

/// A single row in the per-market product breakdown.
class CartProductRow {
  final ProductItem product;
  final double? price;
  const CartProductRow({required this.product, this.price});

  /// True when this market has a price for this product.
  bool get isMatched => price != null;
}

/// Aggregated comparison result for one market.
class CartMarketResult {
  final String marketId;
  final String marketName;
  final int matchedCount;
  final int totalCount;
  final double partialTotal;
  final List<CartProductRow> rows;
  final bool isCheapest;

  const CartMarketResult({
    required this.marketId,
    required this.marketName,
    required this.matchedCount,
    required this.totalCount,
    required this.partialTotal,
    required this.rows,
    this.isCheapest = false,
  });

  /// True when all cart items are available at this market.
  bool get isFullMatch => matchedCount == totalCount;

  /// Human-readable fraction string, e.g. "3/5 urun mevcut".
  String get matchFraction => '$matchedCount/$totalCount urun mevcut';

  /// Number of cart items NOT available at this market.
  int get missingCount => totalCount - matchedCount;
}

/// Computes per-market totals for all items currently in the cart.
///
/// Fan-out pattern: fetches prices for all cart items concurrently, then
/// aggregates into one [CartMarketResult] per market (7 markets from
/// [marketBrands]).
///
/// Sorting rules:
/// 1. Markets with matchedCount == 0 sort to the bottom (per D-11 /
///    research Open Question 2 — showing 0.00 total at top is dishonest).
/// 2. Among markets with matches, sorted by partialTotal ascending.
///
/// The first non-zero-match market after sorting is marked [isCheapest].
///
/// IMPORTANT: [cartNotifierProvider] is watched **synchronously** before any
/// `await` so Riverpod tracks the dependency correctly (Pitfall 2).
/// [productMarketPricesProvider] is read inside [Future.wait] to avoid
/// ref.watch after await (undefined behavior).
final cartComparisonProvider = FutureProvider<List<CartMarketResult>>((ref) async {
  // Watch cart synchronously — must happen before any await.
  final cart = ref.watch(cartNotifierProvider).valueOrNull ?? [];
  if (cart.isEmpty) return [];

  // Fan-out: fetch prices for all cart items concurrently.
  final allPrices = await Future.wait(
    cart.map((p) => ref.read(productMarketPricesProvider(p.id).future)),
  );

  // Build priceMap: productId -> marketId -> price.
  // Also collect display names seen in price data (preferred over fallback).
  // CRITICAL: Index-based identity (allPrices[i] corresponds to cart[i])
  // because MarketPriceItem has no productId field (Pitfall 1).
  final Map<String, Map<String, double>> priceMap = {};
  final Map<String, String> marketNameFromData = {};

  for (var i = 0; i < cart.length; i++) {
    priceMap[cart[i].id] = {};
    for (final m in allPrices[i]) {
      priceMap[cart[i].id]![m.marketId] = m.price;
      marketNameFromData.putIfAbsent(m.marketId, () => m.market);
    }
  }

  // Build one result per market (all 7 from marketBrands).
  final results = marketBrands.keys.map((marketId) {
    double total = 0.0;
    int matchedCount = 0;
    final rows = <CartProductRow>[];

    for (final product in cart) {
      final price = priceMap[product.id]?[marketId];
      rows.add(CartProductRow(product: product, price: price));
      if (price != null) {
        total += price;
        matchedCount++;
      }
    }

    final marketName =
        marketNameFromData[marketId] ?? _marketDisplayNames[marketId] ?? marketId;

    return CartMarketResult(
      marketId: marketId,
      marketName: marketName,
      matchedCount: matchedCount,
      totalCount: cart.length,
      partialTotal: total,
      rows: rows,
    );
  }).toList();

  // Sort: 0-match markets to bottom, then ascending by partialTotal.
  results.sort((a, b) {
    if (a.matchedCount == 0 && b.matchedCount > 0) return 1;
    if (b.matchedCount == 0 && a.matchedCount > 0) return -1;
    return a.partialTotal.compareTo(b.partialTotal);
  });

  // Mark cheapest: first market with at least one match.
  final cheapestIdx = results.indexWhere((r) => r.matchedCount > 0);
  if (cheapestIdx >= 0) {
    final c = results[cheapestIdx];
    results[cheapestIdx] = CartMarketResult(
      marketId: c.marketId,
      marketName: c.marketName,
      matchedCount: c.matchedCount,
      totalCount: c.totalCount,
      partialTotal: c.partialTotal,
      rows: c.rows,
      isCheapest: true,
    );
  }

  return results;
});
