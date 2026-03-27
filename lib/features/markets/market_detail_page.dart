import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../discounts/presentation/providers/discounts_provider.dart';
import '../products/presentation/providers/products_provider.dart';
import 'models/market_item.dart';
import 'widgets/market_detail_header_widget.dart';
import 'widgets/market_discounts_section.dart';
import 'widgets/market_products_section.dart';

class MarketDetailPage extends ConsumerWidget {
  final MarketItem market;

  const MarketDetailPage({super.key, required this.market});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsByMarketProvider(market.id));
    final discountsAsync = ref.watch(discountsByMarketProvider(market.id));

    return Scaffold(
      appBar: AppBar(title: Text(market.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          productsAsync.maybeWhen(
            data: (products) => discountsAsync.maybeWhen(
              data: (discounts) => MarketDetailHeaderWidget(
                market: market,
                productCount: products.length,
                discountCount: discounts.length,
              ),
              orElse: () => MarketDetailHeaderWidget(
                market: market,
                productCount: 0,
                discountCount: 0,
              ),
            ),
            orElse: () => MarketDetailHeaderWidget(
              market: market,
              productCount: 0,
              discountCount: 0,
            ),
          ),
          const SizedBox(height: 16),
          productsAsync.when(
            data: (products) => MarketProductsSection(products: products),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stackTrace) => Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 40,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 12),
                      Text('Ürünler yüklenemedi: ${error.toString()}'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          discountsAsync.when(
            data: (discounts) => MarketDiscountsSection(discounts: discounts),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stackTrace) => Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 40,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 12),
                      Text('İndirimler yüklenemedi: ${error.toString()}'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
