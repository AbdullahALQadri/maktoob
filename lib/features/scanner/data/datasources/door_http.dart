import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/api/end_points.dart';
import '../../domain/entities/door_entities.dart';

/// Why a door call failed. The door keeps working on every one of them:
/// [network] → decide locally; [auth] → keep the data, ask to sign in
/// again; [revoked] → the host removed this phone.
enum DoorErrorKind { network, auth, revoked, refused, server }

class DoorHttpException implements Exception {
  final DoorErrorKind kind;
  final int? status;
  final String? code;
  final String? message;

  const DoorHttpException(this.kind, {this.status, this.code, this.message});

  @override
  String toString() => 'DoorHttpException($kind, $status, $code, $message)';
}

/// The door's own HTTP client.
///
/// Separate from the app's DioConsumer on purpose: a door phone may hold a
/// door token (paired staff phone, scanner account) instead of the client
/// token, and a 401 here must never log the host out or wipe anything.
class DoorHttp {
  final Dio dio;
  final Future<String?> Function(DoorSession session) tokenFor;

  DoorHttp({required this.tokenFor, Dio? dio}) : dio = dio ?? _build();

  static Dio _build() {
    final d = Dio(
      BaseOptions(
        baseUrl: Endpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 45),
        sendTimeout: const Duration(seconds: 30),
        responseType: ResponseType.json,
        headers: {'Accept': 'application/json'},
        validateStatus: (s) => s != null && s >= 200 && s < 300,
      ),
    );
    final adapter = d.httpClientAdapter;
    if (adapter is IOHttpClientAdapter) {
      adapter.createHttpClient = () {
        final client = HttpClient();
        // Same policy as DioConsumer: strict TLS in release builds.
        client.badCertificateCallback = (cert, host, port) => !kReleaseMode;
        return client;
      };
    }
    return d;
  }

  Future<Map<String, dynamic>> request(
    DoorSession? session,
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    Duration? timeout,
    String? bearer,
  }) async {
    final token = bearer ?? (session == null ? null : await tokenFor(session));
    try {
      final response = await dio.request<dynamic>(
        path,
        data: body,
        queryParameters: query,
        options: Options(
          method: method,
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
            if (body != null) 'Content-Type': 'application/json',
          },
          receiveTimeout: timeout,
          sendTimeout: timeout,
        ),
      );
      final data = response.data;
      return data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  DoorHttpException _map(DioException e) {
    final res = e.response;
    if (res == null) return const DoorHttpException(DoorErrorKind.network);
    final body = res.data is Map ? Map<String, dynamic>.from(res.data as Map) : const <String, dynamic>{};
    final code = body['code']?.toString();
    final message = body['message']?.toString();
    final status = res.statusCode ?? 0;
    if (status == 401 && code == 'device_revoked') {
      return DoorHttpException(DoorErrorKind.revoked, status: status, code: code, message: message);
    }
    if (status == 401) return DoorHttpException(DoorErrorKind.auth, status: status, code: code, message: message);
    if (status == 403 || status == 404 || status == 422) {
      return DoorHttpException(DoorErrorKind.refused, status: status, code: code, message: message);
    }
    // 429 / 5xx / a proxy page: treat like a bad connection, try again later.
    if (status == 429 || status >= 500) return DoorHttpException(DoorErrorKind.network, status: status);
    return DoorHttpException(DoorErrorKind.server, status: status, code: code, message: message);
  }
}
