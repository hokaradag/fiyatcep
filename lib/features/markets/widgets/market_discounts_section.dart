import 'package:flutter/material.dart';

import '../../discounts/models/discount_item.dart';
import '../../products/models/product_item.dart';
import '../../products/product_detail_page.dart';

class MarketDiscountsSection extends StatelessWidget {
  final List<DiscountItem> discounts;

  const MarketDiscountsSection({super.key, required this.discounts});

  String _formatPrice(double price) {
    return '${price.toStringAsFixed(2).replaceAll('.', ',')} ₺';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.local_offer_outlined, size: 20),
                SizedBox(width: 8),
                Text(
                  'Aktif İndirimler',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (discounts.isEmpty)
              const Text(
                'Bu market için henüz aktif indirim verisi bulunmuyor.',
              )
            else
              ...discounts.asMap().entries.map((entry) {
                final index = entry.key;
                final discount = entry.value;

                return Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor:
                            Colors.orange.withValues(alpha: 0.10),
                        child: const Icon(
                          Icons.percent,
                          color: Colors.orange,
                        ),
                      ),
                      title: Text(discount.productName),
                      subtitle: Text(
                        'Eski: ${_formatPrice(discount.oldPrice)}  •  Yeni: ${_formatPrice(discount.newPrice)}',
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
                    if (index != discounts.length - 1)
                      const Divider(height: 8),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }
}
