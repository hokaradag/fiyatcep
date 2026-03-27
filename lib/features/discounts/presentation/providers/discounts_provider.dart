import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fiyatcep/core/errors/exceptions.dart';
import '../../models/discount_item.dart';
import '../../../../shared/providers/repository_providers.dart';

final discountsProvider = FutureProvider<List<DiscountItem>>((ref) async {
  final repository = ref.watch(discountRepositoryProvider);
  final result = await repository.getAllDiscounts();

  return result.when(
    success: (data) => data,
    failure: (message, code) => throw AppException(message: message, code: code),
    loading: () => throw StateError('Unexpected loading state in provider'),
  );
});

final discountSearchProvider =
    FutureProvider.family<List<DiscountItem>, String>((ref, query) async {
      final repository = ref.watch(discountRepositoryProvider);
      final result = await repository.searchDiscounts(query);

      return result.when(
        success: (data) => data,
        failure: (message, code) => throw AppException(message: message, code: code),
        loading: () => throw StateError('Unexpected loading state in provider'),
      );
    });

final discountsByMarketProvider =
    FutureProvider.family<List<DiscountItem>, String>((ref, marketId) async {
      final repository = ref.watch(discountRepositoryProvider);
      final result = await repository.getDiscountsByMarket(marketId);

      return result.when(
        success: (data) => data,
        failure: (message, code) => throw AppException(message: message, code: code),
        loading: () => throw StateError('Unexpected loading state in provider'),
      );
    });
