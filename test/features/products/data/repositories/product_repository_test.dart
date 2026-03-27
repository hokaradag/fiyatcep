import 'package:flutter_test/flutter_test.dart';
import 'package:fiyatcep/features/products/data/repositories/product_repository_impl.dart';
import 'package:fiyatcep/features/products/data/datasources/product_mock_datasource.dart';
import 'package:fiyatcep/features/products/models/product_item.dart';
import 'package:fiyatcep/core/errors/result.dart';

void main() {
  group('ProductRepositoryImpl', () {
    late ProductRepositoryImpl repo;

    setUp(() {
      repo = ProductRepositoryImpl(
        remoteDataSource: ProductMockDataSourceImpl(),
      );
    });

    test('getAllProducts returns SuccessResult with non-empty list', () async {
      final result = await repo.getAllProducts();
      expect(result, isA<SuccessResult<List<ProductItem>>>());
      result.when(
        success: (data) => expect(data, isNotEmpty),
        failure: (message, code) => fail('Expected success but got failure: $message'),
        loading: () => fail('Unexpected loading state'),
      );
    });

    test('getAllProducts returns 6 products from mock data', () async {
      final result = await repo.getAllProducts();
      result.when(
        success: (data) => expect(data.length, equals(6)),
        failure: (message, code) => fail('Expected success but got failure: $message'),
        loading: () => fail('Unexpected loading state'),
      );
    });

    test('searchProducts with empty query returns empty SuccessResult', () async {
      final result = await repo.searchProducts('');
      expect(result, isA<SuccessResult<List<ProductItem>>>());
      result.when(
        success: (data) => expect(data, isEmpty),
        failure: (message, code) => fail('Expected success but got failure: $message'),
        loading: () => fail('Unexpected loading state'),
      );
    });

    test('searchProducts with Turkish query "makarna" finds results', () async {
      final result = await repo.searchProducts('makarna');
      expect(result, isA<SuccessResult<List<ProductItem>>>());
      result.when(
        success: (data) {
          expect(data, isNotEmpty);
          expect(data.first.name, contains('Makarna'));
        },
        failure: (message, code) => fail('Expected success but got failure: $message'),
        loading: () => fail('Unexpected loading state'),
      );
    });

    test('searchProducts with Turkish character "süt" finds milk product', () async {
      final result = await repo.searchProducts('süt');
      expect(result, isA<SuccessResult<List<ProductItem>>>());
      result.when(
        success: (data) => expect(data, isNotEmpty),
        failure: (message, code) => fail('Expected success but got failure: $message'),
        loading: () => fail('Unexpected loading state'),
      );
    });

    test('getProductById with valid ID returns SuccessResult', () async {
      final result = await repo.getProductById('p1');
      expect(result, isA<SuccessResult<ProductItem>>());
      result.when(
        success: (data) {
          expect(data.id, equals('p1'));
          expect(data.name, equals('Ayçiçek Yağı 1L'));
        },
        failure: (message, code) => fail('Expected success but got failure: $message'),
        loading: () => fail('Unexpected loading state'),
      );
    });

    test('getProductById with invalid ID returns FailureResult', () async {
      final result = await repo.getProductById('nonexistent');
      expect(result, isA<FailureResult>());
    });

    test('searchProducts with brand name "filiz" returns matching products', () async {
      final result = await repo.searchProducts('filiz');
      result.when(
        success: (data) => expect(data, isNotEmpty),
        failure: (message, code) => fail('Expected success but got failure: $message'),
        loading: () => fail('Unexpected loading state'),
      );
    });
  });
}
