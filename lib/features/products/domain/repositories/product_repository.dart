import '../../models/product_item.dart';
import '../../../../core/errors/result.dart';

abstract class ProductRepository {
  Future<Result<List<ProductItem>>> getAllProducts();
  Future<Result<ProductItem>> getProductById(String id);
  Future<Result<List<ProductItem>>> searchProducts(String query);
  Future<Result<List<ProductItem>>> getProductsByMarket(String marketId);
}
