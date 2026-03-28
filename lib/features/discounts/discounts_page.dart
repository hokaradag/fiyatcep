import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fiyatcep/core/utils/text_normalizer.dart';

import '../products/models/product_item.dart';
import '../products/product_detail_page.dart';
import 'models/discount_item.dart';
import 'presentation/providers/discounts_provider.dart';
import 'widgets/discount_card.dart';

class DiscountsPage extends ConsumerStatefulWidget {
  const DiscountsPage({super.key});

  @override
  ConsumerState<DiscountsPage> createState() => _DiscountsPageState();
}

class _DiscountsPageState extends ConsumerState<DiscountsPage> {
  late TextEditingController _searchController;
  String searchText = '';
  String selectedMarket = 'Tümü';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> _getMarketOptions(List<DiscountItem> discounts) {
    final markets = discounts.map((item) => item.marketName).toSet().toList()
      ..sort();
    return ['Tümü', ...markets];
  }

  List<DiscountItem> _filterDiscounts(List<DiscountItem> discounts) {
    return discounts.where((item) {
      final normalizedQuery = TextNormalizer.normalize(searchText);
      final normalizedProductName = TextNormalizer.normalize(item.productName);
      final normalizedMarketName = TextNormalizer.normalize(item.marketName);

      final matchesSearch =
          normalizedQuery.isEmpty ||
          normalizedProductName.contains(normalizedQuery) ||
          normalizedMarketName.contains(normalizedQuery);

      final matchesMarket =
          selectedMarket == 'Tümü' || item.marketName == selectedMarket;

      return matchesSearch && matchesMarket;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      searchText = '';
      selectedMarket = 'Tümü';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final discountsAsync = ref.watch(discountsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('İndirimler'), centerTitle: true),
      body: discountsAsync.when(
        data: (allDiscounts) {
          final filteredDiscounts = _filterDiscounts(allDiscounts);
          final marketOptions = _getMarketOptions(allDiscounts);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() => searchText = value);
                  },
                  decoration: InputDecoration(
                    hintText: 'İndirim, ürün veya market ara...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchText.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => searchText = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: DropdownButton<String>(
                  value: selectedMarket,
                  isExpanded: true,
                  items: marketOptions
                      .map(
                        (market) => DropdownMenuItem(
                          value: market,
                          child: Text(market),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedMarket = value);
                    }
                  },
                ),
              ),
              if (searchText.isNotEmpty || selectedMarket != 'Tümü')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.clear),
                      label: const Text('Filtreleri Temizle'),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${filteredDiscounts.length} indirim bulundu',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ),
              ),
              Expanded(
                child: filteredDiscounts.isEmpty
                    ? const Center(
                        child: Text(
                          'Aramanıza uygun indirim bulunamadı',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: filteredDiscounts.length,
                        itemBuilder: (context, index) {
                          final discount = filteredDiscounts[index];
                          return DiscountCard(
                            item: discount,
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
                onPressed: () => ref.refresh(discountsProvider),
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
