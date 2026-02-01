import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit({required this.authRepository}) : super(const AuthInitial());

  /// Check if user is already logged in
  Future<void> checkAuthStatus() async {
    final isLoggedIn = await authRepository.isLoggedIn();

    if (isLoggedIn) {
      // Try to get user profile
      final result = await authRepository.getProfile();
      result.fold(
        (failure) {
          // Token might be expired, logout
          emit(const AuthUnauthenticated());
        },
        (user) {
          emit(AuthAuthenticated(user));
        },
      );
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  /// Login with email/phone and password
  Future<void> login({
    required String login,
    required String password,
  }) async {
    emit(const AuthLoading());

    final result = await authRepository.login(
      login: login,
      password: password,
    );

    result.fold(
      (failure) {
        emit(AuthError(failure.message ?? 'Login failed'));
      },
      (user) {
        emit(AuthAuthenticated(user));
      },
    );
  }

  /// Register new user
  /// Normal user: name, phone, password
  /// Institution: name, email, phone, governorate, location, password
  Future<void> register({
    required String name,
    String? email,
    required String phone,
    required String password,
    required String userType,
    String? governorate,
    String? location,
  }) async {
    emit(const AuthLoading());

    final result = await authRepository.register(
      name: name,
      email: email ?? '',
      phone: phone,
      password: password,
      userType: userType,
      governorate: governorate,
      location: location,
    );

    result.fold(
      (failure) {
        emit(AuthError(failure.message ?? 'Registration failed'));
      },
      (user) {
        emit(AuthRegistered(user: user, message: 'Registration successful!'));
      },
    );
  }

  /// Logout current user
  Future<void> logout() async {
    emit(const AuthLoading());

    await authRepository.logout();
    emit(const AuthUnauthenticated());
  }

  /// Verify OTP code
  Future<void> verifyOtp({
    required String login,
    required String otp,
  }) async {
    emit(const AuthLoading());

    final result = await authRepository.verifyOtp(login: login, otp: otp);

    result.fold(
      (failure) =>
          emit(AuthError(failure.message ?? 'OTP verification failed')),
      (user) => emit(AuthOtpVerified(user)),
    );
  }

  /// Send forgot password OTP
  Future<void> forgotPassword({required String login}) async {
    emit(const AuthLoading());

    final result = await authRepository.forgotPassword(login: login);

    result.fold(
      (failure) => emit(AuthError(failure.message ?? 'Failed to send OTP')),
      (_) => emit(const AuthOtpSent(message: 'OTP sent successfully')),
    );
  }

  /// Resend OTP code
  Future<void> resendOtp({
    required String login,
    String? purpose,
  }) async {
    emit(const AuthLoading());

    final result =
        await authRepository.resendOtp(login: login, purpose: purpose);

    result.fold(
      (failure) => emit(AuthError(failure.message ?? 'Failed to resend OTP')),
      (_) => emit(const AuthOtpSent(message: 'OTP resent successfully')),
    );
  }

  /// Reset password with OTP code
  Future<void> resetPassword({
    required String login,
    required String code,
    required String newPassword,
  }) async {
    emit(const AuthLoading());

    final result = await authRepository.resetPassword(
      login: login,
      code: code,
      newPassword: newPassword,
    );

    result.fold(
      (failure) =>
          emit(AuthError(failure.message ?? 'Failed to reset password')),
      (_) => emit(
          const AuthPasswordChanged(message: 'Password reset successfully')),
    );
  }

  /// Change password (authenticated user)
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(const AuthLoading());

    final result = await authRepository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    result.fold(
      (failure) =>
          emit(AuthError(failure.message ?? 'Failed to change password')),
      (_) => emit(
          const AuthPasswordChanged(message: 'Password changed successfully')),
    );
  }

  /// Update user profile
  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? companyName,
  }) async {
    emit(const AuthLoading());

    final result = await authRepository.updateProfile(
      name: name,
      email: email,
      phone: phone,
      companyName: companyName,
    );

    result.fold(
      (failure) =>
          emit(AuthError(failure.message ?? 'Failed to update profile')),
      (user) => emit(AuthProfileUpdated(user)),
    );
  }

  /// Update FCM token (silent — no state change on failure)
  Future<void> updateFcmToken(String fcmToken) async {
    await authRepository.updateFcmToken(fcmToken);
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    emit(const AuthLoading());

    final result = await authRepository.deleteAccount();

    result.fold(
      (failure) =>
          emit(AuthError(failure.message ?? 'Failed to delete account')),
      (_) => emit(const AuthAccountDeleted()),
    );
  }

  /// Reset to unauthenticated (clear error state)
  void resetState() {
    emit(const AuthUnauthenticated());
  }
}
