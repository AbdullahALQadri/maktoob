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
  /// Organization: name, email, phone, location, password
  Future<void> register({
    required String name,
    String? email,
    required String phone,
    required String password,
    required String userType,
    String? location,
  }) async {
    emit(const AuthLoading());

    final result = await authRepository.register(
      name: name,
      email: email ?? '',
      phone: phone,
      password: password,
      userType: userType,
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

  /// Reset to unauthenticated (clear error state)
  void resetState() {
    emit(const AuthUnauthenticated());
  }
}
