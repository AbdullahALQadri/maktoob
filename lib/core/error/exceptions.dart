import 'package:equatable/equatable.dart';

/// Base class for all exceptions in the application.
///
/// Exceptions are thrown when unexpected conditions occur during
/// the execution of data layer operations. They should be caught
/// and converted to [Failure] objects in the repository layer.
abstract class AppException extends Equatable implements Exception {
  /// An optional message describing the exception.
  final String? message;

  /// The error code associated with this exception (if any).
  final int? code;

  const AppException({this.message, this.code});

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => message ?? runtimeType.toString();
}

/// Exception thrown when a server-side error occurs.
///
/// This includes HTTP errors returned from API calls.
///
/// Example usage:
/// ```dart
/// if (response.statusCode != 200) {
///   throw ServerException(
///     message: 'Failed to fetch data',
///     code: response.statusCode,
///   );
/// }
/// ```
class ServerException extends AppException {
  const ServerException({super.message, super.code});
}

/// Exception thrown when an error occurs while accessing cached data.
///
/// Example usage:
/// ```dart
/// try {
///   final data = prefs.getString('key');
///   if (data == null) throw CacheException(message: 'No cached data found');
/// } catch (e) {
///   throw CacheException(message: 'Failed to read from cache');
/// }
/// ```
class CacheException extends AppException {
  const CacheException({super.message, super.code});
}

/// Exception thrown when a network error occurs.
///
/// This is thrown when there is no internet connection or
/// the connection times out.
class NetworkException extends AppException {
  const NetworkException({super.message, super.code});
}

/// Exception thrown when there is an error during data communication.
class FetchDataException extends ServerException {
  const FetchDataException({String? message})
      : super(message: message ?? 'Error During Communication');
}

/// Exception thrown when a bad request is made (HTTP 400).
class BadRequestException extends ServerException {
  const BadRequestException({String? message})
      : super(message: message ?? 'Bad Request', code: 400);
}

/// Exception thrown when the request is unauthorized (HTTP 401).
class UnauthorizedException extends ServerException {
  const UnauthorizedException({String? message})
      : super(message: message ?? 'Unauthorized', code: 401);
}

/// Exception thrown when access is forbidden (HTTP 403).
class ForbiddenException extends ServerException {
  const ForbiddenException({String? message})
      : super(message: message ?? 'Forbidden', code: 403);
}

/// Exception thrown when a resource is not found (HTTP 404).
class NotFoundException extends ServerException {
  const NotFoundException({String? message})
      : super(message: message ?? 'Not Found', code: 404);
}

/// Exception thrown when a conflict occurs (HTTP 409).
class ConflictException extends ServerException {
  const ConflictException({String? message})
      : super(message: message ?? 'Conflict Occurred', code: 409);
}

/// Exception thrown when an internal server error occurs (HTTP 500).
class InternalServerErrorException extends ServerException {
  const InternalServerErrorException({String? message})
      : super(message: message ?? 'Internal Server Error', code: 500);
}

/// Exception thrown when there is no internet connection.
class NoInternetConnectionException extends NetworkException {
  const NoInternetConnectionException({String? message})
      : super(message: message ?? 'No Internet Connection');
}

/// Exception thrown when a request is cancelled.
class RequestCancelledException extends ServerException {
  const RequestCancelledException({String? message})
      : super(message: message ?? 'Request Cancelled');
}

/// Exception thrown when a request times out.
class TimeoutException extends NetworkException {
  const TimeoutException({String? message})
      : super(message: message ?? 'Connection Timeout');
}

/// Exception thrown when authentication fails.
class AuthenticationException extends AppException {
  const AuthenticationException({super.message, super.code});
}

/// Exception thrown when validation fails.
class ValidationException extends AppException {
  const ValidationException({super.message, super.code});
}
