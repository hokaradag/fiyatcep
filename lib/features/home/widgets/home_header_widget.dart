import 'package:flutter/material.dart';

class HomeHeaderWidget extends StatelessWidget {
  const HomeHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.green,
                child: Icon(
                  Icons.shopping_cart_checkout,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'FiyatCep\'e hoş geldin 👋',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Market fiyatlarını karşılaştırabilir, indirimleri takip edebilir ve favori ürünlerini daha sonra hızlıca yeniden görüntüleyebilirsin.',
            style: TextStyle(
              color: Colors.grey.shade800,
              height: 1.45,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
