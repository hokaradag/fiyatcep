import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fiyatcep/features/products/product_detail_page.dart';
import 'package:fiyatcep/features/products/models/product_item.dart';

// Product with ID 'p1' which has entries in mockMarketPrices
const _testProduct = ProductItem(
  id: 'p1',
  marketId: 'a101',
  name: 'Ayçiçek Yağı 1L',
  brand: 'Yudum',
  market: 'A101',
  price: 74.95,
  isDiscounted: true,
);

void main() {
  group('ProductDetailPage', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('shows product name after loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ProductDetailPage(product: _testProduct),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ayçiçek Yağı 1L'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows product brand after loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ProductDetailPage(product: _testProduct),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Yudum'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows app bar with correct title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ProductDetailPage(product: _testProduct),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ürün Detayı'), findsOneWidget);
    });

    testWidgets('shows favorites button after loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ProductDetailPage(product: _testProduct),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The favorites toggle button should be present
      expect(find.text('Favorilere Ekle'), findsOneWidget);
    });
  });
}
