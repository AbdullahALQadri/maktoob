import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/features/scanner/domain/logic/door_crypto.dart';
import 'package:maktoob/features/scanner/domain/logic/scan_key.dart';

/// The phone must compute exactly what the server computes, or an offline
/// door would not recognise a real invitation. The same vector is pinned in
/// maktoob-backend/tests/Feature/Door/DoorPackTest.php
/// (test_keys_match_the_vector_pinned_in_the_flutter_tests).
void main() {
  const saltB64 = '-2gfNPteO2iYw2Hdesm093k9vVcJbmDOnmgMSf3etYk';
  const signB64 = 'FGELBCcvhnLmJGsEBnBbQ25R4XZ9Z23xZ1n2w8Dxc7A';
  final salt = DoorCrypto.decodeKey(saltB64);
  final sign = DoorCrypto.decodeKey(signB64);

  group('lookup hash (pack)', () {
    test('matches the backend for the qr_code and the short_url', () {
      expect(salt.length, 32);
      expect(DoorCrypto.lookupHash(salt, 'AB12CD34'), '1ff24f004aae5eae0e259cb26390146c');
      expect(DoorCrypto.lookupHash(salt, 'k3x9p2m7q8w1'), '796c4e2089436557b0a465b7b0dab65d');
    });

    test('is case- and space-insensitive like the server lookup', () {
      expect(DoorCrypto.lookupHash(salt, ' ab12cd34 '), DoorCrypto.lookupHash(salt, 'AB12CD34'));
    });
  });

  group('signed QR token', () {
    test('matches the backend signature', () {
      expect(DoorCrypto.signature(sign, 42, 777, '3', 'k3x9p2m7q8w1'), '99SbV2t8IM2fyVMr');
      expect(DoorCrypto.signature(sign, 42, 778, 'n', 'zz00yy11xx22'), '0G747QimcRy1WgKX');
    });

    test('verifies a genuine token and parses it', () {
      final token = DoorCrypto.verifyToken(sign, '42.777.3.99SbV2t8IM2fyVMr', 'k3x9p2m7q8w1');
      expect(token, isNotNull);
      expect(token!.eventId, 42);
      expect(token.invitationId, 777);
      expect(token.maxCompanions, 3);
      expect(DoorCrypto.verifyToken(sign, '42.778.n.0G747QimcRy1WgKX', 'zz00yy11xx22')!.maxCompanions, isNull);
    });

    test('refuses an edited number, another link, or garbage', () {
      expect(DoorCrypto.verifyToken(sign, '42.777.9.99SbV2t8IM2fyVMr', 'k3x9p2m7q8w1'), isNull);
      expect(DoorCrypto.verifyToken(sign, '42.777.3.99SbV2t8IM2fyVMr', 'someoneelse1'), isNull);
      expect(DoorCrypto.verifyToken(sign, 'not-a-token', 'k3x9p2m7q8w1'), isNull);
      expect(DoorCrypto.verifyToken(salt, '42.777.3.99SbV2t8IM2fyVMr', 'k3x9p2m7q8w1'), isNull);
    });
  });

  group('scan key (mirrors Invitation::extractScanKey)', () {
    test('invitation URL with the door token', () {
      final k = ScanKey.extract('https://maktoob.social/i/k3x9p2m7q8w1?k=42.777.3.99SbV2t8IM2fyVMr');
      expect(k.key, 'k3x9p2m7q8w1');
      expect(k.token, '42.777.3.99SbV2t8IM2fyVMr');
    });

    test('older QRs: plain URL, trailing slash, bare code, JSON payload', () {
      expect(ScanKey.extract('https://maktoob.social/i/abcd1234/').key, 'abcd1234');
      expect(ScanKey.extract('https://maktoob.social/i/abcd1234').token, isNull);
      expect(ScanKey.extract('  AB12CD34 ').key, 'AB12CD34');
      expect(ScanKey.extract('{"code":"AB12CD34","url":"https://x/i/zzz"}').key, 'AB12CD34');
      expect(ScanKey.extract('{"url":"https://maktoob.social/i/zzz999"}').key, 'zzz999');
      expect(ScanKey.extract('').isEmpty, isTrue);
    });
  });
}
