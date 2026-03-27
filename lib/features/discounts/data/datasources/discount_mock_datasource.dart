import 'package:fiyatcep/core/utils/text_normalizer.dart';

import '../../models/discount_item.dart';
import 'discount_datasource.dart';

class DiscountMockDataSourceImpl implements DiscountRemoteDataSource {
  @override
  Future<List<DiscountItem>> getAllDiscounts() async {
    await Future.delayed(const Duration(milliseconds: 800));

    return const [
      DiscountItem(
        id: 'd1',
        productId: 'p2',
        marketId: 'm1',
        productName: 'Yarım Yağlı Süt 1L',
        marketName: 'Migros',
        oldPrice: 42.95,
        newPrice: 36.50,
        validUntil: '30 Mart 2026',
        note: 'Money üyelerine özel',
      ),
      DiscountItem(
        id: 'd2',
        productId: 'p1',
        marketId: 'm2',
        productName: 'Ayçiçek Yağı 1L',
        marketName: 'A101',
        oldPrice: 89.90,
        newPrice: 74.95,
        validUntil: '29 Mart 2026',
        note: 'Haftanın fırsatı',
      ),
      DiscountItem(
        id: 'd3',
        productId: 'p3',
        marketId: 'm3',
        productName: 'Makarna 500g',
        marketName: 'BİM',
        oldPrice: 21.75,
        newPrice: 17.50,
        validUntil: '1 Nisan 2026',
        note: 'Seçili ürünlerde',
      ),
      DiscountItem(
        id: 'd4',
        productId: 'p5',
        marketId: 'm5',
        productName: 'Çamaşır Deterjanı 3kg',
        marketName: 'CarrefourSA',
        oldPrice: 175.00,
        newPrice: 145.00,
        validUntil: '2 Nisan 2026',
        note: null,
      ),
      DiscountItem(
        id: 'd5',
        productId: 'p4',
        marketId: 'm4',
        productName: 'Türk Kahvesi 100g',
        marketName: 'ŞOK',
        oldPrice: 99.90,
        newPrice: 79.90,
        validUntil: '31 Mart 2026',
        note: 'Stoklarla sınırlı',
      ),
    ];
  }

  @override
  Future<List<DiscountItem>> getDiscountsByMarket(String marketId) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final discounts = await getAllDiscounts();
    return discounts.where((d) => d.marketId == marketId).toList();
  }

  @override
  Future<List<DiscountItem>> searchDiscounts(String query) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (query.isEmpty) return [];

    final discounts = await getAllDiscounts();
    final normalizedQuery = TextNormalizer.normalize(query);

    return discounts.where((discount) {
      final searchableText = TextNormalizer.normalize(
        '${discount.productName} ${discount.marketName}',
      );
      return searchableText.contains(normalizedQuery);
    }).toList();
  }
}
