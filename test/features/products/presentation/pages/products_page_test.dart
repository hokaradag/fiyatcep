import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fiyatcep/features/products/products_page.dart';

void main() {
  group('ProductsPage', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('shows product list after data finishes loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ProductsPage()),
        ),
      );
      // Wait for mock datasource delay to complete
      await tester.pumpAndSettle();

      // Products are rendered in a ListView
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('shows product names from mock data after loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ProductsPage()),
        ),
      );
      await tester.pumpAndSettle();

      // Verify known mock product names are displayed
      expect(find.text('Makarna 500g'), findsOneWidget);
      expect(find.text('Un 1kg'), findsOneWidget);
    });

    testWidgets('has search TextField visible', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ProductsPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows app bar with correct title', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ProductsPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ürünler'), findsOneWidget);
    });
  });
}
