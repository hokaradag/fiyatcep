import 'package:flutter/material.dart';
import '../../products/models/product_item.dart';

/// Shows the list of products in the cart with a remove button per row.
///
/// Used at the top of [CartComparisonPage] to let users review and edit
/// their cart before comparing markets.
class CartProductListSection extends StatelessWidget {
  final List<ProductItem> products;
  final void Function(ProductItem) onRemove;

  const CartProductListSection({
    super.key,
    required this.products,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header: "Sepetim (N ürün)"
        Row(
          children: [
            const Text(
              'Sepetim',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '(${products.length} ürün)',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Product rows
        ...products.map(
          (product) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              product.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              product.brand,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            trailing: Semantics(
              label: 'Sepetten çıkar',
              button: true,
              child: IconButton(
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: Colors.red,
                ),
                onPressed: () => onRemove(product),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
