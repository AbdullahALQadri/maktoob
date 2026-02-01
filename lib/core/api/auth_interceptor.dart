import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../utils/storage/secure_storage_service.dart';
import 'end_points.dart';

/// Interceptor that handles automatic token injection, refresh, and 401 responses.
///
/// - Injects the Bearer token from secure storage into every request.
/// - On 401 responses, attempts to refresh the token before forcing re-login.
/// - Uses a lock to prevent concurrent refresh attempts.
class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;

  bool _isRefreshing = false;
  final _pendingRequests = <({ErrorInterceptorHandler handler, DioException err})>[];

  AuthInterceptor({required SecureStorageService secureStorage})
      : _secureStorage = secureStorage;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
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
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Don't try to refresh if the failed request was the refresh call itself
    final path = err.requestOptions.path;
    if (path == Endpoints.clientRefreshToken || _isPublicEndpoint(path)) {
      if (kDebugMode) {
        debugPrint('AuthInterceptor: 401 on auth endpoint, clearing credentials');
      }
      await _secureStorage.clearSecureData();
      return handler.next(err);
    }

    // If already refreshing, queue this request
    if (_isRefreshing) {
      _pendingRequests.add((handler: handler, err: err));
      return;
    }

    _isRefreshing = true;

    final refreshed = await _tryRefreshToken();

    if (refreshed) {
      // Retry the original request with new token
      final retried = await _retryRequest(err.requestOptions);
      if (retried != null) {
        handler.resolve(retried);
      } else {
        handler.next(err);
      }

      // Retry all queued requests
      final queued = List.of(_pendingRequests);
      _pendingRequests.clear();
      for (final pending in queued) {
        final retried = await _retryRequest(pending.err.requestOptions);
        if (retried != null) {
          pending.handler.resolve(retried);
        } else {
          pending.handler.next(pending.err);
        }
      }
    } else {
      // Refresh failed — clear credentials and reject all
      if (kDebugMode) {
        debugPrint('AuthInterceptor: refresh failed, clearing credentials');
      }
      await _secureStorage.clearSecureData();
      handler.next(err);

      final queued = List.of(_pendingRequests);
      _pendingRequests.clear();
      for (final pending in queued) {
        pending.handler.next(pending.err);
      }
    }

    _isRefreshing = false;
  }

  /// Attempts to refresh the token using the stored refresh token.
  Future<bool> _tryRefreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;

      // Use a fresh Dio instance to avoid interceptor loops
      final dio = Dio(BaseOptions(baseUrl: Endpoints.baseUrl));
      final response = await dio.post(
        Endpoints.clientRefreshToken,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final newToken = data['data']?['token'] ?? data['token'];
        final newRefresh = data['data']?['refresh_token'] ?? data['refresh_token'];

        if (newToken != null) {
          await _secureStorage.saveToken(newToken as String);
          if (newRefresh != null) {
            await _secureStorage.saveRefreshToken(newRefresh as String);
          }
          if (kDebugMode) {
            debugPrint('AuthInterceptor: token refreshed successfully');
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthInterceptor: refresh error: $e');
      }
      return false;
    }
  }

  /// Retries a request with the new token from secure storage.
  Future<Response?> _retryRequest(RequestOptions options) async {
    try {
      final token = await _secureStorage.getToken();
      final dio = Dio(BaseOptions(baseUrl: Endpoints.baseUrl));
      final retryOptions = Options(
        method: options.method,
        headers: {
          ...options.headers,
          'Authorization': 'Bearer $token',
        },
      );
      return await dio.request(
        options.path,
        data: options.data,
        queryParameters: options.queryParameters,
        options: retryOptions,
      );
    } catch (_) {
      return null;
    }
  }

  /// Check if the endpoint is public (no auth required).
  bool _isPublicEndpoint(String path) {
    return path.startsWith('/public/') ||
        path == Endpoints.clientLogin ||
        path == Endpoints.clientRegister ||
        path == Endpoints.clientForgotPassword ||
        path == Endpoints.clientVerifyOtp ||
        path == Endpoints.clientResetPassword ||
        path == Endpoints.clientRefreshToken;
  }
}
