import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../discounts/presentation/providers/discounts_provider.dart';
import '../favorites/presentation/providers/favorites_notifier.dart';
import '../markets/presentation/providers/markets_provider.dart';
import '../products/models/product_item.dart';
import '../products/presentation/providers/products_provider.dart';
import '../products/product_detail_page.dart';
import 'widgets/home_discounts_section.dart';
import 'widgets/home_header_widget.dart';
import 'widgets/home_markets_section.dart';
import 'widgets/home_stats_section.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final marketsAsync = ref.watch(marketsProvider);
    final discountsAsync = ref.watch(discountsProvider);
    final favoritesAsync = ref.watch(favoritesNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ana Sayfa')),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.refresh(productsProvider.future),
            ref.refresh(marketsProvider.future),
            ref.refresh(discountsProvider.future),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const HomeHeaderWidget(),
            const SizedBox(height: 20),
            productsAsync.maybeWhen(
              data: (products) => marketsAsync.maybeWhen(
                data: (markets) => discountsAsync.maybeWhen(
                  data: (discounts) => HomeStatsSection(
                    productCount: products.length,
                    marketCount: markets.length,
                    discountCount: discounts.length,
                    favoriteCount: favoritesAsync.valueOrNull?.length ?? 0,
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),
            discountsAsync.when(
              data: (discounts) => HomeDiscountsSection(discounts: discounts),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Text('Hata: ${error.toString()}'),
              ),
            ),
            const SizedBox(height: 12),
            _HomeFavoritesSection(favoritesAsync: favoritesAsync),
            const SizedBox(height: 12),
            marketsAsync.when(
              data: (markets) => HomeMarketsSection(markets: markets),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Text('Hata: ${error.toString()}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeFavoritesSection extends StatelessWidget {
  final AsyncValue<List<ProductItem>> favoritesAsync;

  const _HomeFavoritesSection({required this.favoritesAsync});

  String _formatPrice(double price) {
    return '${price.toStringAsFixed(2).replaceAll('.', ',')} ₺';
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
              'Favorilerinden Devam Et',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Daha önce kaydettiğin ürünlere buradan hızlıca dönebilirsin.',
              style: TextStyle(color: Colors.grey.shade700, height: 1.35),
            ),
          ],
        ),
        const SizedBox(height: 12),
        favoritesAsync.when(
          data: (favorites) {
            final recentFavorites = favorites.reversed.take(3).toList();

            return recentFavorites.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Henüz favori ürün eklemedin. Ürün detay ekranındaki kalp butonuyla favori ekleyebilirsin.',
                    ),
                  )
                : Column(
                    children: recentFavorites.map((product) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  Colors.red.withValues(alpha: 0.10),
                              child: const Icon(
                                Icons.favorite,
                                color: Colors.red,
                              ),
                            ),
                            title: Text(product.name),
                            subtitle:
                                Text('${product.brand} • ${product.market}'),
                            trailing: Text(
                              _formatPrice(product.price),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProductDetailPage(product: product),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  );
          },
          loading: () => const SizedBox.shrink(),
          error: (e, st) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
