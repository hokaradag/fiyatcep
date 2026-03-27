// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fiyatcep/core/utils/text_normalizer.dart';

import '../models/market_item.dart';

class MarketCard extends StatelessWidget {
  final MarketItem market;
  final VoidCallback? onTap;

  const MarketCard({super.key, required this.market, this.onTap});

  IconData _getMarketIcon(String marketName) {
    switch (TextNormalizer.normalize(marketName)) {
      case 'migros':
        return Icons.storefront;
      case 'a101':
        return Icons.local_mall_outlined;
      case 'bim':
        return Icons.shopping_basket_outlined;
      case 'sok':
        return Icons.local_offer_outlined;
      case 'carrefoursa':
        return Icons.shopping_cart_outlined;
      default:
        return Icons.store_outlined;
    }
  }

  Color _getAccentColor(String marketName) {
    switch (TextNormalizer.normalize(marketName)) {
      case 'migros':
        return Colors.orange;
      case 'a101':
        return Colors.blue;
      case 'bim':
        return Colors.red;
      case 'sok':
        return Colors.deepOrange;
      case 'carrefoursa':
        return Colors.indigo;
      default:
        return Colors.green;
    }
  }

  String _formatBranchCount(int count) {
    return '${count.toString()}+ şube';
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _getAccentColor(market.name);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Üst kısım
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getMarketIcon(market.name),
                      color: accentColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      market.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${market.activeDiscountCount} indirim',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                market.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(
                    Icons.location_city_outlined,
                    size: 18,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatBranchCount(market.branchCount),
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: market.supportsOnlineOrder
                          ? Colors.blue.withOpacity(0.10)
                          : Colors.grey.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      market.supportsOnlineOrder
                          ? 'Online sipariş var'
                          : 'Online sipariş yok',
                      style: TextStyle(
                        color: market.supportsOnlineOrder
                            ? Colors.blue.shade700
                            : Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: market.hasLoyaltyProgram
                          ? Colors.purple.withOpacity(0.10)
                          : Colors.grey.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      market.hasLoyaltyProgram
                          ? 'Sadakat programı var'
                          : 'Sadakat programı yok',
                      style: TextStyle(
                        color: market.hasLoyaltyProgram
                            ? Colors.purple.shade700
                            : Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
