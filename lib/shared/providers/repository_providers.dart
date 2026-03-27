import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/products/data/datasources/product_datasource.dart';
import '../../features/products/data/datasources/product_mock_datasource.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/markets/data/datasources/market_datasource.dart';
import '../../features/markets/data/datasources/market_mock_datasource.dart';
import '../../features/markets/data/repositories/market_repository_impl.dart';
import '../../features/markets/domain/repositories/market_repository.dart';
import '../../features/discounts/data/datasources/discount_datasource.dart';
import '../../features/discounts/data/datasources/discount_mock_datasource.dart';
import '../../features/discounts/data/repositories/discount_repository_impl.dart';
import '../../features/discounts/domain/repositories/discount_repository.dart';

// Product Repository (using mock data for now)
final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((
  ref,
) {
  return ProductMockDataSourceImpl();
  // TODO: Switch to ProductRemoteDataSourceImpl(apiClient: apiClient) when API is ready
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final remoteDataSource = ref.watch(productRemoteDataSourceProvider);
  return ProductRepositoryImpl(remoteDataSource: remoteDataSource);
});

// Market Repository (using mock data for now)
final marketRemoteDataSourceProvider = Provider<MarketRemoteDataSource>((ref) {
  return MarketMockDataSourceImpl();
  // TODO: Switch to MarketRemoteDataSourceImpl(apiClient: apiClient) when API is ready
});

final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  final remoteDataSource = ref.watch(marketRemoteDataSourceProvider);
  return MarketRepositoryImpl(remoteDataSource: remoteDataSource);
});

// Discount Repository (using mock data for now)
final discountRemoteDataSourceProvider = Provider<DiscountRemoteDataSource>((
  ref,
) {
  return DiscountMockDataSourceImpl();
  // TODO: Switch to DiscountRemoteDataSourceImpl(apiClient: apiClient) when API is ready
});

final discountRepositoryProvider = Provider<DiscountRepository>((ref) {
  final remoteDataSource = ref.watch(discountRemoteDataSourceProvider);
  return DiscountRepositoryImpl(remoteDataSource: remoteDataSource);
});
