import 'package:dio/dio.dart';
import '../errors/exceptions.dart';

class ApiClient {
  late final Dio _dio;
  final String baseUrl;

  ApiClient({this.baseUrl = 'https://api.example.com/api/v1'}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  /// GET request
  Future<T> get<T>({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );

      return fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _handleException(e);
      rethrow;
    }
  }

  /// POST request
  Future<T> post<T>({
    required String endpoint,
    required Map<String, dynamic> data,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.post(endpoint, data: data);

      return fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _handleException(e);
      rethrow;
    }
  }

  /// PUT request
  Future<T> put<T>({
    required String endpoint,
    required Map<String, dynamic> data,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.put(endpoint, data: data);

      return fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _handleException(e);
      rethrow;
    }
  }

  /// DELETE request
  Future<void> delete({required String endpoint}) async {
    try {
      await _dio.delete(endpoint);
    } catch (e) {
      _handleException(e);
      rethrow;
    }
  }

  /// Interceptor callbacks
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add auth token if available
    // final token = await _getAuthToken();
    // if (token != null) {
    //   options.headers['Authorization'] = 'Bearer $token';
    // }
    return handler.next(options);
  }

  Future<void> _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    return handler.next(response);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    return handler.next(error);
  }

  /// Handle exceptions and convert to AppException
  void _handleException(dynamic exception) {
    if (exception is DioException) {
      switch (exception.type) {
        case DioExceptionType.badResponse:
          if (exception.response?.statusCode != null) {
            final body = exception.response?.data;
            final errorObj = body is Map ? body['error'] : null;
            final message = (errorObj is Map ? errorObj['message'] : null)
                ?? (body is Map ? body['message'] : null)
                ?? 'Unknown error';
            final errorCode = (errorObj is Map ? errorObj['code'] : null) as String?;
            if (exception.response!.statusCode! >= 500) {
              throw ServerException(
                message: message,
                statusCode: exception.response?.statusCode,
                code: errorCode,
                originalException: exception,
              );
            } else if (exception.response!.statusCode! >= 400) {
              throw ClientException(
                message: message,
                statusCode: exception.response?.statusCode,
                code: errorCode,
                originalException: exception,
              );
            }
          }
          break;
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          throw NetworkException(
            message: 'Network timeout',
            originalException: exception,
          );
        case DioExceptionType.unknown:
          throw NetworkException(
            message: 'Network error',
            originalException: exception,
          );
        default:
          throw AppException(
            message: 'Unknown error',
            originalException: exception,
          );
      }
    }
  }
}
