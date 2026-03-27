import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../discounts/presentation/providers/discounts_provider.dart';
import '../products/models/product_item.dart';
import '../products/presentation/providers/products_provider.dart';
import '../products/product_detail_page.dart';
import 'models/market_item.dart';

class MarketDetailPage extends ConsumerWidget {
  final MarketItem market;

  const MarketDetailPage({super.key, required this.market});

  String _formatPrice(double price) {
    return '${price.toStringAsFixed(2).replaceAll('.', ',')} ₺';
  }

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

  Widget _buildSectionTitle(String title, {IconData? icon}) {
    return Row(
      children: [
        if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsByMarketProvider(market.id));
    final discountsAsync = ref.watch(discountsByMarketProvider(market.id));

    return Scaffold(
      appBar: AppBar(title: Text(market.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
          productsAsync.maybeWhen(
            data: (products) => discountsAsync.maybeWhen(
              data: (discounts) => Card(
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
                              '${products.length}',
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
                              '${discounts.length}',
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
              orElse: () => const SizedBox.shrink(),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),

          // Products Section
          productsAsync.when(
            data: (products) => Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(
                      'Bu Marketteki Ürünler',
                      icon: Icons.inventory_2_outlined,
                    ),
                    const SizedBox(height: 12),
                    if (products.isEmpty)
                      const Text('Bu market için henüz ürün verisi bulunmuyor.')
                    else
                      ...products.asMap().entries.map((entry) {
                        final index = entry.key;
                        final product = entry.value;

                        return Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: Colors.red.withValues(
                                  alpha: 0.12,
                                ),
                                child: const Icon(
                                  Icons.shopping_bag_outlined,
                                  color: Colors.green,
                                ),
                              ),
                              title: Text(product.name),
                              subtitle: Text(
                                '${product.brand} • ${product.market}',
                              ),
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
                            if (index != products.length - 1)
                              const Divider(height: 8),
                          ],
                        );
                      }),
                  ],
                ),
              ),
            ),
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

          // Discounts Section
          discountsAsync.when(
            data: (discounts) => Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(
                      'Aktif İndirimler',
                      icon: Icons.local_offer_outlined,
                    ),
                    const SizedBox(height: 12),
                    if (discounts.isEmpty)
                      const Text(
                        'Bu market için henüz aktif indirim verisi bulunmuyor.',
                      )
                    else
                      ...discounts.asMap().entries.map((entry) {
                        final index = entry.key;
                        final discount = entry.value;

                        return Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: Colors.orange.withValues(
                                  alpha: 0.10,
                                ),
                                child: const Icon(
                                  Icons.percent,
                                  color: Colors.orange,
                                ),
                              ),
                              title: Text(discount.productName),
                              subtitle: Text(
                                'Eski: ${_formatPrice(discount.oldPrice)}  •  Yeni: ${_formatPrice(discount.newPrice)}',
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
                            if (index != discounts.length - 1)
                              const Divider(height: 8),
                          ],
                        );
                      }),
                  ],
                ),
              ),
            ),
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
