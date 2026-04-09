import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fiyatcep/core/errors/exceptions.dart';
import '../../models/product_item.dart';
import '../../models/market_price_item.dart';
import '../../../../shared/providers/repository_providers.dart';

final productsProvider = FutureProvider<List<ProductItem>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.getAllProducts();

  return result.when(
    success: (data) => data,
    failure: (message, code) => throw AppException(message: message, code: code),
    loading: () => throw StateError('Unexpected loading state in provider'),
  );
});

final productSearchProvider = FutureProvider.family<List<ProductItem>, String>((
  ref,
  query,
) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.searchProducts(query);

  return result.when(
    success: (data) => data,
    failure: (message, code) => throw AppException(message: message, code: code),
    loading: () => throw StateError('Unexpected loading state in provider'),
  );
});

final productByIdProvider = FutureProvider.family<ProductItem, String>((
  ref,
  id,
) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.getProductById(id);

  return result.when(
    success: (data) => data,
    failure: (message, code) => throw AppException(message: message, code: code),
    loading: () => throw StateError('Unexpected loading state in provider'),
  );
});

final productMarketPricesProvider =
    FutureProvider.family<List<MarketPriceItem>, String>((
      ref,
      productId,
    ) async {
      final dataSource = ref.watch(productRemoteDataSourceProvider);
      final prices = await dataSource.getProductPrices(productId);
      return [...prices]..sort((a, b) => a.price.compareTo(b.price));
    });

final productsByMarketProvider =
    FutureProvider.family<List<ProductItem>, String>((ref, marketId) async {
      final repository = ref.watch(productRepositoryProvider);
      final result = await repository.getProductsByMarket(marketId);

      return result.when(
        success: (data) => data,
        failure: (message, code) => throw AppException(message: message, code: code),
        loading: () => throw StateError('Unexpected loading state in provider'),
      );
    });
