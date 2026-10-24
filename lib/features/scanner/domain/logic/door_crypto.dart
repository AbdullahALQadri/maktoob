import 'dart:convert';

import 'package:crypto/crypto.dart';

/// The door pack's lookup hashes and the signed QR token, byte for byte the
/// same as `App\Services\Door\DoorKeys` in the backend (both test suites pin
/// the same vector).
class DoorCrypto {
  DoorCrypto._();

  static const String tokenVersion = 'v1';

  /// The pack sends its keys as unpadded base64url.
  static List<int> decodeKey(String encoded) =>
      encoded.isEmpty ? const [] : base64Url.decode(base64Url.normalize(encoded));

  /// HMAC-SHA256(salt, lower-case key), first 16 bytes as hex.
  static String lookupHash(List<int> salt, String key) {
    final mac = Hmac(sha256, salt).convert(utf8.encode(key.trim().toLowerCase()));
    return mac.toString().substring(0, 32);
  }

  /// The parsed door token when its signature is genuine, else null.
  static DoorToken? verifyToken(List<int> signKey, String token, String shortUrl) {
    final parts = token.trim().split('.');
    if (parts.length != 4) return null;
    final event = int.tryParse(parts[0]);
    final invitation = int.tryParse(parts[1]);
    final max = parts[2];
    if (event == null || invitation == null) return null;
    if (max != 'n' && int.tryParse(max) == null) return null;

    final expected = signature(signKey, event, invitation, max, shortUrl);
    if (!_constantTimeEquals(expected, parts[3])) return null;

    return DoorToken(eventId: event, invitationId: invitation, maxCompanions: max == 'n' ? null : int.parse(max));
  }

  static String signature(List<int> signKey, int eventId, int invitationId, String max, String shortUrl) {
    final message = [tokenVersion, eventId, invitationId, max, shortUrl.trim().toLowerCase()].join('|');
    final mac = Hmac(sha256, signKey).convert(utf8.encode(message)).bytes.sublist(0, 12);
    return base64Url.encode(mac).replaceAll('=', '');
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}

class DoorToken {
  final int eventId;
  final int invitationId;
  final int? maxCompanions;

  const DoorToken({required this.eventId, required this.invitationId, this.maxCompanions});
}
