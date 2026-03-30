import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../products/models/product_item.dart';

class CartNotifier extends AsyncNotifier<List<ProductItem>> {
  static const String _cartKey = 'cart_products';

  @override
  Future<List<ProductItem>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_cartKey) ?? [];
    try {
      return stored
          .map((item) =>
              ProductItem.fromJson(jsonDecode(item) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> add(ProductItem product) async {
    final current = await future;
    if (current.any((p) => p.id == product.id)) return;
    final updated = [...current, product];
    state = AsyncData(updated);
    await _save(updated);
  }

  Future<void> remove(ProductItem product) async {
    final current = await future;
    final updated = current.where((p) => p.id != product.id).toList();
    state = AsyncData(updated);
    await _save(updated);
  }

  Future<void> clear() async {
    state = const AsyncData([]);
    await _save([]);
  }

  bool isInCart(List<ProductItem> cart, ProductItem product) {
    return cart.any((p) => p.id == product.id);
  }

  Future<void> _save(List<ProductItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = items.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_cartKey, encoded);
  }
}

final cartNotifierProvider =
    AsyncNotifierProvider<CartNotifier, List<ProductItem>>(CartNotifier.new);
