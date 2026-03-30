// STUB — RED phase placeholder. Replace in GREEN phase.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../products/models/product_item.dart';

class CartProductRow {
  final ProductItem product;
  final double? price;
  const CartProductRow({required this.product, this.price});
  bool get isMatched => price != null;
}

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

  bool get isFullMatch => matchedCount == totalCount;
  String get matchFraction => '$matchedCount/$totalCount urun mevcut';
  int get missingCount => totalCount - matchedCount;
}

final cartComparisonProvider = FutureProvider<List<CartMarketResult>>((ref) async {
  // STUB: returns empty list — tests should fail
  return [];
});
