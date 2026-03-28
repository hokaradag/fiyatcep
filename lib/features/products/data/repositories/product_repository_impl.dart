import '../../models/product_item.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource? localDataSource;

  ProductRepositoryImpl({required this.remoteDataSource, this.localDataSource});

  @override
  Future<Result<List<ProductItem>>> getAllProducts() async {
    try {
      final products = await remoteDataSource.getAllProducts();

      // Cache locally if available
      await localDataSource?.cacheProducts(products);

      return SuccessResult(products);
    } on AppException catch (e) {
      return FailureResult(message: e.message, code: e.code);
    } catch (e) {
      return FailureResult(message: 'Unknown error occurred');
    }
  }

  @override
  Future<Result<ProductItem>> getProductById(String id) async {
    try {
      final product = await remoteDataSource.getProductById(id);
      return SuccessResult(product);
    } on AppException catch (e) {
      return FailureResult(message: e.message, code: e.code);
    } catch (e) {
      return FailureResult(message: 'Unknown error occurred');
    }
  }

  @override
  Future<Result<List<ProductItem>>> searchProducts(String query) async {
    try {
      if (query.isEmpty) {
        return const SuccessResult([]);
      }

      final results = await remoteDataSource.searchProducts(query);
      return SuccessResult(results);
    } on AppException catch (e) {
      return FailureResult(message: e.message, code: e.code);
    } catch (e) {
      return FailureResult(message: 'Unknown error occurred');
    }
  }

  @override
  Future<Result<List<ProductItem>>> getProductsByMarket(String marketId) async {
    try {
      final products = await remoteDataSource.getProductsByMarket(marketId);
      return SuccessResult(products);
    } on AppException catch (e) {
      return FailureResult(message: e.message, code: e.code);
    } catch (e) {
      return FailureResult(message: 'Unknown error occurred');
    }
  }
}
