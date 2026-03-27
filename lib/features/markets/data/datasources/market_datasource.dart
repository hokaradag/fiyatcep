import '../../models/market_item.dart';

abstract class MarketRemoteDataSource {
  Future<List<MarketItem>> getAllMarkets();
  Future<MarketItem> getMarketById(String id);
  Future<List<MarketItem>> searchMarkets(String query);
}
