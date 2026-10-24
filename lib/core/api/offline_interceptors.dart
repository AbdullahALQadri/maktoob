import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../utils/uuid.dart';

/// Every write carries an `Idempotency-Key`: when a weak network loses the
/// response and the request is sent again (RetryInterceptor, or the user
/// tapping again), the server answers from the first run instead of doing
/// it twice (backend `IdempotentRequests` middleware).
class IdempotencyInterceptor extends Interceptor {
  static const String header = 'Idempotency-Key';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.method.toUpperCase() != 'GET' && !options.headers.containsKey(header)) {
      options.headers[header] = Uuid.v4();
    }
    handler.next(options);
  }
}

/// Retries a request that died on the way (timeouts, a dropped connection,
/// a 502/503/504 from the proxy). Reads always; writes only with an
/// Idempotency-Key, so a retry never runs twice. With no network at all it
/// gives up at once (OfflineCacheInterceptor then serves the cached copy).
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final List<Duration> delays;

  RetryInterceptor(this.dio, {this.delays = const [Duration(milliseconds: 700), Duration(milliseconds: 1800)]});

  static const String _attemptKey = 'retry_attempt';
  final Random _random = Random();

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final attempt = (options.extra[_attemptKey] as int?) ?? 0;
    if (attempt >= delays.length || !retryable(err) || !_safe(options) || options.data is Stream) {
      return handler.next(err);
    }

    await Future<void>.delayed(delays[attempt] + Duration(milliseconds: _random.nextInt(400)));
    options.extra[_attemptKey] = attempt + 1;
    final data = options.data;
    if (data is FormData) options.data = data.clone();

    try {
      return handler.resolve(await dio.fetch<dynamic>(options));
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  static bool retryable(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return true;
      case DioExceptionType.badResponse:
        final s = e.response?.statusCode ?? 0;
        return s == 502 || s == 503 || s == 504;
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return !noNetwork(e);
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
        return false;
    }
  }

  /// The phone has no route at all (no point waiting to retry).
  static bool noNetwork(DioException e) {
    final error = e.error;
    if (error is SocketException) {
      final text = '${error.message} ${error.osError?.message ?? ''}'.toLowerCase();
      return text.contains('failed host lookup') ||
          text.contains('network is unreachable') ||
          text.contains('no address associated');
    }
    return false;
  }

  static bool _safe(RequestOptions o) {
    final m = o.method.toUpperCase();
    return m == 'GET' || m == 'HEAD' || o.headers.containsKey(IdempotencyInterceptor.header);
  }
}

/// Keeps the last good answer of the app's GETs and serves it when the
/// network is down, so screens open with what was last seen instead of an
/// error. Answers from the cache carry `x-maktoob-cache: 1` and the age.
class OfflineCacheInterceptor extends Interceptor {
  final Box box;
  final int maxEntries;
  final int maxBytes;

  OfflineCacheInterceptor(this.box, {this.maxEntries = 400, this.maxBytes = 2 * 1024 * 1024});

  /// Live data that must never come from a cache.
  static final List<RegExp> _never = [
    RegExp(r'/generation-status/'),
    RegExp(r'^/?auth/'),
    RegExp(r'/door/'),
    RegExp(r'^/?scanner/'),
    RegExp(r'^/?door/'),
    RegExp(r'/payments/initiate'),
  ];

  static bool cacheable(RequestOptions o) =>
      o.method.toUpperCase() == 'GET' && !_never.any((r) => r.hasMatch(o.path));

  static String keyOf(RequestOptions o) => 'GET ${o.uri}';

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final o = response.requestOptions;
    final status = response.statusCode ?? 0;
    final data = response.data;
    if (cacheable(o) && status >= 200 && status < 300 && data is String && data.length <= maxBytes) {
      unawaited(_put(keyOf(o), data));
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final o = err.requestOptions;
    final offline = err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        (err.type == DioExceptionType.unknown && err.error is SocketException) ||
        (err.type == DioExceptionType.badResponse && const [502, 503, 504].contains(err.response?.statusCode));
    if (!offline || !cacheable(o)) return handler.next(err);

    final entry = box.get(keyOf(o));
    if (entry is! Map || entry['b'] is! String) return handler.next(err);

    final savedAt = (entry['t'] as int?) ?? 0;
    final age = DateTime.now().millisecondsSinceEpoch - savedAt;
    handler.resolve(Response<dynamic>(
      requestOptions: o,
      data: markSaved(entry['b'] as String, age ~/ 1000),
      statusCode: 200,
      headers: Headers.fromMap({
        'x-maktoob-cache': ['1'],
        'x-maktoob-cache-age': ['${age ~/ 1000}'],
      }),
    ));
  }

  /// Adds `_offline: {age_seconds}` to a saved JSON object so the screen can
  /// say it shows the last saved copy. Other bodies pass through untouched.
  static String markSaved(String body, int ageSeconds) {
    try {
      final json = jsonDecode(body);
      if (json is! Map<String, dynamic>) return body;
      return jsonEncode({...json, '_offline': {'age_seconds': ageSeconds}});
    } catch (_) {
      return body;
    }
  }

  Future<void> _put(String key, String body) async {
    try {
      await box.put(key, {'t': DateTime.now().millisecondsSinceEpoch, 'b': body});
      if (box.length > maxEntries) {
        final entries = box.toMap().entries.toList()
          ..sort((a, b) => ((a.value is Map ? a.value['t'] : 0) as int).compareTo((b.value is Map ? b.value['t'] : 0) as int));
        await box.deleteAll(entries.take(box.length - maxEntries + 50).map((e) => e.key));
      }
    } catch (_) {
      // A full or locked box only costs the offline copy.
    }
  }
}
