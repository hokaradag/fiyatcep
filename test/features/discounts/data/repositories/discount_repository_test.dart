import 'package:flutter_test/flutter_test.dart';
import 'package:fiyatcep/features/discounts/data/repositories/discount_repository_impl.dart';
import 'package:fiyatcep/features/discounts/data/datasources/discount_mock_datasource.dart';
import 'package:fiyatcep/features/discounts/models/discount_item.dart';
import 'package:fiyatcep/core/errors/result.dart';

void main() {
  group('DiscountRepositoryImpl', () {
    late DiscountRepositoryImpl repo;

    setUp(() {
      repo = DiscountRepositoryImpl(
        remoteDataSource: DiscountMockDataSourceImpl(),
      );
    });

    test('getAllDiscounts returns SuccessResult with non-empty list', () async {
      final result = await repo.getAllDiscounts();
      expect(result, isA<SuccessResult<List<DiscountItem>>>());
      result.when(
        success: (data) => expect(data, isNotEmpty),
        failure: (message, code) => fail('Expected success but got failure: $message'),
        loading: () => fail('Unexpected loading state'),
      );
    });

    test('getAllDiscounts returns 5 discounts from mock data', () async {
      final result = await repo.getAllDiscounts();
      result.when(
        success: (data) => expect(data.length, equals(5)),
        failure: (message, code) => fail('Expected success but got failure: $message'),
        loading: () => fail('Unexpected loading state'),
      );
    });

    test('searchDiscounts with empty query returns empty SuccessResult', () async {
      final result = await repo.searchDiscounts('');
      expect(result, isA<SuccessResult<List<DiscountItem>>>());
      result.when(
        success: (data) => expect(data, isEmpty),
        failure: (message, code) => fail('Expected success but got failure: $message'),
        loading: () => fail('Unexpected loading state'),
      );
    });

    test('searchDiscounts with "makarna" finds matching discount', () async {
      final result = await repo.searchDiscounts('makarna');
      expect(result, isA<SuccessResult<List<DiscountItem>>>());
      result.when(
        success: (data) {
          expect(data, isNotEmpty);
          expect(data.first.productName, contains('Makarna'));
        },
        failure: (message, code) => fail('Expected success but got failure: $message'),
        loading: () => fail('Unexpected loading state'),
      );
    });

    test('searchDiscounts with Turkish "süt" finds milk discount', () async {
      final result = await repo.searchDiscounts('süt');
      expect(result, isA<SuccessResult<List<DiscountItem>>>());
      result.when(
        success: (data) => expect(data, isNotEmpty),
        failure: (message, code) => fail('Expected success but got failure: $message'),
        loading: () => fail('Unexpected loading state'),
      );
    });

    test('getDiscountsByMarket with valid marketId returns SuccessResult', () async {
      final result = await repo.getDiscountsByMarket('migros');
      expect(result, isA<SuccessResult<List<DiscountItem>>>());
      result.when(
        success: (data) {
          expect(data, isNotEmpty);
          expect(data.every((d) => d.marketId == 'migros'), isTrue);
        },
        failure: (message, code) => fail('Expected success but got failure: $message'),
        loading: () => fail('Unexpected loading state'),
      );
    });

    test('getDiscountsByMarket with unknown marketId returns empty list', () async {
      final result = await repo.getDiscountsByMarket('nonexistent');
      expect(result, isA<SuccessResult<List<DiscountItem>>>());
      result.when(
        success: (data) => expect(data, isEmpty),
        failure: (message, code) => fail('Expected success but got failure: $message'),
        loading: () => fail('Unexpected loading state'),
      );
    });

    test('discountPercent computed getter returns correct value', () async {
      final result = await repo.getAllDiscounts();
      result.when(
        success: (data) {
          // d1: oldPrice=42.95, newPrice=36.50 => ~15%
          final d1 = data.firstWhere((d) => d.id == 'd1');
          expect(d1.discountPercent, greaterThan(0));
          expect(d1.discountAmount, closeTo(6.45, 0.01));
        },
        failure: (message, code) => fail('Expected success but got failure: $message'),
        loading: () => fail('Unexpected loading state'),
      );
    });
  });
}
