import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../api/end_points.dart';
import '../api/offline_interceptors.dart';
import '../utils/uuid.dart';

/// A write made with no connection, waiting to be sent.
class PendingAction {
  final int id;
  final String label;
  final Map<String, String> labelArgs;
  final String method;
  final String path;
  final Map<String, dynamic>? body;
  final String idempotencyKey;

  /// pending (will be sent) | failed (the server refused it; see [lastError]).
  final String status;
  final int attempts;
  final String? lastError;
  final DateTime createdAt;

  const PendingAction({
    required this.id,
    required this.label,
    required this.labelArgs,
    required this.method,
    required this.path,
    required this.body,
    required this.idempotencyKey,
    required this.status,
    required this.attempts,
    required this.lastError,
    required this.createdAt,
  });

  bool get failed => status == 'failed';
}

/// Writes queued while offline (e.g. re-sending an invitation, removing a
/// guest, marking notifications read), sent in order when the connection
/// returns: now if the app is open, else by the background task. Each keeps
/// its Idempotency-Key, so a send whose answer was lost is never repeated.
///
/// [label] is a translation key the "waiting to send" screen shows.
class PendingActionsQueue {
  final Future<Database> Function() database;
  final Future<String?> Function() token;
  final Dio dio;

  final StreamController<int> _count = StreamController<int>.broadcast();
  bool _flushing = false;

  /// Called when something was queued (schedule a background send).
  void Function()? onQueued;

  PendingActionsQueue({required this.database, required this.token, Dio? dio}) : dio = dio ?? _build();

  static Dio _build() {
    final d = Dio(BaseOptions(
      baseUrl: Endpoints.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      responseType: ResponseType.plain,
      validateStatus: (s) => s != null && s >= 200 && s < 300,
    ));
    final adapter = d.httpClientAdapter;
    if (adapter is IOHttpClientAdapter) {
      adapter.createHttpClient = () => HttpClient()..badCertificateCallback = (cert, host, port) => !kReleaseMode;
    }
    return d;
  }

  /// How many writes are waiting (pending or failed).
  Stream<int> get countStream => _count.stream;

  Future<int> enqueue({
    required String label,
    required String method,
    required String path,
    Map<String, dynamic>? body,
    Map<String, String> labelArgs = const {},
    String owner = 'client',
  }) async {
    final db = await database();
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = await db.insert('pending_actions', {
      'owner': owner,
      'label': label,
      'label_args': jsonEncode(labelArgs),
      'method': method.toUpperCase(),
      'path': path,
      'body': body == null ? null : jsonEncode(body),
      'idempotency_key': Uuid.v4(),
      'status': 'pending',
      'created_at': now,
      'updated_at': now,
    });
    await _publish();
    onQueued?.call();
    return id;
  }

  Future<List<PendingAction>> all() async {
    final db = await database();
    return (await db.query('pending_actions', orderBy: 'id ASC')).map((r) {
      final args = r['label_args'] == null ? const {} : jsonDecode('${r['label_args']}') as Map;
      return PendingAction(
        id: r['id'] as int,
        label: '${r['label']}',
        labelArgs: args.map((k, v) => MapEntry('$k', '$v')),
        method: '${r['method']}',
        path: '${r['path']}',
        body: r['body'] == null ? null : Map<String, dynamic>.from(jsonDecode('${r['body']}') as Map),
        idempotencyKey: '${r['idempotency_key']}',
        status: '${r['status']}',
        attempts: r['attempts'] as int,
        lastError: r['last_error'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(r['created_at'] as int),
      );
    }).toList();
  }

  Future<int> count() async {
    final db = await database();
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM pending_actions')) ?? 0;
  }

  Future<void> remove(int id) async {
    final db = await database();
    await db.delete('pending_actions', where: 'id = ?', whereArgs: [id]);
    await _publish();
  }

  Future<void> retry(int id) async {
    final db = await database();
    await db.update('pending_actions', {'status': 'pending', 'last_error': null}, where: 'id = ?', whereArgs: [id]);
    await _publish();
    unawaited(flush());
  }

  /// Sends what is pending, oldest first. Stops at the first network error
  /// (the rest would fail too). Returns how many were sent.
  Future<int> flush() async {
    if (_flushing) return 0;
    _flushing = true;
    var sent = 0;
    try {
      final bearer = await token();
      if (bearer == null || bearer.isEmpty) return 0;
      for (final action in (await all()).where((a) => !a.failed)) {
        final outcome = await _send(action, bearer);
        final db = await database();
        if (outcome == null) {
          await db.delete('pending_actions', where: 'id = ?', whereArgs: [action.id]);
          sent++;
        } else if (outcome == _Outcome.network) {
          await db.rawUpdate('UPDATE pending_actions SET attempts = attempts + 1 WHERE id = ?', [action.id]);
          break;
        } else if (outcome == _Outcome.signedOut) {
          break;
        } else {
          await db.update(
            'pending_actions',
            {'status': 'failed', 'last_error': outcome.message, 'updated_at': DateTime.now().millisecondsSinceEpoch},
            where: 'id = ?',
            whereArgs: [action.id],
          );
        }
      }
    } finally {
      _flushing = false;
      await _publish();
    }
    return sent;
  }

  Future<_Outcome?> _send(PendingAction a, String bearer) async {
    try {
      await dio.request<dynamic>(
        a.path,
        data: a.body,
        options: Options(method: a.method, headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearer',
          IdempotencyInterceptor.header: a.idempotencyKey,
        }),
      );
      return null;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == null || status == 429 || status >= 500) return _Outcome.network;
      if (status == 401) return _Outcome.signedOut;
      String? message;
      try {
        final body = jsonDecode('${e.response?.data}');
        if (body is Map) message = body['message']?.toString();
      } catch (_) {}
      return _Outcome.refused(message ?? 'HTTP $status');
    }
  }

  Future<void> _publish() async {
    if (!_count.isClosed) _count.add(await count());
  }
}

class _Outcome {
  final String? message;
  const _Outcome._(this.message);

  static const _Outcome network = _Outcome._('network');
  static const _Outcome signedOut = _Outcome._('signed_out');
  factory _Outcome.refused(String message) => _Outcome._(message);
}
