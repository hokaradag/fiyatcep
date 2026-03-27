import 'package:fiyatcep/core/utils/text_normalizer.dart';

import '../../models/market_item.dart';
import 'market_datasource.dart';

class MarketMockDataSourceImpl implements MarketRemoteDataSource {
  @override
  Future<List<MarketItem>> getAllMarkets() async {
    await Future.delayed(const Duration(milliseconds: 800));

    return const [
      MarketItem(
        id: 'm1',
        name: 'Migros',
        description: 'Geniş ürün yelpazesi ve düzenli kampanyalar sunar.',
        branchCount: 2450,
        activeDiscountCount: 24,
        supportsOnlineOrder: true,
        hasLoyaltyProgram: true,
      ),
      MarketItem(
        id: 'm2',
        name: 'A101',
        description: 'Uygun fiyatlı temel ihtiyaç ürünleriyle öne çıkar.',
        branchCount: 12500,
        activeDiscountCount: 18,
        supportsOnlineOrder: true,
        hasLoyaltyProgram: false,
      ),
      MarketItem(
        id: 'm3',
        name: 'BİM',
        description: 'Günlük alışverişte ekonomik fiyatlarıyla tercih edilir.',
        branchCount: 11000,
        activeDiscountCount: 15,
        supportsOnlineOrder: false,
        hasLoyaltyProgram: false,
      ),
      MarketItem(
        id: 'm4',
        name: 'ŞOK',
        description: 'Kaliteli ürünleri uygun fiyatlarla sunmaktadır.',
        branchCount: 8500,
        activeDiscountCount: 20,
        supportsOnlineOrder: true,
        hasLoyaltyProgram: true,
      ),
      MarketItem(
        id: 'm5',
        name: 'CarrefourSA',
        description: 'Uluslararası mağaza zinciri, premium ürünler.',
        branchCount: 3200,
        activeDiscountCount: 30,
        supportsOnlineOrder: true,
        hasLoyaltyProgram: true,
      ),
    ];
  }

  @override
  Future<MarketItem> getMarketById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final markets = await getAllMarkets();
    return markets.firstWhere(
      (m) => m.id == id,
      orElse: () => throw Exception('Market bulunamadı'),
    );
  }

  @override
  Future<List<MarketItem>> searchMarkets(String query) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (query.isEmpty) return [];

    final markets = await getAllMarkets();
    final normalizedQuery = TextNormalizer.normalize(query);

    return markets.where((market) {
      final searchableText = TextNormalizer.normalize(market.name);
      return searchableText.contains(normalizedQuery);
    }).toList();
  }
}
