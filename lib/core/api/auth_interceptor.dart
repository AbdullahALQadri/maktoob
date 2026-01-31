import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../utils/storage/secure_storage_service.dart';
import 'end_points.dart';

/// Interceptor that handles automatic token injection and 401 responses.
///
/// - Injects the Bearer token from secure storage into every request.
/// - On 401 responses, clears stored credentials to force re-login.
class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;

  AuthInterceptor({required SecureStorageService secureStorage})
      : _secureStorage = secureStorage;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip token injection for public endpoints and auth endpoints
    final path = options.path;
    if (_isPublicEndpoint(path)) {
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
    if (err.response?.statusCode == 401) {
      debugPrint('AuthInterceptor: 401 received, clearing credentials');
      await _secureStorage.clearSecureData();
    }

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
