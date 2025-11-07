/// Base class for all custom exceptions
class AppException implements Exception {
  final String message;
  final String? code;

  AppException({required this.message, this.code});

  @override
  String toString() => message;
}

/// Exception thrown when database operation fails
class DatabaseException extends AppException {
  DatabaseException({required super.message, super.code});
}

/// Exception thrown when network request fails
class NetworkException extends AppException {
  NetworkException({required super.message, super.code});
}

/// Exception thrown when server returns an error
class ServerException extends AppException {
  final int? statusCode;
  
  ServerException({
    required super.message,
    super.code,
    this.statusCode,
  });
}

/// Exception thrown when authentication fails
class AuthenticationException extends AppException {
  AuthenticationException({required super.message, super.code});
}

/// Exception thrown when validation fails
class ValidationException extends AppException {
  final Map<String, String>? errors;
  
  ValidationException({
    required super.message,
    super.code,
    this.errors,
  });
}

/// Exception thrown when cache operation fails
class CacheException extends AppException {
  CacheException({required super.message, super.code});
}
