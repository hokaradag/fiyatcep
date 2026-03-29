import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fiyatcep/features/favorites/presentation/providers/favorites_notifier.dart';
import 'package:fiyatcep/features/products/models/product_item.dart';

const _testProduct = ProductItem(
  id: 'p1',
  marketId: 'migros',
  name: 'Test Ürün',
  brand: 'Test Marka',
  market: 'Test Market',
  price: 10.0,
  isDiscounted: false,
);

const _testProduct2 = ProductItem(
  id: 'p2',
  marketId: 'a101',
  name: 'Test Ürün 2',
  brand: 'Test Marka 2',
  market: 'Test Market 2',
  price: 20.0,
  isDiscounted: true,
);

void main() {
  group('FavoritesNotifier', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('build() returns empty list when no stored data', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final favorites = await container.read(favoritesNotifierProvider.future);
      expect(favorites, isEmpty);
    });

    test('build() loads stored favorites from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'favorite_products': [
          '{"id":"p1","marketId":"migros","name":"Test Ürün","brand":"Test Marka","market":"Test Market","price":10.0,"isDiscounted":false}',
        ],
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final favorites = await container.read(favoritesNotifierProvider.future);
      expect(favorites.length, equals(1));
      expect(favorites.first.id, equals('p1'));
    });

    test('add() appends product to favorites and persists', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Ensure build completes first
      await container.read(favoritesNotifierProvider.future);

      await container.read(favoritesNotifierProvider.notifier).add(_testProduct);

      final favorites = await container.read(favoritesNotifierProvider.future);
      expect(favorites.length, equals(1));
      expect(favorites.first, equals(_testProduct));
    });

    test('add() does not add duplicate products', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(favoritesNotifierProvider.future);

      final notifier = container.read(favoritesNotifierProvider.notifier);
      await notifier.add(_testProduct);
      await notifier.add(_testProduct);

      final favorites = await container.read(favoritesNotifierProvider.future);
      expect(favorites.length, equals(1));
    });

    test('remove() removes product from favorites', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(favoritesNotifierProvider.future);

      final notifier = container.read(favoritesNotifierProvider.notifier);
      await notifier.add(_testProduct);
      await notifier.remove(_testProduct);

      final favorites = await container.read(favoritesNotifierProvider.future);
      expect(favorites, isEmpty);
    });

    test('toggle() adds product when not in favorites', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(favoritesNotifierProvider.future);

      await container.read(favoritesNotifierProvider.notifier).toggle(_testProduct);

      final favorites = await container.read(favoritesNotifierProvider.future);
      expect(favorites, contains(_testProduct));
    });

    test('toggle() removes product when already in favorites', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(favoritesNotifierProvider.future);

      final notifier = container.read(favoritesNotifierProvider.notifier);
      await notifier.add(_testProduct);
      await notifier.toggle(_testProduct);

      final favorites = await container.read(favoritesNotifierProvider.future);
      expect(favorites, isNot(contains(_testProduct)));
    });

    test('isFavorite() returns true when product is in list', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(favoritesNotifierProvider.future);

      final notifier = container.read(favoritesNotifierProvider.notifier);
      await notifier.add(_testProduct);
      final favorites = await container.read(favoritesNotifierProvider.future);

      expect(notifier.isFavorite(favorites, _testProduct), isTrue);
      expect(notifier.isFavorite(favorites, _testProduct2), isFalse);
    });
  });
}
