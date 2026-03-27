import 'package:flutter/material.dart';

class HomeStatsSection extends StatelessWidget {
  final int productCount;
  final int marketCount;
  final int discountCount;
  final int favoriteCount;

  const HomeStatsSection({
    super.key,
    required this.productCount,
    required this.marketCount,
    required this.discountCount,
    required this.favoriteCount,
  });

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Genel Durum',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Uygulamadaki mevcut mock veri özetini hızlıca gör.',
              style: TextStyle(color: Colors.grey.shade700, height: 1.35),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.25,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildStatCard(
              icon: Icons.inventory_2_outlined,
              label: 'Ürün',
              value: '$productCount',
              color: Colors.green,
            ),
            _buildStatCard(
              icon: Icons.local_offer_outlined,
              label: 'Aktif İndirim',
              value: '$discountCount',
              color: Colors.orange,
            ),
            _buildStatCard(
              icon: Icons.storefront_outlined,
              label: 'Market',
              value: '$marketCount',
              color: Colors.blue,
            ),
            _buildStatCard(
              icon: Icons.favorite_outline,
              label: 'Favori',
              value: '$favoriteCount',
              color: Colors.red,
            ),
          ],
        ),
      ],
    );
  }
}
