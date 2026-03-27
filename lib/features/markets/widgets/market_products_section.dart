import 'package:flutter/material.dart';

import '../../products/models/product_item.dart';
import '../../products/product_detail_page.dart';

class MarketProductsSection extends StatelessWidget {
  final List<ProductItem> products;

  const MarketProductsSection({super.key, required this.products});

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
                Icon(Icons.inventory_2_outlined, size: 20),
                SizedBox(width: 8),
                Text(
                  'Bu Marketteki Ürünler',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (products.isEmpty)
              const Text('Bu market için henüz ürün verisi bulunmuyor.')
            else
              ...products.asMap().entries.map((entry) {
                final index = entry.key;
                final product = entry.value;

                return Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Colors.red.withValues(alpha: 0.12),
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.green,
                        ),
                      ),
                      title: Text(product.name),
                      subtitle: Text(
                        '${product.brand} • ${product.market}',
                      ),
                      trailing: Text(
                        _formatPrice(product.price),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailPage(product: product),
                          ),
                        );
                      },
                    ),
                    if (index != products.length - 1)
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
