import 'package:flutter/material.dart';

import '../../markets/market_detail_page.dart';
import '../../markets/models/market_item.dart';

class HomeMarketsSection extends StatelessWidget {
  final List<MarketItem> markets;

  const HomeMarketsSection({super.key, required this.markets});

  @override
  Widget build(BuildContext context) {
    final topMarkets = [...markets]
      ..sort((a, b) => b.activeDiscountCount.compareTo(a.activeDiscountCount));
    final highlightedMarkets = topMarkets.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Öne Çıkan Marketler',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Aktif indirim sayısına göre öne çıkan marketlere göz at.',
              style: TextStyle(color: Colors.grey.shade700, height: 1.35),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...highlightedMarkets.map((market) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withValues(alpha: 0.12),
                  child: const Icon(
                    Icons.storefront,
                    color: Colors.blue,
                  ),
                ),
                title: Text(
                  market.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${market.activeDiscountCount} aktif indirim • ${market.branchCount}+ şube',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MarketDetailPage(market: market),
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
