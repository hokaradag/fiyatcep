import '../../models/market_item.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/repositories/market_repository.dart';
import '../datasources/market_datasource.dart';

class MarketRepositoryImpl implements MarketRepository {
  final MarketRemoteDataSource remoteDataSource;

  MarketRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<List<MarketItem>>> getAllMarkets() async {
    try {
      final markets = await remoteDataSource.getAllMarkets();
      return SuccessResult(markets);
    } on AppException catch (e) {
      return FailureResult(message: e.message, code: e.code);
    } catch (e) {
      return FailureResult(message: 'Unknown error occurred');
    }
  }

  @override
  Future<Result<MarketItem>> getMarketById(String id) async {
    try {
      final market = await remoteDataSource.getMarketById(id);
      return SuccessResult(market);
    } on AppException catch (e) {
      return FailureResult(message: e.message, code: e.code);
    } catch (e) {
      return FailureResult(message: 'Unknown error occurred');
    }
  }

  @override
  Future<Result<List<MarketItem>>> searchMarkets(String query) async {
    try {
      if (query.isEmpty) {
        return const SuccessResult([]);
      }

      final results = await remoteDataSource.searchMarkets(query);
      return SuccessResult(results);
    } on AppException catch (e) {
      return FailureResult(message: e.message, code: e.code);
    } catch (e) {
      return FailureResult(message: 'Unknown error occurred');
    }
  }
}
