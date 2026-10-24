import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:maktoob/core/api/offline_interceptors.dart';
import 'package:maktoob/core/offline/offline_database.dart';
import 'package:maktoob/core/offline/pending_actions_queue.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Answers from a script: an int is a status, an Exception is a dropped
/// connection.
class _ScriptedAdapter implements HttpClientAdapter {
  final List<Object> script;
  final List<RequestOptions> seen = [];

  _ScriptedAdapter(this.script);

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    seen.add(options);
    final next = script.isEmpty ? 200 : script.removeAt(0);
    if (next is Exception) throw next;
    return ResponseBody.fromString(jsonEncode({'n': seen.length}), next as int, headers: {
      Headers.contentTypeHeader: ['application/json'],
    });
  }

  @override
  void close({bool force = false}) {}
}

Dio _dio(_ScriptedAdapter adapter, {Box? cache}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api/v1', responseType: ResponseType.plain))
    ..httpClientAdapter = adapter;
  dio.interceptors.add(IdempotencyInterceptor());
  dio.interceptors.add(RetryInterceptor(dio, delays: const [Duration.zero, Duration.zero]));
  if (cache != null) dio.interceptors.add(OfflineCacheInterceptor(cache));
  return dio;
}

/// What a real adapter throws when the connection drops mid-request.
SocketException _dropped() => const SocketException('Connection reset by peer');

void main() {
  late Directory tmp;
  late Box box;

  setUpAll(() async {
    sqfliteFfiInit();
    tmp = await Directory.systemTemp.createTemp('maktoob_http_cache');
    Hive.init(tmp.path);
  });

  setUp(() async => box = await Hive.openBox('http_${DateTime.now().microsecondsSinceEpoch}'));

  tearDownAll(() async {
    await Hive.close();
    await tmp.delete(recursive: true);
  });

  test('every write carries one Idempotency-Key, kept across its retries', () async {
    final adapter = _ScriptedAdapter([503, 200]);
    await _dio(adapter).post('/events/1/guests/add', data: {'name': 'x'});

    expect(adapter.seen, hasLength(2), reason: '503 from the proxy is retried');
    final keys = adapter.seen.map((o) => o.headers[IdempotencyInterceptor.header]).toSet();
    expect(keys, hasLength(1), reason: 'the same key, so the server runs it once');
    expect(keys.single, matches(RegExp(r'^[0-9a-f-]{36}$')));
  });

  test('reads never get a key; a dead route is not retried', () async {
    final adapter = _ScriptedAdapter([200]);
    await _dio(adapter).get('/events');
    expect(adapter.seen.single.headers.containsKey(IdempotencyInterceptor.header), isFalse);

    final noRoute = DioException.connectionError(
      requestOptions: RequestOptions(path: '/x'),
      reason: 'Failed host lookup',
      error: const SocketException('Failed host lookup: api.test'),
    );
    expect(RetryInterceptor.retryable(noRoute), isFalse, reason: 'no network at all: fall back at once');
    expect(
      RetryInterceptor.retryable(DioException(requestOptions: RequestOptions(path: '/x'), error: _dropped())),
      isTrue,
    );
  });

  test('a GET opened offline shows the last good answer', () async {
    final online = _ScriptedAdapter([200]);
    final first = await _dio(online, cache: box).get('/events', queryParameters: {'page': 1});
    expect(first.headers.value('x-maktoob-cache'), isNull);

    final offline = _ScriptedAdapter([_dropped(), _dropped(), _dropped()]);
    final cached = await _dio(offline, cache: box).get('/events', queryParameters: {'page': 1});
    expect(cached.statusCode, 200);
    expect(cached.headers.value('x-maktoob-cache'), '1');
    // The same answer, marked as a saved copy so the screen can say so.
    final saved = jsonDecode(cached.data as String) as Map<String, dynamic>;
    expect(saved.remove('_offline'), containsPair('age_seconds', isA<int>()));
    expect(saved, jsonDecode(first.data as String));

    // Another page was never seen: the error stays an error.
    expect(
      () => _dio(_ScriptedAdapter([_dropped(), _dropped(), _dropped()]), cache: box).get('/events', queryParameters: {'page': 2}),
      throwsA(isA<DioException>()),
    );
  });

  test('live data is never cached (generation status, door, auth)', () {
    for (final path in ['/event-wizard/1/generation-status/2', '/door/pack', '/events/1/door/changes', '/auth/profile']) {
      expect(OfflineCacheInterceptor.cacheable(RequestOptions(path: path)), isFalse, reason: path);
    }
    expect(OfflineCacheInterceptor.cacheable(RequestOptions(path: '/events/5')), isTrue);
  });

  group('queued writes', () {
    Future<(PendingActionsQueue, _ScriptedAdapter)> queue(List<Object> script, {String? token = 'tok'}) async {
      final db = await OfflineDatabase.open(factory: databaseFactoryFfi, path: inMemoryDatabasePath, singleInstance: false);
      final adapter = _ScriptedAdapter(script);
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api/v1', validateStatus: (s) => s != null && s < 300))
        ..httpClientAdapter = adapter;
      return (PendingActionsQueue(database: () async => db, token: () async => token, dio: dio), adapter);
    }

    test('sent in order when the connection returns, with their own keys', () async {
      final (q, adapter) = await queue([200, 200]);
      await q.enqueue(label: 'offline_action_resend_invitation', method: 'POST', path: '/invitations/4/resend');
      await q.enqueue(label: 'offline_action_remove_invitation', method: 'DELETE', path: '/invitations/5');
      expect(await q.count(), 2);

      expect(await q.flush(), 2);
      expect(adapter.seen.map((o) => '${o.method} ${o.path}'), ['POST /invitations/4/resend', 'DELETE /invitations/5']);
      expect(adapter.seen.map((o) => o.headers[IdempotencyInterceptor.header]).toSet(), hasLength(2));
      expect(adapter.seen.first.headers['Authorization'], 'Bearer tok');
      expect(await q.count(), 0);
    });

    test('a dropped connection keeps the rest for later; a refusal is kept as failed', () async {
      final (q, adapter) = await queue([_dropped()]);
      await q.enqueue(label: 'a', method: 'POST', path: '/a');
      await q.enqueue(label: 'b', method: 'POST', path: '/b');
      expect(await q.flush(), 0);
      expect(adapter.seen, hasLength(1), reason: 'stops at the first network error');
      expect((await q.all()).every((a) => !a.failed), isTrue);

      adapter.script.addAll([422, 200]);
      expect(await q.flush(), 1);
      final left = await q.all();
      expect(left.single.label, 'a');
      expect(left.single.failed, isTrue);

      await q.retry(left.single.id);
      expect((await q.all()).single.failed, isFalse);
    });

    test('nothing is sent while signed out', () async {
      final (q, adapter) = await queue([200], token: null);
      await q.enqueue(label: 'a', method: 'POST', path: '/a');
      expect(await q.flush(), 0);
      expect(adapter.seen, isEmpty);
    });
  });
}
