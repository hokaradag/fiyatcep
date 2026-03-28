import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client_provider.dart';
import '../../features/products/data/datasources/product_datasource.dart';
import '../../features/products/data/datasources/product_remote_datasource.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/markets/data/datasources/market_datasource.dart';
import '../../features/markets/data/datasources/market_remote_datasource.dart';
import '../../features/markets/data/repositories/market_repository_impl.dart';
import '../../features/markets/domain/repositories/market_repository.dart';
import '../../features/discounts/data/datasources/discount_datasource.dart';
import '../../features/discounts/data/datasources/discount_remote_datasource.dart';
import '../../features/discounts/data/repositories/discount_repository_impl.dart';
import '../../features/discounts/domain/repositories/discount_repository.dart';

// Product Repository
final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProductRemoteDataSourceImpl(apiClient: apiClient);
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final remoteDataSource = ref.watch(productRemoteDataSourceProvider);
  return ProductRepositoryImpl(remoteDataSource: remoteDataSource);
});

// Market Repository
final marketRemoteDataSourceProvider = Provider<MarketRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MarketRemoteDataSourceImpl(apiClient: apiClient);
});

final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  final remoteDataSource = ref.watch(marketRemoteDataSourceProvider);
  return MarketRepositoryImpl(remoteDataSource: remoteDataSource);
});

// Discount Repository
final discountRemoteDataSourceProvider = Provider<DiscountRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DiscountRemoteDataSourceImpl(apiClient: apiClient);
});

final discountRepositoryProvider = Provider<DiscountRepository>((ref) {
  final remoteDataSource = ref.watch(discountRemoteDataSourceProvider);
  return DiscountRepositoryImpl(remoteDataSource: remoteDataSource);
});
