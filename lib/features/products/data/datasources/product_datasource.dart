import '../../models/product_item.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductItem>> getAllProducts();
  Future<ProductItem> getProductById(String id);
  Future<List<ProductItem>> searchProducts(String query);
}

abstract class ProductLocalDataSource {
  Future<void> cacheProducts(List<ProductItem> products);
  Future<List<ProductItem>> getCachedProducts();
  Future<void> clearCache();
}
