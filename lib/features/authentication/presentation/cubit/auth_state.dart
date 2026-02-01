import 'package:equatable/equatable.dart';

import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state - checking auth status
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state - during login/register/logout
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated state - user is logged in
class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Registration successful
class AuthRegistered extends AuthState {
  final UserEntity user;
  final String message;

  const AuthRegistered({required this.user, required this.message});

  @override
  List<Object?> get props => [user, message];
}

/// Unauthenticated state - user is not logged in
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// OTP sent successfully (forgot password / resend)
class AuthOtpSent extends AuthState {
  final String message;

  const AuthOtpSent({required this.message});

  @override
  List<Object?> get props => [message];
}

/// OTP verified successfully
class AuthOtpVerified extends AuthState {
  final UserEntity user;

  const AuthOtpVerified(this.user);

  @override
  List<Object?> get props => [user];
}

/// Password reset / changed successfully
class AuthPasswordChanged extends AuthState {
  final String message;

  const AuthPasswordChanged({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Profile updated successfully
class AuthProfileUpdated extends AuthState {
  final UserEntity user;

  const AuthProfileUpdated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Account deleted
class AuthAccountDeleted extends AuthState {
  const AuthAccountDeleted();
}

/// Error state
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
