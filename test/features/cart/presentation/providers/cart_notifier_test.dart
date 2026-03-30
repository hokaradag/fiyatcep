import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fiyatcep/features/cart/presentation/providers/cart_notifier.dart';
import 'package:fiyatcep/features/products/models/product_item.dart';

const _testProduct = ProductItem(
  id: 'p1',
  marketId: 'migros',
  name: 'Test Sut',
  brand: 'Icim',
  market: 'Migros',
  price: 10.0,
  isDiscounted: false,
);

const _testProduct2 = ProductItem(
  id: 'p2',
  marketId: 'a101',
  name: 'Test Ekmek',
  brand: 'Uno',
  market: 'A101',
  price: 5.0,
  isDiscounted: true,
);

void main() {
  group('CartNotifier', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('build() returns empty list when no stored data', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final cart = await container.read(cartNotifierProvider.future);
      expect(cart, isEmpty);
    });

    test('build() loads stored cart from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'cart_products': [
          '{"id":"p1","marketId":"migros","name":"Test Sut","brand":"Icim","market":"Migros","price":10.0,"isDiscounted":false,"priceHistory":[]}',
        ],
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final cart = await container.read(cartNotifierProvider.future);
      expect(cart.length, equals(1));
      expect(cart.first.id, equals('p1'));
    });

    test('add() appends product and state contains the product', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(cartNotifierProvider.future);

      await container.read(cartNotifierProvider.notifier).add(_testProduct);

      final cart = await container.read(cartNotifierProvider.future);
      expect(cart.length, equals(1));
      expect(cart.first.id, equals('p1'));
    });

    test('add() with same product.id twice results in list length 1 (id-based dedup)', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(cartNotifierProvider.future);

      // Two different ProductItem instances with same id but different price
      const productV1 = ProductItem(
        id: 'p1',
        marketId: 'migros',
        name: 'Test Sut',
        brand: 'Icim',
        market: 'Migros',
        price: 10.0,
        isDiscounted: false,
      );
      const productV2 = ProductItem(
        id: 'p1',
        marketId: 'migros',
        name: 'Test Sut',
        brand: 'Icim',
        market: 'Migros',
        price: 15.0, // Different price
        isDiscounted: false,
      );

      final notifier = container.read(cartNotifierProvider.notifier);
      await notifier.add(productV1);
      await notifier.add(productV2);

      final cart = await container.read(cartNotifierProvider.future);
      expect(cart.length, equals(1));
    });

    test('remove() removes product by id from cart', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(cartNotifierProvider.future);

      final notifier = container.read(cartNotifierProvider.notifier);
      await notifier.add(_testProduct);
      await notifier.add(_testProduct2);
      await notifier.remove(_testProduct);

      final cart = await container.read(cartNotifierProvider.future);
      expect(cart.length, equals(1));
      expect(cart.first.id, equals('p2'));
    });

    test('clear() empties the cart completely', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(cartNotifierProvider.future);

      final notifier = container.read(cartNotifierProvider.notifier);
      await notifier.add(_testProduct);
      await notifier.add(_testProduct2);
      await notifier.clear();

      final cart = await container.read(cartNotifierProvider.future);
      expect(cart, isEmpty);
    });

    test('isInCart() returns true when product.id matches an item in list, false otherwise', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(cartNotifierProvider.future);

      final notifier = container.read(cartNotifierProvider.notifier);
      await notifier.add(_testProduct);
      final cart = await container.read(cartNotifierProvider.future);

      expect(notifier.isInCart(cart, _testProduct), isTrue);
      expect(notifier.isInCart(cart, _testProduct2), isFalse);
    });

    test('persistence — add product, new container loads it from SharedPreferences', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(cartNotifierProvider.future);
      await container.read(cartNotifierProvider.notifier).add(_testProduct);

      // Verify SharedPreferences has the data
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList('cart_products');
      expect(stored, isNotNull);
      expect(stored!.length, equals(1));

      final decoded = jsonDecode(stored.first) as Map<String, dynamic>;
      expect(decoded['id'], equals('p1'));
    });
  });
}
