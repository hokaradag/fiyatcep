import 'package:flutter/material.dart';

import '../models/product_item.dart';

class ProductInfoSection extends StatelessWidget {
  final ProductItem product;
  final double cheapestPrice;
  final String cheapestMarket;

  const ProductInfoSection({
    super.key,
    required this.product,
    required this.cheapestPrice,
    required this.cheapestMarket,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.shopping_bag,
            size: 64,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          product.name,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Marka: ${product.brand}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'En Uygun Fiyat',
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(height: 6),
              Text(
                '${cheapestPrice.toStringAsFixed(2)} ₺',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'En uygun market: $cheapestMarket',
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
