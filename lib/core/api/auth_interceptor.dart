import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../utils/storage/secure_storage_service.dart';
import 'end_points.dart';

/// Interceptor that handles automatic token injection and 401 responses.
///
/// - Injects the Bearer token from secure storage into every request.
/// - On 401 to an authed endpoint: clears credentials and signals re-login
///   via [onUnauthenticated]. (No refresh-token flow: nothing in the app
///   currently writes a refresh token, so the previous refresh path was
///   dead and only delayed the inevitable logout.)
/// - On 401 to a public/auth endpoint: passes through so the caller can
///   show "wrong password" instead of yanking the user to login.
class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;

  /// Called after credentials are cleared due to a 401.
  /// Wire this to `AuthCubit` to navigate the user back to the login screen.
  final VoidCallback? onUnauthenticated;

  AuthInterceptor({
    required SecureStorageService secureStorage,
    this.onUnauthenticated,
  }) : _secureStorage = secureStorage;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isPublicEndpoint(options.path)) {
      return handler.next(options);
    }

    final token = await _secureStorage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // 401 on a public/auth endpoint = wrong creds — let the caller see it.
    if (_isPublicEndpoint(err.requestOptions.path)) {
      return handler.next(err);
    }

    if (kDebugMode) {
      debugPrint('AuthInterceptor: 401 on ${err.requestOptions.path}, clearing credentials');
    }
    await _secureStorage.clearSecureData();
    onUnauthenticated?.call();
    handler.next(err);
  }

  /// Check if the endpoint is public (no auth required).
  bool _isPublicEndpoint(String path) {
    return path.startsWith('/public/') ||
        path == Endpoints.clientLogin ||
        path == Endpoints.clientRegister ||
        path == Endpoints.clientForgotPassword ||
        path == Endpoints.clientVerifyOtp ||
        path == Endpoints.clientResetPassword;
  }
}
