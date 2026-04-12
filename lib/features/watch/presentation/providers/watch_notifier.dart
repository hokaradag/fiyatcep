import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/providers/api_client_provider.dart';

/// Simple data holder for watched IDs.
class WatchList {
  final List<String> productIds;
  final List<String> discountIds;

  const WatchList({
    this.productIds = const [],
    this.discountIds = const [],
  });
}

/// Stores watched product IDs and discount IDs locally.
/// Mirrors FavoritesNotifier pattern (per D-04).
class WatchNotifier extends AsyncNotifier<WatchList> {
  static const String _watchedProductIdsKey = 'watched_product_ids';
  static const String _watchedDiscountIdsKey = 'watched_discount_ids';

  @override
  Future<WatchList> build() async {
    final prefs = await SharedPreferences.getInstance();
    final productIds = prefs.getStringList(_watchedProductIdsKey) ?? [];
    final discountIds = prefs.getStringList(_watchedDiscountIdsKey) ?? [];
    return WatchList(productIds: productIds, discountIds: discountIds);
  }

  Future<void> toggleProduct(String productId) async {
    final current = await future;
    final updated = current.productIds.contains(productId)
        ? current.productIds.where((id) => id != productId).toList()
        : [...current.productIds, productId];
    final newState = WatchList(productIds: updated, discountIds: current.discountIds);
    state = AsyncData(newState);
    await _save(newState);
    await _syncWithBackend(newState);
  }

  Future<void> toggleDiscount(String discountId) async {
    final current = await future;
    final updated = current.discountIds.contains(discountId)
        ? current.discountIds.where((id) => id != discountId).toList()
        : [...current.discountIds, discountId];
    final newState = WatchList(productIds: current.productIds, discountIds: updated);
    state = AsyncData(newState);
    await _save(newState);
    await _syncWithBackend(newState);
  }

  bool isProductWatched(WatchList watchList, String productId) {
    return watchList.productIds.contains(productId);
  }

  bool isDiscountWatched(WatchList watchList, String discountId) {
    return watchList.discountIds.contains(discountId);
  }

  Future<void> _save(WatchList watchList) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_watchedProductIdsKey, watchList.productIds);
    await prefs.setStringList(_watchedDiscountIdsKey, watchList.discountIds);
  }

  Future<void> _syncWithBackend(WatchList watchList) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('fcm_token');
      if (token == null) return;

      // Direct Dio call since ApiClient.post requires a fromJson callback;
      // this is a best-effort fire-and-forget, response body is not needed.
      // Uses apiBaseUrl constant from api_client_provider.dart (single source of truth).
      final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
      await dio.post('/notifications/subscribe', data: {
        'fcmToken': token,
        'productIds': watchList.productIds,
        'discountIds': watchList.discountIds,
      });
    } catch (_) {
      // Best-effort sync -- don't block watch toggle on network failure
    }
  }
}

final watchNotifierProvider =
    AsyncNotifierProvider<WatchNotifier, WatchList>(
  WatchNotifier.new,
);
