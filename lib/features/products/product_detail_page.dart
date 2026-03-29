import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../favorites/presentation/providers/favorites_notifier.dart';
import 'models/product_item.dart';
import 'presentation/providers/products_provider.dart';
import 'widgets/product_info_section.dart';
import 'widgets/product_price_history_section.dart';
import 'widgets/product_price_section.dart';

class ProductDetailPage extends ConsumerWidget {
  final ProductItem product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pricesAsync = ref.watch(productMarketPricesProvider(product.id));

    return Scaffold(
      appBar: AppBar(title: const Text('Ürün Detayı'), centerTitle: true),
      body: pricesAsync.when(
        data: (prices) {
          final cheapestPrice = prices.first.price;
          final cheapestMarket = prices.first.market;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductInfoSection(
                  product: product,
                  cheapestPrice: cheapestPrice,
                  cheapestMarket: cheapestMarket,
                ),
                const SizedBox(height: 28),
                ProductPriceSection(prices: prices),
                const SizedBox(height: 24),
                ProductPriceHistorySection(priceHistory: product.priceHistory),
                const SizedBox(height: 28),
                Consumer(
                  builder: (context, ref, child) {
                    final favorites =
                        ref.watch(favoritesNotifierProvider).valueOrNull ?? [];
                    final isFav = favorites.any((p) => p == product);

                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ref
                              .read(favoritesNotifierProvider.notifier)
                              .toggle(product);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isFav
                                    ? '${product.name} favorilerden çıkarıldı'
                                    : '${product.name} favorilere eklendi',
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                        ),
                        label: Text(
                          isFav ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
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
                onPressed: () =>
                    ref.refresh(productMarketPricesProvider(product.id)),
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
