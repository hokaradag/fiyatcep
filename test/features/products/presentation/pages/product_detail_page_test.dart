import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fiyatcep/features/products/product_detail_page.dart';
import 'package:fiyatcep/features/products/models/product_item.dart';
import 'package:fiyatcep/features/products/models/market_price_item.dart';
import 'package:fiyatcep/features/products/presentation/providers/products_provider.dart';

const _testProduct = ProductItem(
  id: 'p1',
  marketId: 'a101',
  name: 'Ayçiçek Yağı 1L',
  brand: 'Yudum',
  market: 'A101',
  price: 74.95,
  isDiscounted: true,
);

const _stubPrices = [
  MarketPriceItem(marketId: 'a101', market: 'A101', price: 74.95, isDiscounted: true),
];

// Override productMarketPricesProvider so widget tests never hit the network.
final _pricesOverride = productMarketPricesProvider.overrideWith(
  (ref, productId) async => _stubPrices,
);

Widget _buildTestWidget() => ProviderScope(
      overrides: [_pricesOverride],
      child: const MaterialApp(
        home: ProductDetailPage(product: _testProduct),
      ),
    );

void main() {
  group('ProductDetailPage', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('shows product name after loading', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Ayçiçek Yağı 1L'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows product brand after loading', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('Yudum'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows app bar with correct title', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Ürün Detayı'), findsOneWidget);
    });

    testWidgets('shows favorites button after loading', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Favorilere Ekle'), findsOneWidget);
    });
  });
}
