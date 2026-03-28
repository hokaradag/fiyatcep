import 'package:fiyatcep/core/utils/text_normalizer.dart';

import '../../models/product_item.dart';
import 'product_datasource.dart';

class ProductMockDataSourceImpl implements ProductRemoteDataSource {
  @override
  Future<List<ProductItem>> getAllProducts() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    return const [
      ProductItem(
        id: 'p1',
        marketId: 'm2',
        name: 'Ayçiçek Yağı 1L',
        brand: 'Yudum',
        market: 'A101',
        price: 74.95,
        isDiscounted: true,
      ),
      ProductItem(
        id: 'p2',
        marketId: 'm1',
        name: 'Yarım Yağlı Süt 1L',
        brand: 'Sütaş',
        market: 'Migros',
        price: 36.50,
        isDiscounted: true,
      ),
      ProductItem(
        id: 'p3',
        marketId: 'm3',
        name: 'Makarna 500g',
        brand: 'Filiz',
        market: 'BİM',
        price: 17.50,
        isDiscounted: true,
      ),
      ProductItem(
        id: 'p4',
        marketId: 'm4',
        name: 'Türk Kahvesi 100g',
        brand: 'Mehmet Efendi',
        market: 'ŞOK',
        price: 79.90,
        isDiscounted: false,
      ),
      ProductItem(
        id: 'p5',
        marketId: 'm5',
        name: 'Çamaşır Deterjanı 3kg',
        brand: 'Omo',
        market: 'CarrefourSA',
        price: 145.00,
        isDiscounted: true,
      ),
      ProductItem(
        id: 'p6',
        marketId: 'm1',
        name: 'Un 1kg',
        brand: 'Duru',
        market: 'Migros',
        price: 29.95,
        isDiscounted: false,
      ),
    ];
  }

  @override
  Future<ProductItem> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final products = await getAllProducts();
    return products.firstWhere(
      (p) => p.id == id,
      orElse: () => throw Exception('Ürün bulunamadı'),
    );
  }

  @override
  Future<List<ProductItem>> getProductsByMarket(String marketId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final products = await getAllProducts();
    return products.where((p) => p.marketId == marketId).toList();
  }

  @override
  Future<List<ProductItem>> searchProducts(String query) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (query.isEmpty) return [];

    final products = await getAllProducts();
    final normalizedQuery = TextNormalizer.normalize(query);

    return products.where((product) {
      final searchableText = TextNormalizer.normalize(
        '${product.name} ${product.brand} ${product.market}',
      );
      return searchableText.contains(normalizedQuery);
    }).toList();
  }
}
