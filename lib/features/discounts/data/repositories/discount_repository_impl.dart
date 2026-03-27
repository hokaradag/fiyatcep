import '../../models/discount_item.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/repositories/discount_repository.dart';
import '../datasources/discount_datasource.dart';

class DiscountRepositoryImpl implements DiscountRepository {
  final DiscountRemoteDataSource remoteDataSource;

  DiscountRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<List<DiscountItem>>> getAllDiscounts() async {
    try {
      final discounts = await remoteDataSource.getAllDiscounts();
      return SuccessResult(discounts);
    } on AppException catch (e) {
      return FailureResult(message: e.message, code: e.code);
    } catch (e) {
      return FailureResult(message: 'Unknown error occurred');
    }
  }

  @override
  Future<Result<List<DiscountItem>>> getDiscountsByMarket(
    String marketId,
  ) async {
    try {
      final discounts = await remoteDataSource.getDiscountsByMarket(marketId);
      return SuccessResult(discounts);
    } on AppException catch (e) {
      return FailureResult(message: e.message, code: e.code);
    } catch (e) {
      return FailureResult(message: 'Unknown error occurred');
    }
  }

  @override
  Future<Result<List<DiscountItem>>> searchDiscounts(String query) async {
    try {
      if (query.isEmpty) {
        return const SuccessResult([]);
      }

      final results = await remoteDataSource.searchDiscounts(query);
      return SuccessResult(results);
    } on AppException catch (e) {
      return FailureResult(message: e.message, code: e.code);
    } catch (e) {
      return FailureResult(message: 'Unknown error occurred');
    }
  }
}
