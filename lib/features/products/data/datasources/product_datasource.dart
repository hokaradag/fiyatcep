import '../../models/product_item.dart';
import '../../models/market_price_item.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductItem>> getAllProducts();
  Future<ProductItem> getProductById(String id);
  Future<List<ProductItem>> searchProducts(String query);
  Future<List<ProductItem>> getProductsByMarket(String marketId);
  Future<List<MarketPriceItem>> getProductPrices(String productId);
}

abstract class ProductLocalDataSource {
  Future<void> cacheProducts(List<ProductItem> products);
  Future<List<ProductItem>> getCachedProducts();
  Future<void> clearCache();
}
