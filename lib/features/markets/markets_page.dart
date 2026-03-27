// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'market_detail_page.dart';
import 'presentation/providers/markets_provider.dart';
import 'widgets/market_card.dart';

class MarketsPage extends ConsumerWidget {
  const MarketsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketsAsync = ref.watch(marketsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Marketler')),
      body: marketsAsync.when(
        data: (markets) {
          if (markets.isEmpty) {
            return const Center(
              child: Text(
                'Henüz market verisi bulunmuyor.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Marketleri inceleyebilir, aktif indirim sayılarını görebilir ve detay ekranından ilgili ürünleri keşfedebilirsin.',
                    style: TextStyle(fontSize: 14, height: 1.4),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: markets.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final market = markets[index];

                    return MarketCard(
                      market: market,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MarketDetailPage(market: market),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Hata: ${error.toString()}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(marketsProvider);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
