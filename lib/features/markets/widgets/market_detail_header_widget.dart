import 'package:flutter/material.dart';

import '../models/market_item.dart';

class MarketDetailHeaderWidget extends StatelessWidget {
  final MarketItem market;
  final int productCount;
  final int discountCount;

  const MarketDetailHeaderWidget({
    super.key,
    required this.market,
    required this.productCount,
    required this.discountCount,
  });

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Market Info Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  market.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  market.description,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildInfoChip(
                      icon: Icons.location_city_outlined,
                      label: '${market.branchCount}+ şube',
                      color: Colors.blue,
                    ),
                    _buildInfoChip(
                      icon: Icons.discount_outlined,
                      label: '${market.activeDiscountCount} indirim',
                      color: Colors.green,
                    ),
                    _buildInfoChip(
                      icon: market.supportsOnlineOrder
                          ? Icons.delivery_dining
                          : Icons.do_not_disturb_alt_outlined,
                      label: market.supportsOnlineOrder
                          ? 'Online sipariş var'
                          : 'Online sipariş yok',
                      color: market.supportsOnlineOrder
                          ? Colors.indigo
                          : Colors.grey,
                    ),
                    _buildInfoChip(
                      icon: market.hasLoyaltyProgram
                          ? Icons.workspace_premium_outlined
                          : Icons.block_outlined,
                      label: market.hasLoyaltyProgram
                          ? 'Sadakat programı var'
                          : 'Sadakat programı yok',
                      color: market.hasLoyaltyProgram
                          ? Colors.purple
                          : Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Statistics Card
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '$productCount',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text('Listelenen Ürün'),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 48,
                  color: Colors.grey.shade300,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '$discountCount',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text('Aktif İndirim'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
