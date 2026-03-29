import 'package:flutter_test/flutter_test.dart';
import 'package:fiyatcep/features/discounts/models/discount_item.dart';

void main() {
  group('DiscountItem', () {
    DiscountItem makeItem({
      DateTime? validUntil,
      double oldPrice = 100.0,
      double newPrice = 75.0,
    }) {
      return DiscountItem(
        id: 'd1',
        productId: 'p1',
        marketId: 'migros',
        productName: 'Test Ürün',
        marketName: 'Test Market',
        oldPrice: oldPrice,
        newPrice: newPrice,
        validUntil: validUntil ?? DateTime(2026, 3, 30),
      );
    }

    group('validUntil is DateTime', () {
      test('validUntil.day returns correct day', () {
        final item = makeItem(validUntil: DateTime(2026, 3, 30));
        expect(item.validUntil.day, equals(30));
      });

      test('validUntil.month and year accessible', () {
        final item = makeItem(validUntil: DateTime(2026, 3, 30));
        expect(item.validUntil.month, equals(3));
        expect(item.validUntil.year, equals(2026));
      });
    });

    group('displayDate', () {
      test('returns Turkish formatted date for 30 Mart 2026', () {
        final item = makeItem(validUntil: DateTime(2026, 3, 30));
        expect(item.displayDate, equals('30 Mart 2026'));
      });

      test('returns Ocak for January', () {
        final item = makeItem(validUntil: DateTime(2026, 1, 5));
        expect(item.displayDate, equals('5 Ocak 2026'));
      });

      test('returns Aralık for December', () {
        final item = makeItem(validUntil: DateTime(2026, 12, 31));
        expect(item.displayDate, equals('31 Aralık 2026'));
      });

      test('returns Şubat for February', () {
        final item = makeItem(validUntil: DateTime(2026, 2, 14));
        expect(item.displayDate, equals('14 Şubat 2026'));
      });

      test('returns Nisan for April', () {
        final item = makeItem(validUntil: DateTime(2026, 4, 1));
        expect(item.displayDate, equals('1 Nisan 2026'));
      });
    });

    group('computed getters (regression)', () {
      test('discountAmount is correct', () {
        final item = makeItem(oldPrice: 42.95, newPrice: 36.50);
        expect(item.discountAmount, closeTo(6.45, 0.01));
      });

      test('discountPercent is correct', () {
        final item = makeItem(oldPrice: 100.0, newPrice: 75.0);
        expect(item.discountPercent, equals(25));
      });

      test('discountPercent with zero oldPrice returns 0', () {
        final item = makeItem(oldPrice: 0.0, newPrice: 0.0);
        expect(item.discountPercent, equals(0));
      });
    });
  });
}
