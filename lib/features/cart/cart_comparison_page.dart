import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/providers/cart_comparison_provider.dart';
import 'presentation/providers/cart_notifier.dart';
import 'widgets/cart_market_comparison_card.dart';
import 'widgets/cart_product_list_section.dart';

/// Full-page cart comparison showing per-market totals for all cart items.
///
/// Shows a list of [CartMarketComparisonCard]s sorted by price ascending with
/// the cheapest market highlighted. The cart product list at the top allows
/// item removal.
class CartComparisonPage extends ConsumerWidget {
  const CartComparisonPage({super.key});

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sepeti Temizle?'),
        content: const Text('Tüm ürünler sepetten çıkarılacak.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              ref.read(cartNotifierProvider.notifier).clear();
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text('Temizle'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartNotifierProvider);
    final cart = cartAsync.valueOrNull ?? [];
    final comparisonAsync = ref.watch(cartComparisonProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sepet Karşılaştırması'),
        centerTitle: true,
        actions: [
          if (cart.isNotEmpty)
            TextButton(
              onPressed: () => _showClearDialog(context, ref),
              child: const Text('Sepeti Temizle'),
            ),
        ],
      ),
      body: comparisonAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Fiyatlar yüklenemedi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bağlantınızı kontrol edip tekrar deneyin.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(cartComparisonProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
        data: (results) {
          if (cart.isEmpty) {
            // Empty state guard (normally not reachable from AppBar icon)
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Sepetiniz Boş',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Ürün detay ekranından ürün ekleyerek marketleri karşılaştırabilirsin.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cart product list section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: CartProductListSection(
                    products: cart,
                    onRemove: (p) =>
                        ref.read(cartNotifierProvider.notifier).remove(p),
                  ),
                ),
                const SizedBox(height: 24),
                // Market comparison section header
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Market Karşılaştırması',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Market comparison cards
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: results.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CartMarketComparisonCard(result: results[i]),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
