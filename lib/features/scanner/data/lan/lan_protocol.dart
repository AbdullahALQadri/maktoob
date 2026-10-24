import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

/// The venue hub: one door phone (usually the one sharing its hotspot) runs
/// a small server on the local network, and the other doors join it by
/// scanning its QR. No internet is needed; the doors still see each other's
/// check-ins in a second or two, so a shared QR is refused at the second door.
///
/// Every message is AES-256-GCM sealed with the hub's session secret (from
/// the join QR), the request path bound as associated data: phones without
/// the QR can neither read the guest list nor add check-ins.

/// What the hub's join QR carries.
class LanJoinInfo {
  static const String prefix = 'maktoob-door:1:';

  final List<String> hosts;
  final int eventId;
  final String eventTitle;
  final String hubName;
  final List<int> secret;

  const LanJoinInfo({
    required this.hosts,
    required this.eventId,
    required this.eventTitle,
    required this.hubName,
    required this.secret,
  });

  static List<int> newSecret() {
    final r = Random.secure();
    return List<int>.generate(32, (_) => r.nextInt(256));
  }

  Map<String, dynamic> toJson() => {
    'h': hosts,
    'e': eventId,
    't': eventTitle,
    'n': hubName,
    'k': base64Url.encode(secret).replaceAll('=', ''),
  };

  static LanJoinInfo? fromJson(Map<String, dynamic> j) {
    try {
      return LanJoinInfo(
        hosts: (j['h'] as List).map((h) => '$h').toList(),
        eventId: (j['e'] as num).toInt(),
        eventTitle: '${j['t'] ?? ''}',
        hubName: '${j['n'] ?? ''}',
        secret: base64Url.decode(base64Url.normalize('${j['k']}')),
      );
    } catch (_) {
      return null;
    }
  }

  /// The text inside the join QR.
  String encode() => prefix + base64Url.encode(utf8.encode(jsonEncode(toJson()))).replaceAll('=', '');

  static LanJoinInfo? decode(String raw) {
    final text = raw.trim();
    if (!text.startsWith(prefix)) return null;
    try {
      final json = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(text.substring(prefix.length)))));
      return json is Map ? fromJson(Map<String, dynamic>.from(json)) : null;
    } catch (_) {
      return null;
    }
  }

  String toStorage() => jsonEncode(toJson());

  static LanJoinInfo? fromStorage(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
    } catch (_) {
      return null;
    }
  }
}

class LanAuthException implements Exception {
  const LanAuthException();
}

/// AES-256-GCM envelope `{n: nonce, c: ciphertext+tag}` (base64url).
class LanCipher {
  final SecretKey _key;
  final AesGcm _aes = AesGcm.with256bits();

  LanCipher(List<int> secret) : _key = SecretKey(secret);

  Future<Map<String, dynamic>> seal(Map<String, dynamic> payload, String path) async {
    final nonce = _aes.newNonce();
    final box = await _aes.encrypt(
      utf8.encode(jsonEncode(payload)),
      secretKey: _key,
      nonce: nonce,
      aad: utf8.encode(path),
    );
    return {
      'n': base64Url.encode(nonce),
      'c': base64Url.encode([...box.cipherText, ...box.mac.bytes]),
    };
  }

  Future<Map<String, dynamic>> open(Map<String, dynamic> envelope, String path) async {
    try {
      final nonce = base64Url.decode(base64Url.normalize('${envelope['n']}'));
      final data = base64Url.decode(base64Url.normalize('${envelope['c']}'));
      if (data.length < 16) throw const LanAuthException();
      final clear = await _aes.decrypt(
        SecretBox(data.sublist(0, data.length - 16), nonce: nonce, mac: Mac(data.sublist(data.length - 16))),
        secretKey: _key,
        aad: utf8.encode(path),
      );
      final json = jsonDecode(utf8.decode(clear));
      if (json is! Map) throw const LanAuthException();
      return Map<String, dynamic>.from(json);
    } on LanAuthException {
      rethrow;
    } catch (_) {
      throw const LanAuthException();
    }
  }
}
