import 'package:equatable/equatable.dart';

/// Base class for all failures
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Failure for database operations
class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message, super.code});
}

/// Failure for network operations
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});
}

/// Failure for server errors
class ServerFailure extends Failure {
  final int? statusCode;
  
  const ServerFailure({
    required super.message,
    super.code,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, code, statusCode];
}

/// Failure for authentication errors
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({required super.message, super.code});
}

/// Failure for validation errors
class ValidationFailure extends Failure {
  final Map<String, String>? errors;
  
  const ValidationFailure({
    required super.message,
    super.code,
    this.errors,
  });

  @override
  List<Object?> get props => [message, code, errors];
}

/// Failure when resource is not found
class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message, super.code});
}

/// Failure for cache operations
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});
}

/// Failure for synchronization operations
class SyncFailure extends Failure {
  const SyncFailure({required super.message, super.code});
}

/// Failure for permission issues
class PermissionFailure extends Failure {
  const PermissionFailure({required super.message, super.code});
}
