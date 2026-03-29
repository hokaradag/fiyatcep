import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client_provider.dart';
import '../../features/products/data/datasources/product_datasource.dart';
import '../../features/products/data/datasources/product_mock_datasource.dart';
import '../../features/products/data/datasources/product_remote_datasource.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/markets/data/datasources/market_datasource.dart';
import '../../features/markets/data/datasources/market_mock_datasource.dart';
import '../../features/markets/data/datasources/market_remote_datasource.dart';
import '../../features/markets/data/repositories/market_repository_impl.dart';
import '../../features/markets/domain/repositories/market_repository.dart';
import '../../features/discounts/data/datasources/discount_datasource.dart';
import '../../features/discounts/data/datasources/discount_mock_datasource.dart';
import '../../features/discounts/data/datasources/discount_remote_datasource.dart';
import '../../features/discounts/data/repositories/discount_repository_impl.dart';
import '../../features/discounts/domain/repositories/discount_repository.dart';

// UAT: remote datasource providers kept for easy reactivation once API is live
final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProductRemoteDataSourceImpl(apiClient: apiClient);
});

// Product Repository
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(remoteDataSource: ProductMockDataSourceImpl());
});

// UAT: remote datasource providers kept for easy reactivation once API is live
final marketRemoteDataSourceProvider = Provider<MarketRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MarketRemoteDataSourceImpl(apiClient: apiClient);
});

// Market Repository
final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  return MarketRepositoryImpl(remoteDataSource: MarketMockDataSourceImpl());
});

// UAT: remote datasource providers kept for easy reactivation once API is live
final discountRemoteDataSourceProvider = Provider<DiscountRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DiscountRemoteDataSourceImpl(apiClient: apiClient);
});

// Discount Repository
final discountRepositoryProvider = Provider<DiscountRepository>((ref) {
  return DiscountRepositoryImpl(remoteDataSource: DiscountMockDataSourceImpl());
});
