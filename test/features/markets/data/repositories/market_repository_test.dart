import 'package:flutter_test/flutter_test.dart';
import 'package:fiyatcep/features/markets/data/repositories/market_repository_impl.dart';
import 'package:fiyatcep/features/markets/data/datasources/market_mock_datasource.dart';
import 'package:fiyatcep/features/markets/models/market_item.dart';
import 'package:fiyatcep/core/errors/result.dart';

void main() {
  group('MarketRepositoryImpl', () {
    late MarketRepositoryImpl repo;

    setUp(() {
      repo = MarketRepositoryImpl(
        remoteDataSource: MarketMockDataSourceImpl(),
      );
    });

    test('getAllMarkets returns SuccessResult with non-empty list', () async {
      final result = await repo.getAllMarkets();
      expect(result, isA<SuccessResult<List<MarketItem>>>());
      result.when(
        success: (data) => expect(data, isNotEmpty),
        failure: (message, code) => fail('Expected success but got failure: $message'),
        loading: () => fail('Unexpected loading state'),
      );
    });

    test('getAllMarkets returns 5 markets from mock data', () async {
      final result = await repo.getAllMarkets();
      result.when(
        success: (data) => expect(data.length, equals(5)),
        failure: (message, code) => fail('Expected success but got failure: $message'),
        loading: () => fail('Unexpected loading state'),
      );
    });

    test('searchMarkets with empty query returns empty SuccessResult', () async {
      final result = await repo.searchMarkets('');
      expect(result, isA<SuccessResult<List<MarketItem>>>());
      result.when(
        success: (data) => expect(data, isEmpty),
        failure: (message, code) => fail('Expected success but got failure: $message'),
        loading: () => fail('Unexpected loading state'),
      );
    });

    test('searchMarkets with "migros" query finds Migros market', () async {
      final result = await repo.searchMarkets('migros');
      expect(result, isA<SuccessResult<List<MarketItem>>>());
      result.when(
        success: (data) {
          expect(data, isNotEmpty);
          expect(data.first.name, equals('Migros'));
        },
        failure: (message, code) => fail('Expected success but got failure: $message'),
        loading: () => fail('Unexpected loading state'),
      );
    });

    test('searchMarkets with Turkish character "şok" finds ŞOK market', () async {
      final result = await repo.searchMarkets('şok');
      expect(result, isA<SuccessResult<List<MarketItem>>>());
      result.when(
        success: (data) => expect(data, isNotEmpty),
        failure: (message, code) => fail('Expected success but got failure: $message'),
        loading: () => fail('Unexpected loading state'),
      );
    });

    test('getMarketById with valid ID returns SuccessResult', () async {
      final result = await repo.getMarketById('m1');
      expect(result, isA<SuccessResult<MarketItem>>());
      result.when(
        success: (data) {
          expect(data.id, equals('m1'));
          expect(data.name, equals('Migros'));
        },
        failure: (message, code) => fail('Expected success but got failure: $message'),
        loading: () => fail('Unexpected loading state'),
      );
    });

    test('getMarketById with invalid ID returns FailureResult', () async {
      final result = await repo.getMarketById('nonexistent');
      expect(result, isA<FailureResult>());
    });
  });
}
