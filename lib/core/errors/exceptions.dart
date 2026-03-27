/// Base exception class for the application
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  AppException({required this.message, this.code, this.originalException});

  @override
  String toString() => message;
}

/// Exception for network/API errors
class NetworkException extends AppException {
  NetworkException({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// Exception for server errors (5xx)
class ServerException extends AppException {
  final int? statusCode;

  ServerException({
    required super.message,
    this.statusCode,
    super.code,
    super.originalException,
  });
}

/// Exception for client errors (4xx)
class ClientException extends AppException {
  final int? statusCode;

  ClientException({
    required super.message,
    this.statusCode,
    super.code,
    super.originalException,
  });
}

/// Exception for parsing errors
class ParseException extends AppException {
  ParseException({required super.message, super.code, super.originalException});
}

/// Exception for cache errors
class CacheException extends AppException {
  CacheException({required super.message, super.code, super.originalException});
}
