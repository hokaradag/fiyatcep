import '../../models/discount_item.dart';

abstract class DiscountRemoteDataSource {
  Future<List<DiscountItem>> getAllDiscounts();
  Future<List<DiscountItem>> getDiscountsByMarket(String marketId);
  Future<List<DiscountItem>> searchDiscounts(String query);
}
