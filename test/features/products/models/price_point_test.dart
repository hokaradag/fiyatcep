import 'package:flutter_test/flutter_test.dart';
import 'package:fiyatcep/features/products/models/price_point.dart';

void main() {
  group('PricePoint', () {
    test('fromJson parses price and ISO 8601 date correctly', () {
      final json = {
        'price': 10.5,
        'date': '2026-03-28T14:00:00.000Z',
      };

      final point = PricePoint.fromJson(json);

      expect(point.price, equals(10.5));
      expect(point.date.year, equals(2026));
      expect(point.date.month, equals(3));
      expect(point.date.day, equals(28));
    });

    test('toJson produces map with price and date keys', () {
      final point = PricePoint(price: 25.0, date: DateTime(2026, 1, 15));

      final json = point.toJson();

      expect(json, containsPair('price', 25.0));
      expect(json.containsKey('date'), isTrue);
    });

    test('constructor sets price and date fields correctly', () {
      final date = DateTime(2026, 6, 15);
      final point = PricePoint(price: 99.99, date: date);

      expect(point.price, equals(99.99));
      expect(point.date, equals(date));
    });
  });
}
