import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../markets/data/market_brand_config.dart';
import '../presentation/providers/cart_comparison_provider.dart';

/// Formats a price value as Turkish decimal format with TL suffix.
/// Example: 131.20 → "131,20 TL"
String _formatPrice(double price) =>
    '${price.toStringAsFixed(2).replaceAll('.', ',')} TL';

/// Expandable comparison card showing a market's total price for cart items.
///
/// Collapsed view shows market identity, match fraction, total, cheapest badge.
/// Expanded view reveals per-product matched/unmatched breakdown.
class CartMarketComparisonCard extends ConsumerStatefulWidget {
  final CartMarketResult result;

  const CartMarketComparisonCard({super.key, required this.result});

  @override
  ConsumerState<CartMarketComparisonCard> createState() =>
      _CartMarketComparisonCardState();
}

class _CartMarketComparisonCardState
    extends ConsumerState<CartMarketComparisonCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final brand = marketBrands[result.marketId];
    final brandColor = brand?.primaryColor ?? Colors.grey;

    // Match fraction color: green for full match, orange for partial
    final fractionColor =
        result.isFullMatch ? Colors.green : Colors.orange;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() {
            isExpanded = !isExpanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Collapsed row (always visible)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Market logo container
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Icon(
                      Icons.store,
                      color: brandColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Market name + match fraction
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.marketName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          result.matchFraction,
                          style: TextStyle(
                            fontSize: 12,
                            color: fractionColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Total price + cheapest badge
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatPrice(result.partialTotal),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: result.isCheapest
                              ? Colors.green
                              : Colors.black87,
                        ),
                      ),
                      if (result.isCheapest) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'En Uygun',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                ],
              ),
              // Partial match footnote
              if (result.missingCount > 0) ...[
                const SizedBox(height: 8),
                Text(
                  '* ${result.missingCount} ürün bu markette bulunamadı',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
                  ),
                ),
              ],
              // Expanded product breakdown
              if (isExpanded) ...[
                const SizedBox(height: 8),
                const Divider(),
                ...result.rows.map(
                  (row) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          row.isMatched
                              ? Icons.check_circle
                              : Icons.cancel,
                          color:
                              row.isMatched ? Colors.green : Colors.red,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            row.product.name,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        if (row.isMatched)
                          Text(
                            _formatPrice(row.price!),
                            style: const TextStyle(fontSize: 14),
                          )
                        else
                          const Text(
                            'bulunamadı',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
