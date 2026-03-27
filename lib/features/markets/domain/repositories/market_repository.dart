import '../../models/market_item.dart';
import '../../../../core/errors/result.dart';

abstract class MarketRepository {
  Future<Result<List<MarketItem>>> getAllMarkets();
  Future<Result<MarketItem>> getMarketById(String id);
  Future<Result<List<MarketItem>>> searchMarkets(String query);
}
