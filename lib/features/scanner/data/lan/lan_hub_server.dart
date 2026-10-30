import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'lan_protocol.dart';

/// What the hub answers; the door engine implements it (one place decides,
/// whether the scan happened on the hub or on a joined phone).
abstract class LanHubHandlers {
  Future<Map<String, dynamic>> hello(Map<String, dynamic> payload);
  Future<Map<String, dynamic>> pack();
  Future<Map<String, dynamic>> claim(Map<String, dynamic> item);
  Future<Map<String, dynamic>> push(List<Map<String, dynamic>> items);
  Future<Map<String, dynamic>> changes(int since);
}

/// The venue hub's HTTP server on the local network (hotspot / venue Wi-Fi).
class LanHubServer {
  static const int defaultPort = 8787;
  static const int maxBody = 4 * 1024 * 1024;

  final int eventId;
  final LanCipher cipher;
  final LanHubHandlers handlers;

  HttpServer? _server;
  final StreamController<void> _changed = StreamController<void>.broadcast();
  final Map<String, DateTime> _peers = {};

  LanHubServer({required this.eventId, required this.cipher, required this.handlers});

  bool get running => _server != null;
  int get port => _server?.port ?? 0;

  /// Phones heard from in the last minute.
  int get peerCount {
    final since = DateTime.now().subtract(const Duration(minutes: 1));
    _peers.removeWhere((_, at) => at.isBefore(since));
    return _peers.length;
  }

  Future<void> start({int port = defaultPort}) async {
    if (_server != null) return;
    try {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, port, shared: true);
    } on SocketException {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
    }
    _server!.listen(_handle, onError: (_) {});
  }

  Future<void> stop() async {
    final s = _server;
    _server = null;
    _peers.clear();
    await s?.close(force: true);
  }

  /// Wake the phones waiting on the changes feed.
  void notifyChanged() {
    if (!_changed.isClosed) _changed.add(null);
  }

  /// The addresses joined phones can reach (private IPv4 of Wi-Fi / hotspot).
  Future<List<String>> addresses() async {
    final out = <String>[];
    try {
      for (final nic in await NetworkInterface.list(type: InternetAddressType.IPv4)) {
        for (final a in nic.addresses) {
          if (!a.isLoopback && _private(a.address)) out.add('${a.address}:$port');
        }
      }
    } catch (_) {}
    // Hotspot first (Android's softAP is usually 192.168.43.x / .x.1).
    out.sort((a, b) => (b.endsWith('.1:$port') ? 1 : 0) - (a.endsWith('.1:$port') ? 1 : 0));
    return out;
  }

  static bool _private(String ip) {
    final p = ip.split('.').map(int.tryParse).toList();
    if (p.length != 4 || p.contains(null)) return false;
    return p[0] == 10 || (p[0] == 172 && p[1]! >= 16 && p[1]! <= 31) || (p[0] == 192 && p[1] == 168);
  }

  Future<void> _handle(HttpRequest request) async {
    final res = request.response;
    try {
      final path = request.uri.path;
      if (request.method == 'GET' && path == '/ping') {
        return await _send(res, 200, {'app': 'maktoob-door', 'v': 1, 'event_id': eventId});
      }
      if (request.method != 'POST' || !path.startsWith('/v1/')) {
        return await _send(res, 404, {'error': 'not_found'});
      }

      final bytes = await _readBody(request);
      if (bytes == null) return await _send(res, 413, {'error': 'too_large'});
      final envelope = jsonDecode(utf8.decode(bytes));
      if (envelope is! Map) return await _send(res, 400, {'error': 'bad_request'});

      final Map<String, dynamic> payload;
      try {
        payload = await cipher.open(Map<String, dynamic>.from(envelope), path);
      } on LanAuthException {
        return await _send(res, 403, {'error': 'forbidden'});
      }
      if (payload['event_id'] != eventId) return await _send(res, 409, {'error': 'other_event'});
      final device = '${payload['device_uuid'] ?? ''}';
      if (device.isNotEmpty) _peers[device] = DateTime.now();

      final answer = await _dispatch(path.substring(4), payload);
      if (answer == null) return await _send(res, 404, {'error': 'not_found'});
      return await _send(res, 200, await cipher.seal(answer, path));
    } catch (_) {
      try {
        return await _send(res, 500, {'error': 'server'});
      } catch (_) {}
    }
  }

  Future<Map<String, dynamic>?> _dispatch(String op, Map<String, dynamic> payload) async {
    switch (op) {
      case 'hello':
        return handlers.hello(payload);
      case 'pack':
        return handlers.pack();
      case 'claim':
        final item = payload['item'];
        return item is Map ? handlers.claim(Map<String, dynamic>.from(item)) : {'result': 'refused', 'code': 'invalid'};
      case 'push':
        final items = payload['items'];
        return handlers.push(
          items is List ? items.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList() : const [],
        );
      case 'changes':
        final since = (payload['since'] as num?)?.toInt() ?? 0;
        final wait = ((payload['wait'] as num?)?.toInt() ?? 0).clamp(0, 25);
        var answer = await handlers.changes(since);
        if ((answer['records'] as List?)?.isEmpty ?? true) {
          if (wait > 0) {
            try {
              await _changed.stream.first.timeout(Duration(seconds: wait));
              answer = await handlers.changes(since);
            } on TimeoutException {
              // Nothing new: answer empty, the phone asks again.
            }
          }
        }
        return {...answer, 'peers': peerCount};
    }
    return null;
  }

  static Future<List<int>?> _readBody(HttpRequest request) async {
    final out = <int>[];
    await for (final chunk in request) {
      out.addAll(chunk);
      if (out.length > maxBody) return null;
    }
    return out;
  }

  static Future<void> _send(HttpResponse res, int status, Map<String, dynamic> body) async {
    res.statusCode = status;
    res.headers.contentType = ContentType.json;
    res.write(jsonEncode(body));
    await res.close();
  }
}
