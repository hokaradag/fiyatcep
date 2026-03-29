import 'package:fiyatcep/core/utils/text_normalizer.dart';

import '../../models/price_point.dart';
import '../../models/product_item.dart';
import 'product_datasource.dart';

class ProductMockDataSourceImpl implements ProductRemoteDataSource {
  @override
  Future<List<ProductItem>> getAllProducts() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    return [
      ProductItem(
        id: 'p1',
        marketId: 'a101',
        name: 'Ayçiçek Yağı 1L',
        brand: 'Yudum',
        market: 'A101',
        price: 74.95,
        isDiscounted: true,
        priceHistory: [
          // Within last 7 days (enables 1H tab — 3 points)
          PricePoint(price: 76.50, date: DateTime.utc(2026, 3, 22)),
          PricePoint(price: 75.80, date: DateTime.utc(2026, 3, 25)),
          PricePoint(price: 74.95, date: DateTime.utc(2026, 3, 28)),
          // Within last 30 days (enables 1A tab — 2 more points)
          PricePoint(price: 78.90, date: DateTime.utc(2026, 3, 1)),
          PricePoint(price: 77.25, date: DateTime.utc(2026, 3, 10)),
          // Within last 90 days (enables 3A tab — 2 more points)
          PricePoint(price: 82.00, date: DateTime.utc(2026, 1, 15)),
          PricePoint(price: 80.50, date: DateTime.utc(2026, 2, 1)),
          // Within last 365 days (enables 1Y tab — 3 more points)
          PricePoint(price: 69.90, date: DateTime.utc(2025, 5, 1)),
          PricePoint(price: 72.50, date: DateTime.utc(2025, 8, 15)),
          PricePoint(price: 79.00, date: DateTime.utc(2025, 11, 20)),
        ],
      ),
      ProductItem(
        id: 'p2',
        marketId: 'migros',
        name: 'Yarım Yağlı Süt 1L',
        brand: 'Sütaş',
        market: 'Migros',
        price: 36.50,
        isDiscounted: true,
        priceHistory: [
          // Within last 7 days (enables 1H tab — 3 points)
          PricePoint(price: 35.90, date: DateTime.utc(2026, 3, 22)),
          PricePoint(price: 36.25, date: DateTime.utc(2026, 3, 25)),
          PricePoint(price: 36.50, date: DateTime.utc(2026, 3, 28)),
          // Within last 30 days (enables 1A tab — 2 more points)
          PricePoint(price: 34.50, date: DateTime.utc(2026, 3, 1)),
          PricePoint(price: 35.00, date: DateTime.utc(2026, 3, 10)),
          // Within last 90 days (enables 3A tab — 3 more points)
          PricePoint(price: 32.90, date: DateTime.utc(2026, 1, 15)),
          PricePoint(price: 33.50, date: DateTime.utc(2026, 2, 1)),
          PricePoint(price: 34.00, date: DateTime.utc(2026, 2, 20)),
          // NO points older than 90 days — 1Y tab stays disabled for p2
        ],
      ),
      const ProductItem(
        id: 'p3',
        marketId: 'bim',
        name: 'Makarna 500g',
        brand: 'Filiz',
        market: 'BİM',
        price: 17.50,
        isDiscounted: true,
      ),
      const ProductItem(
        id: 'p4',
        marketId: 'sok',
        name: 'Türk Kahvesi 100g',
        brand: 'Mehmet Efendi',
        market: 'ŞOK',
        price: 79.90,
        isDiscounted: false,
      ),
      const ProductItem(
        id: 'p5',
        marketId: 'carrefoursa',
        name: 'Çamaşır Deterjanı 3kg',
        brand: 'Omo',
        market: 'CarrefourSA',
        price: 145.00,
        isDiscounted: true,
      ),
      const ProductItem(
        id: 'p6',
        marketId: 'migros',
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
