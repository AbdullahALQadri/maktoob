import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/fcm_service.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  final FcmService? fcmService;
  StreamSubscription<String>? _tokenSub;
  String? _pendingFcmToken; // most recent token captured before user was authenticated

  AuthCubit({required this.authRepository, this.fcmService})
      : super(const AuthInitial()) {
    _tokenSub = fcmService?.tokenStream.listen((t) {
      _pendingFcmToken = t;
      _registerFcmToken(t);
    });
  }

  Future<void> _registerFcmToken(String token) async {
    // Only register if the user is authenticated — calling /auth/fcm-token
    // unauthenticated would 401. Keep the token in [_pendingFcmToken] so we
    // can register it as soon as login completes.
    if (state is! AuthAuthenticated) return;
    final result = await authRepository.updateFcmToken(token);
    result.fold(
      (f) => dev.log('FCM token register failed: ${f.message}', name: 'AuthCubit'),
      (_) => dev.log('FCM token registered', name: 'AuthCubit'),
    );
  }

  @override
  Future<void> close() {
    _tokenSub?.cancel();
    return super.close();
  }

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
          _pushCurrentFcmToken();
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
        // Check if account is verified
        if (!user.isVerified) {
          emit(AuthUnverified(user: user, phone: login));
        } else {
          emit(AuthAuthenticated(user));
          _pushCurrentFcmToken();
        }
      },
    );
  }

  Future<void> _pushCurrentFcmToken() async {
    if (fcmService == null) return;
    // Prefer the cached token captured before login (handles token-rotation-before-auth case).
    final token = _pendingFcmToken ?? await fcmService!.getToken();
    if (token != null) await _registerFcmToken(token);
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

    // Best-effort: unregister this device's FCM token before logging out
    // so the user stops receiving push notifications meant for this account.
    try {
      await authRepository.updateFcmToken('');
    } catch (_) {
      // Non-fatal — proceed with logout
    }

    await authRepository.logout();
    _pendingFcmToken = null;
    emit(const AuthUnauthenticated());
  }

  /// Force unauthenticated state without a server call.
  /// Called by AuthInterceptor when a token refresh fails mid-session.
  void forceLogout() {
    if (state is! AuthUnauthenticated) {
      emit(const AuthUnauthenticated());
    }
  }

  /// Verify OTP code
  /// If [loginAfterVerify] is true, emit AuthAuthenticated after successful verification
  Future<void> verifyOtp({
    required String login,
    required String otp,
    bool loginAfterVerify = false,
  }) async {
    emit(const AuthLoading());

    final result = await authRepository.verifyOtp(login: login, otp: otp);

    result.fold(
      (failure) =>
          emit(AuthError(failure.message ?? 'OTP verification failed')),
      (user) {
        if (loginAfterVerify) {
          // After verification, user should be authenticated
          emit(AuthAuthenticated(user));
          _pushCurrentFcmToken();
        } else {
          emit(AuthOtpVerified(user));
        }
      },
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
