import '../../models/discount_item.dart';
import '../../../../core/errors/result.dart';

abstract class DiscountRepository {
  Future<Result<List<DiscountItem>>> getAllDiscounts();
  Future<Result<List<DiscountItem>>> getDiscountsByMarket(String marketId);
  Future<Result<List<DiscountItem>>> searchDiscounts(String query);
}
