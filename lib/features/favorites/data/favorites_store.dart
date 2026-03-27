// DEPRECATED: Use FavoritesNotifier instead. Safe to delete after Phase 1 verification.
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../products/models/product_item.dart';

class FavoritesStore {
  static const String _favoritesKey = 'favorite_products';

  static final ValueNotifier<List<ProductItem>> favoritesNotifier =
      ValueNotifier<List<ProductItem>>([]);

  static SharedPreferences? _prefs;
  static bool _isInitialized = false;

  static List<ProductItem> get favorites => favoritesNotifier.value;

  static Future<void> init() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();
    await _loadFavorites();
    _isInitialized = true;
  }

  static bool isFavorite(ProductItem product) {
    return favorites.any((item) => item == product);
  }

  static void add(ProductItem product) {
    if (isFavorite(product)) return;

    favoritesNotifier.value = [...favorites, product];
    unawaited(_saveFavorites());
  }

  static void remove(ProductItem product) {
    favoritesNotifier.value = favorites
        .where((item) => item != product)
        .toList();

    unawaited(_saveFavorites());
  }

  static void toggle(ProductItem product) {
    if (isFavorite(product)) {
      remove(product);
    } else {
      add(product);
    }
  }

  static Future<void> _loadFavorites() async {
    try {
      final storedList = _prefs?.getStringList(_favoritesKey) ?? [];

      final loadedFavorites = storedList
          .map((item) => ProductItem.fromJson(jsonDecode(item)))
          .toList();

      favoritesNotifier.value = loadedFavorites;
    } catch (_) {
      favoritesNotifier.value = [];
    }
  }

  static Future<void> _saveFavorites() async {
    final prefs = _prefs;
    if (prefs == null) return;

    final encodedList = favorites
        .map((product) => jsonEncode(product.toJson()))
        .toList();

    await prefs.setStringList(_favoritesKey, encodedList);
  }
}
