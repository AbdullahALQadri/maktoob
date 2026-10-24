import 'package:equatable/equatable.dart';

/// Abstract base class for all failures in the application.
///
/// Failures represent expected error conditions that can occur during
/// the execution of use cases. They are used on the left side of [Either]
/// to indicate that an operation did not succeed.
///
/// Each failure contains an optional [message] that describes what went wrong.
abstract class Failure extends Equatable {
  /// An optional message describing the failure.
  final String? message;

  /// The error code associated with this failure (if any).
  final int? code;

  const Failure({this.message, this.code});

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => message ?? runtimeType.toString();
}

/// Represents a failure that occurred due to a server-side error.
///
/// This includes HTTP errors like 500 Internal Server Error,
/// 502 Bad Gateway, 503 Service Unavailable, etc.
///
/// Example usage:
/// ```dart
/// return Left(ServerFailure(message: 'Server is currently unavailable'));
/// ```
class ServerFailure extends Failure {
  const ServerFailure({super.message, super.code});
}

/// Represents a failure that occurred while accessing cached data.
///
/// This typically happens when:
/// - The cached data is not found
/// - The cached data is corrupted
/// - The cache storage is not accessible
///
/// Example usage:
/// ```dart
/// return Left(CacheFailure(message: 'Failed to retrieve cached user data'));
/// ```
class CacheFailure extends Failure {
  const CacheFailure({super.message, super.code});
}

/// Represents a failure due to network connectivity issues.
///
/// This occurs when:
/// - The device has no internet connection
/// - The connection timed out
/// - DNS resolution failed
///
/// Example usage:
/// ```dart
/// if (!await networkInfo.isConnected) {
///   return Left(NetworkFailure(message: 'No internet connection'));
/// }
/// ```
class NetworkFailure extends Failure {
  const NetworkFailure({super.message, super.code});
}

/// Represents a failure during authentication.
///
/// This occurs when:
/// - User credentials are invalid
/// - Token has expired
/// - User session is invalid
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({super.message, super.code});
}

/// Represents a failure when input validation fails.
///
/// This occurs when:
/// - Required fields are missing
/// - Input format is invalid
/// - Business rules are violated
class ValidationFailure extends Failure {
  const ValidationFailure({super.message, super.code});
}

/// Represents an unexpected or unknown failure.
///
/// Use this when the error type cannot be determined or
/// when an unexpected exception occurs.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({super.message, super.code});
}

/// Represents a failure when a requested resource is not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message, super.code});
}

/// Represents a failure when the user doesn't have permission.
class PermissionFailure extends Failure {
  const PermissionFailure({super.message, super.code});
}

/// Represents a failure when an operation times out.
class TimeoutFailure extends Failure {
  const TimeoutFailure({super.message, super.code});
}

/// Represents a failure during QR code scanning operations.
class ScannerFailure extends Failure {
  const ScannerFailure({super.message, super.code});
}

/// No connection: the write was queued and will be sent when it returns
/// (PendingActionsQueue). [message] is the translation key to show.
class QueuedOfflineFailure extends NetworkFailure {
  const QueuedOfflineFailure() : super(message: 'event_queued_offline');
}

/// The door refused the guest. [reason] is a door rule code the UI
/// translates (`door_reason_<code>`), because an offline door has no server
/// message to show: event_not_active, qr_not_yet_valid, qr_expired,
/// too_many_companions, not_found, other_event, no_pack, ...
class DoorRefusedFailure extends ScannerFailure {
  final String reason;
  final int? maxCompanions;

  const DoorRefusedFailure({required this.reason, this.maxCompanions, super.message});

  @override
  List<Object?> get props => [reason, maxCompanions, message];
}

/// Represents a failure during file picking operations.
class FilePickerFailure extends Failure {
  const FilePickerFailure({super.message, super.code});
}

/// Represents a failure during file upload operations.
class UploadFailure extends Failure {
  const UploadFailure({super.message, super.code});
}
