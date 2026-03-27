import 'package:dio/dio.dart';
import '../../models/discount_item.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/exceptions.dart';
import 'discount_datasource.dart';

class DiscountRemoteDataSourceImpl implements DiscountRemoteDataSource {
  final ApiClient apiClient;

  DiscountRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<DiscountItem>> getAllDiscounts() async {
    try {
      return await apiClient
          .get(
            endpoint: '/discounts',
            fromJson: (json) {
              final list = json['data'] as List? ?? [];
              return list.cast<Map<String, dynamic>>();
            },
          )
          .then(
            (list) => list.map((item) => DiscountItem.fromJson(item)).toList(),
          );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<List<DiscountItem>> getDiscountsByMarket(String marketId) async {
    try {
      return await apiClient
          .get(
            endpoint: '/discounts',
            queryParameters: {'marketId': marketId},
            fromJson: (json) {
              final list = json['data'] as List? ?? [];
              return list.cast<Map<String, dynamic>>();
            },
          )
          .then(
            (list) => list.map((item) => DiscountItem.fromJson(item)).toList(),
          );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<List<DiscountItem>> searchDiscounts(String query) async {
    try {
      return await apiClient
          .get(
            endpoint: '/discounts/search',
            queryParameters: {'q': query},
            fromJson: (json) {
              final list = json['data'] as List? ?? [];
              return list.cast<Map<String, dynamic>>();
            },
          )
          .then(
            (list) => list.map((item) => DiscountItem.fromJson(item)).toList(),
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
    return NetworkException(message: 'Failed to fetch discounts');
  }
}
