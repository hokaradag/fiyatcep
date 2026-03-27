import 'package:dio/dio.dart';
import '../../models/market_item.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/exceptions.dart';
import 'market_datasource.dart';

class MarketRemoteDataSourceImpl implements MarketRemoteDataSource {
  final ApiClient apiClient;

  MarketRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<MarketItem>> getAllMarkets() async {
    try {
      return await apiClient
          .get(
            endpoint: '/markets',
            fromJson: (json) {
              final list = json['data'] as List? ?? [];
              return list.cast<Map<String, dynamic>>();
            },
          )
          .then(
            (list) => list.map((item) => MarketItem.fromJson(item)).toList(),
          );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<MarketItem> getMarketById(String id) async {
    try {
      return await apiClient.get(
        endpoint: '/markets/$id',
        fromJson: (json) => MarketItem.fromJson(json['data']),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<List<MarketItem>> searchMarkets(String query) async {
    try {
      return await apiClient
          .get(
            endpoint: '/markets/search',
            queryParameters: {'q': query},
            fromJson: (json) {
              final list = json['data'] as List? ?? [];
              return list.cast<Map<String, dynamic>>();
            },
          )
          .then(
            (list) => list.map((item) => MarketItem.fromJson(item)).toList(),
          );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  AppException _handleDioException(DioException e) {
    if (e.type == DioExceptionType.badResponse) {
      if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
        return ServerException(
          message: e.response?.data['message'] ?? 'Server error',
          statusCode: e.response?.statusCode,
        );
      }
    }
    return NetworkException(message: 'Failed to fetch markets');
  }
}
