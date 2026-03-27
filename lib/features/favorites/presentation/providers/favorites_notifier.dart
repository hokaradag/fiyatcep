import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../products/models/product_item.dart';

class FavoritesNotifier extends AsyncNotifier<List<ProductItem>> {
  static const String _favoritesKey = 'favorite_products';

  @override
  Future<List<ProductItem>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_favoritesKey) ?? [];
    try {
      return stored
          .map((item) => ProductItem.fromJson(jsonDecode(item) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> add(ProductItem product) async {
    final current = await future;
    if (current.any((p) => p == product)) return;
    final updated = [...current, product];
    state = AsyncData(updated);
    await _save(updated);
  }

  Future<void> remove(ProductItem product) async {
    final current = await future;
    final updated = current.where((p) => p != product).toList();
    state = AsyncData(updated);
    await _save(updated);
  }

  Future<void> toggle(ProductItem product) async {
    final current = await future;
    if (current.any((p) => p == product)) {
      await remove(product);
    } else {
      await add(product);
    }
  }

  bool isFavorite(List<ProductItem> favorites, ProductItem product) {
    return favorites.any((p) => p == product);
  }

  Future<void> _save(List<ProductItem> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = favorites.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_favoritesKey, encoded);
  }
}

final favoritesNotifierProvider =
    AsyncNotifierProvider<FavoritesNotifier, List<ProductItem>>(
  FavoritesNotifier.new,
);
