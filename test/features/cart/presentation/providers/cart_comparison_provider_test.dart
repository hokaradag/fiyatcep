import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fiyatcep/features/cart/presentation/providers/cart_comparison_provider.dart';
import 'package:fiyatcep/features/cart/presentation/providers/cart_notifier.dart';
import 'package:fiyatcep/features/products/models/market_price_item.dart';
import 'package:fiyatcep/features/products/models/product_item.dart';
import 'package:fiyatcep/features/products/presentation/providers/products_provider.dart';

// Test fixture products
const _p1 = ProductItem(
  id: 'p1',
  marketId: 'migros',
  name: 'Sut',
  brand: 'Icim',
  market: 'Migros',
  price: 10.0,
  isDiscounted: false,
);

const _p2 = ProductItem(
  id: 'p2',
  marketId: 'a101',
  name: 'Ekmek',
  brand: 'Uno',
  market: 'A101',
  price: 5.0,
  isDiscounted: false,
);

// p1 available at migros (12.0) and a101 (13.0)
// p2 available at migros (6.0) only
const _p1Prices = [
  MarketPriceItem(marketId: 'migros', market: 'Migros', price: 12.0, isDiscounted: false),
  MarketPriceItem(marketId: 'a101', market: 'A101', price: 13.0, isDiscounted: false),
];
const _p2Prices = [
  MarketPriceItem(marketId: 'migros', market: 'Migros', price: 6.0, isDiscounted: false),
];

/// Notifier that returns a fixed cart without touching SharedPreferences.
class _FixedCartNotifier extends CartNotifier {
  final List<ProductItem> cart;
  _FixedCartNotifier(this.cart);

  @override
  Future<List<ProductItem>> build() async => cart;
}

/// Creates a ProviderContainer with controlled cart and price data,
/// and awaits cart initialization so cartNotifierProvider is in AsyncData
/// state before callers use cartComparisonProvider.
Future<ProviderContainer> _makeContainer({
  List<ProductItem> cart = const [],
  Map<String, List<MarketPriceItem>> prices = const {},
}) async {
  final container = ProviderContainer(
    overrides: [
      cartNotifierProvider.overrideWith(() => _FixedCartNotifier(cart)),
      productMarketPricesProvider.overrideWith((ref, id) async {
        return prices[id] ?? [];
      }),
    ],
  );
  // Prime the cart notifier so it is in AsyncData state (not AsyncLoading)
  // before cartComparisonProvider reads it via ref.watch.
  await container.read(cartNotifierProvider.future);
  return container;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('cartComparisonProvider', () {
    test('Test 1: Returns empty list when cart is empty', () async {
      final container = await _makeContainer();
      addTearDown(container.dispose);

      final results = await container.read(cartComparisonProvider.future);
      expect(results, isEmpty);
    });

    test('Test 2: Returns 7 CartMarketResult entries (one per marketBrands key) when cart has items', () async {
      final container = await _makeContainer(
        cart: [_p1],
        prices: {'p1': _p1Prices},
      );
      addTearDown(container.dispose);

      final results = await container.read(cartComparisonProvider.future);
      expect(results.length, equals(7));
    });

    test('Test 3: Correct matchedCount — p1 in migros+a101, p2 in migros only', () async {
      final container = await _makeContainer(
        cart: [_p1, _p2],
        prices: {'p1': _p1Prices, 'p2': _p2Prices},
      );
      addTearDown(container.dispose);

      final results = await container.read(cartComparisonProvider.future);

      final migros = results.firstWhere((r) => r.marketId == 'migros');
      final a101 = results.firstWhere((r) => r.marketId == 'a101');
      final bim = results.firstWhere((r) => r.marketId == 'bim');

      expect(migros.matchedCount, equals(2));
      expect(a101.matchedCount, equals(1));
      expect(bim.matchedCount, equals(0));
    });

    test('Test 4: Correct partialTotal — sum of matched prices per market', () async {
      final container = await _makeContainer(
        cart: [_p1, _p2],
        prices: {'p1': _p1Prices, 'p2': _p2Prices},
      );
      addTearDown(container.dispose);

      final results = await container.read(cartComparisonProvider.future);

      final migros = results.firstWhere((r) => r.marketId == 'migros');
      final a101 = results.firstWhere((r) => r.marketId == 'a101');

      // migros: p1=12.0 + p2=6.0 = 18.0
      expect(migros.partialTotal, closeTo(18.0, 0.001));
      // a101: p1=13.0 only = 13.0
      expect(a101.partialTotal, closeTo(13.0, 0.001));
    });

    test('Test 5: Results sorted by partialTotal ascending, 0-match markets at bottom', () async {
      final container = await _makeContainer(
        cart: [_p1, _p2],
        prices: {'p1': _p1Prices, 'p2': _p2Prices},
      );
      addTearDown(container.dispose);

      final results = await container.read(cartComparisonProvider.future);

      // a101 (13.0) < migros (18.0), so a101 should be first (position 0)
      // then migros (18.0) at position 1
      // then 5 zero-match markets at the bottom
      expect(results.first.marketId, equals('a101'));
      expect(results[1].marketId, equals('migros'));

      // All 0-match markets are at the bottom
      final zeroMatchResults = results.where((r) => r.matchedCount == 0).toList();
      final nonZeroResults = results.where((r) => r.matchedCount > 0).toList();
      expect(nonZeroResults.length, equals(2));
      expect(zeroMatchResults.length, equals(5));

      // First zero-match index must come after last non-zero index
      final firstZeroIndex = results.indexWhere((r) => r.matchedCount == 0);
      final lastNonZeroIndex = results.lastIndexWhere((r) => r.matchedCount > 0);
      expect(firstZeroIndex, greaterThan(lastNonZeroIndex));
    });

    test('Test 6: matchFraction getter returns correct string format "N/M urun mevcut"', () async {
      final container = await _makeContainer(
        cart: [_p1, _p2],
        prices: {'p1': _p1Prices, 'p2': _p2Prices},
      );
      addTearDown(container.dispose);

      final results = await container.read(cartComparisonProvider.future);

      final migros = results.firstWhere((r) => r.marketId == 'migros');
      final a101 = results.firstWhere((r) => r.marketId == 'a101');
      final bim = results.firstWhere((r) => r.marketId == 'bim');

      expect(migros.matchFraction, equals('2/2 urun mevcut'));
      expect(a101.matchFraction, equals('1/2 urun mevcut'));
      expect(bim.matchFraction, equals('0/2 urun mevcut'));
    });

    test('Cheapest market is marked isCheapest=true', () async {
      final container = await _makeContainer(
        cart: [_p1, _p2],
        prices: {'p1': _p1Prices, 'p2': _p2Prices},
      );
      addTearDown(container.dispose);

      final results = await container.read(cartComparisonProvider.future);

      // a101 has lower total (13.0 vs migros 18.0), so a101 is cheapest
      final cheapestMarkets = results.where((r) => r.isCheapest).toList();
      expect(cheapestMarkets.length, equals(1));
      expect(cheapestMarkets.first.marketId, equals('a101'));
    });

    test('isFullMatch and missingCount helpers work correctly', () async {
      final container = await _makeContainer(
        cart: [_p1, _p2],
        prices: {'p1': _p1Prices, 'p2': _p2Prices},
      );
      addTearDown(container.dispose);

      final results = await container.read(cartComparisonProvider.future);

      final migros = results.firstWhere((r) => r.marketId == 'migros');
      final a101 = results.firstWhere((r) => r.marketId == 'a101');

      // migros has both products — full match
      expect(migros.isFullMatch, isTrue);
      expect(migros.missingCount, equals(0));

      // a101 has 1 of 2 products — partial match
      expect(a101.isFullMatch, isFalse);
      expect(a101.missingCount, equals(1));
    });
  });
}
