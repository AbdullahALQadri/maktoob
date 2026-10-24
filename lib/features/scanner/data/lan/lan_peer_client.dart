import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'lan_protocol.dart';

class LanUnavailableException implements Exception {
  const LanUnavailableException();
}

/// A door phone joined to the venue hub (it scanned the hub's join QR).
class LanPeerClient {
  final LanJoinInfo join;
  final LanCipher cipher;
  final String deviceUuid;
  final String deviceName;
  final int? Function() gateId;

  String? _host;

  LanPeerClient({required this.join, required this.deviceUuid, required this.deviceName, required this.gateId})
    : cipher = LanCipher(join.secret);

  /// The hub address that answered last.
  String? get host => _host;

  Future<Map<String, dynamic>> call(
    String op,
    Map<String, dynamic> payload, {
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final hosts = [if (_host != null) _host!, ...join.hosts.where((h) => h != _host)];
    for (final host in hosts) {
      try {
        final answer = await _post(host, op, payload, timeout);
        _host = host;
        return answer;
      } on LanAuthException {
        rethrow;
      } catch (_) {
        // Try the hub's next address.
      }
    }
    _host = null;
    throw const LanUnavailableException();
  }

  /// One exchange with one hub address; [timeout] covers all of it (an
  /// unreachable address still fails after the 2 s connection timeout).
  Future<Map<String, dynamic>> _post(String host, String op, Map<String, dynamic> payload, Duration timeout) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 2);
    try {
      return await _exchange(client, host, '/v1/$op', payload).timeout(timeout);
    } finally {
      client.close(force: true);
    }
  }

  Future<Map<String, dynamic>> _exchange(
    HttpClient client,
    String host,
    String path,
    Map<String, dynamic> payload,
  ) async {
    final body = await cipher.seal({
      ...payload,
      'event_id': join.eventId,
      'device_uuid': deviceUuid,
      'device_name': deviceName,
      'gate_id': gateId(),
      'ts': DateTime.now().toUtc().millisecondsSinceEpoch,
    }, path);
    final request = await client.postUrl(Uri.parse('http://$host$path'));
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(body));
    final response = await request.close();
    final text = await response.transform(utf8.decoder).join();
    if (response.statusCode == 403) throw const LanAuthException();
    if (response.statusCode != 200) throw const LanUnavailableException();
    final envelope = jsonDecode(text);
    if (envelope is! Map) throw const LanUnavailableException();
    return cipher.open(Map<String, dynamic>.from(envelope), path);
  }

  Future<Map<String, dynamic>> hello() => call('hello', const {});

  Future<Map<String, dynamic>> pack() => call('pack', const {}, timeout: const Duration(seconds: 60));

  /// Longer than the hub's own live claim for this door
  /// (DoorEngine.peerLiveTimeout) plus the local network, so the hub's
  /// answer, not a timeout, decides.
  Future<Map<String, dynamic>> claim(Map<String, dynamic> item) =>
      call('claim', {'item': item}, timeout: const Duration(seconds: 4));

  Future<Map<String, dynamic>> push(List<Map<String, dynamic>> items) =>
      call('push', {'items': items}, timeout: const Duration(seconds: 10));

  /// Long-polls up to [wait] seconds for check-ins after [since].
  Future<Map<String, dynamic>> changes(int since, {int wait = 20}) =>
      call('changes', {'since': since, 'wait': wait}, timeout: Duration(seconds: wait + 8));
}
