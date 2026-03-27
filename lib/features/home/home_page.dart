import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../discounts/presentation/providers/discounts_provider.dart';
import '../favorites/presentation/providers/favorites_notifier.dart';
import '../markets/market_detail_page.dart';
import '../markets/presentation/providers/markets_provider.dart';
import '../products/models/product_item.dart';
import '../products/presentation/providers/products_provider.dart';
import '../products/product_detail_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  String _formatPrice(double price) {
    return '${price.toStringAsFixed(2).replaceAll('.', ',')} ₺';
  }

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

  Widget _buildSectionTitle(String title, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade700, height: 1.35),
          ),
        ],
      ],
    );
  }

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
              Container(
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
                            'FiyatCep’e hoş geldin 👋',
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
              ),

              const SizedBox(height: 20),

              // Stats Section
              _buildSectionTitle(
                'Genel Durum',
                subtitle: 'Uygulamadaki mevcut mock veri özetini hızlıca gör.',
              ),
              const SizedBox(height: 12),
              productsAsync.maybeWhen(
                data: (products) => marketsAsync.maybeWhen(
                  data: (markets) => discountsAsync.maybeWhen(
                    data: (discounts) => GridView.count(
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
                          value: '${products.length}',
                          color: Colors.green,
                        ),
                        _buildStatCard(
                          icon: Icons.local_offer_outlined,
                          label: 'Aktif İndirim',
                          value: '${discounts.length}',
                          color: Colors.orange,
                        ),
                        _buildStatCard(
                          icon: Icons.storefront_outlined,
                          label: 'Market',
                          value: '${markets.length}',
                          color: Colors.blue,
                        ),
                        _buildStatCard(
                          icon: Icons.favorite_outline,
                          label: 'Favori',
                          value: '${favoritesAsync.valueOrNull?.length ?? 0}',
                          color: Colors.red,
                        ),
                      ],
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
                orElse: () => const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),

              // Featured Discounts Section
              _buildSectionTitle(
                'Öne Çıkan İndirimler',
                subtitle:
                    'En yüksek indirim oranına sahip kampanyalara hızlıca göz at.',
              ),
              const SizedBox(height: 12),
              discountsAsync.when(
                data: (allDiscounts) {
                  final featuredDiscounts = [...allDiscounts]
                    ..sort(
                      (a, b) => b.discountPercent.compareTo(a.discountPercent),
                    );
                  final topDiscounts = featuredDiscounts.take(4).toList();

                  return topDiscounts.isEmpty
                      ? const Text('Şu anda öne çıkan indirim bulunmuyor.')
                      : Column(
                          children: topDiscounts.map((discount) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(14),
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        Colors.orange.withValues(alpha: 0.12),
                                    child: const Icon(
                                      Icons.percent,
                                      color: Colors.orange,
                                    ),
                                  ),
                                  title: Text(
                                    discount.productName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      '${discount.marketName} • Eski: ${_formatPrice(discount.oldPrice)} • Yeni: ${_formatPrice(discount.newPrice)}',
                                    ),
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.10),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      '%${discount.discountPercent}',
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ProductDetailPage(
                                          product: ProductItem(
                                            id: discount.productId,
                                            marketId: discount.marketId,
                                            name: discount.productName,
                                            brand: '',
                                            market: discount.marketName,
                                            price: discount.newPrice,
                                            isDiscounted: true,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Text('Hata: ${error.toString()}'),
                ),
              ),

              const SizedBox(height: 12),

              // Favorites Section
              _buildSectionTitle(
                'Favorilerinden Devam Et',
                subtitle:
                    'Daha önce kaydettiğin ürünlere buradan hızlıca dönebilirsin.',
              ),
              const SizedBox(height: 12),
              favoritesAsync.when(
                data: (favorites) {
                  final recentFavorites =
                      favorites.reversed.take(3).toList();

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
                                    backgroundColor: Colors.red.withValues(alpha: 0.10),
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

              const SizedBox(height: 12),

              // Featured Markets Section
              _buildSectionTitle(
                'Öne Çıkan Marketler',
                subtitle:
                    'Aktif indirim sayısına göre öne çıkan marketlere göz at.',
              ),
              const SizedBox(height: 12),
              marketsAsync.when(
                data: (allMarkets) {
                  final topMarkets = [...allMarkets]
                    ..sort(
                      (a, b) => b.activeDiscountCount
                          .compareTo(a.activeDiscountCount),
                    );
                  final highlightedMarkets = topMarkets.take(3).toList();

                  return Column(
                    children: highlightedMarkets.map((market) {
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
                                  builder: (_) =>
                                      MarketDetailPage(market: market),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
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
