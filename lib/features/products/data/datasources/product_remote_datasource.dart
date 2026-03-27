import 'package:dio/dio.dart';
import '../../models/product_item.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/exceptions.dart';
import 'product_datasource.dart';

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient apiClient;

  ProductRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ProductItem>> getAllProducts() async {
    try {
      return await apiClient
          .get(
            endpoint: '/products',
            fromJson: (json) {
              final list = json['data'] as List? ?? [];
              return list.cast<Map<String, dynamic>>();
            },
          )
          .then(
            (list) => list.map((item) => ProductItem.fromJson(item)).toList(),
          );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<ProductItem> getProductById(String id) async {
    try {
      return await apiClient.get(
        endpoint: '/products/$id',
        fromJson: (json) => ProductItem.fromJson(json['data']),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<List<ProductItem>> searchProducts(String query) async {
    try {
      return await apiClient
          .get(
            endpoint: '/products/search',
            queryParameters: {'q': query},
            fromJson: (json) {
              final list = json['data'] as List? ?? [];
              return list.cast<Map<String, dynamic>>();
            },
          )
          .then(
            (list) => list.map((item) => ProductItem.fromJson(item)).toList(),
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
    return NetworkException(message: 'Failed to fetch products');
  }
}
