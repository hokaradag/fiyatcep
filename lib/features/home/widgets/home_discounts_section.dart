import 'package:flutter/material.dart';

import '../../discounts/models/discount_item.dart';
import '../../products/models/product_item.dart';
import '../../products/product_detail_page.dart';

class HomeDiscountsSection extends StatelessWidget {
  final List<DiscountItem> discounts;

  const HomeDiscountsSection({super.key, required this.discounts});

  String _formatPrice(double price) {
    return '${price.toStringAsFixed(2).replaceAll('.', ',')} ₺';
  }

  @override
  Widget build(BuildContext context) {
    final featuredDiscounts = [...discounts]
      ..sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
    final topDiscounts = featuredDiscounts.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Öne Çıkan İndirimler',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'En yüksek indirim oranına sahip kampanyalara hızlıca göz at.',
              style: TextStyle(color: Colors.grey.shade700, height: 1.35),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (topDiscounts.isEmpty)
          const Text('Şu anda öne çıkan indirim bulunmuyor.')
        else
          ...topDiscounts.map((discount) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.withValues(alpha: 0.12),
                    child: const Icon(
                      Icons.percent,
                      color: Colors.orange,
                    ),
                  ),
                  title: Text(
                    discount.productName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${discount.marketName} • Eski: ${_formatPrice(discount.oldPrice)} • Yeni: ${_formatPrice(discount.newPrice)}',
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '%${discount.discountPercent}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailPage(
                          product: ProductItem(
                            id: discount.productId,
                            marketId: discount.marketId,
                            name: discount.productName,
                            brand: '',
                            market: discount.marketName,
                            price: discount.newPrice,
                            isDiscounted: true,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }),
      ],
    );
  }
}
