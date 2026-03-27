import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fiyatcep/core/errors/exceptions.dart';
import '../../models/market_item.dart';
import '../../../../shared/providers/repository_providers.dart';

final marketsProvider = FutureProvider<List<MarketItem>>((ref) async {
  final repository = ref.watch(marketRepositoryProvider);
  final result = await repository.getAllMarkets();

  return result.when(
    success: (data) => data,
    failure: (message, code) => throw AppException(message: message, code: code),
    loading: () => throw StateError('Unexpected loading state in provider'),
  );
});

final marketSearchProvider = FutureProvider.family<List<MarketItem>, String>((
  ref,
  query,
) async {
  final repository = ref.watch(marketRepositoryProvider);
  final result = await repository.searchMarkets(query);

  return result.when(
    success: (data) => data,
    failure: (message, code) => throw AppException(message: message, code: code),
    loading: () => throw StateError('Unexpected loading state in provider'),
  );
});

final marketByIdProvider = FutureProvider.family<MarketItem, String>((
  ref,
  id,
) async {
  final repository = ref.watch(marketRepositoryProvider);
  final result = await repository.getMarketById(id);

  return result.when(
    success: (data) => data,
    failure: (message, code) => throw AppException(message: message, code: code),
    loading: () => throw StateError('Unexpected loading state in provider'),
  );
});
