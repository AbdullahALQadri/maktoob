import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/core/error/failures.dart';
import 'package:maktoob/features/scanner/presentation/cubit/scanner_state.dart';

import 'fake_scanner_repository.dart';

void main() {
  group('kiosk mode', () {
    test('auto-checks in with RSVP companions capped at max', () async {
      final repo = FakeScannerRepository()..scan = Right(guestEntity(max: 2));
      final cubit = await cubitFor(repo);
      await cubit.kioskScan('qr');

      expect(repo.checkInCalls, 1);
      expect(repo.sentCompanions, 2, reason: 'RSVP 3 capped at max 2');
      final s = cubit.state as KioskResult;
      expect(s.admitted, isTrue);
      expect(s.name, 'سارة');
      expect(s.companions, 2);
      await cubit.close();
    });

    test('a blocked QR (not yet valid / expired) is refused without a check-in', () async {
      final repo = FakeScannerRepository()
        ..scan = Right(guestEntity(canCheckIn: false, blockerCode: 'qr_not_yet_valid'));
      final cubit = await cubitFor(repo);
      await cubit.kioskScan('qr');

      expect(repo.checkInCalls, 0);
      final s = cubit.state as KioskResult;
      expect(s.admitted, isFalse);
      expect(s.code, 'qr_not_yet_valid');
      await cubit.close();
    });

    test('a guest coming back the same day is welcomed back; nothing is recorded again', () async {
      final repo = FakeScannerRepository()..scan = Right(guestEntity(already: true));
      final cubit = await cubitFor(repo);
      await cubit.kioskScan('qr');

      expect(repo.checkInCalls, 0);
      final s = cubit.state as KioskResult;
      expect(s.admitted, isTrue);
      expect(s.returning, isTrue);
      expect(s.checkedInAt, DateTime.utc(2026, 10, 10, 17, 5), reason: 'the first entry');
      expect(s.checkedInDevice, 'Women 1');
      await cubit.close();
    });

    test('coming back after the event day is refused: the QR is one day', () async {
      final repo = FakeScannerRepository()
        ..scan = Right(guestEntity(already: true, canCheckIn: false, blockerCode: 'qr_expired'));
      final cubit = await cubitFor(repo);
      await cubit.kioskScan('qr');

      final s = cubit.state as KioskResult;
      expect(s.admitted, isFalse);
      expect(s.code, 'qr_expired');
      await cubit.close();
    });

    test('another door let them in first: still a welcome back', () async {
      final repo = FakeScannerRepository()..checkInResult = guestEntity(already: true, returning: true);
      final cubit = await cubitFor(repo);
      await cubit.kioskScan('qr');

      final s = cubit.state as KioskResult;
      expect(s.admitted, isTrue);
      expect(s.returning, isTrue);
      expect(s.checkedInDevice, 'Women 1');
      await cubit.close();
    });

    test('an unknown QR is refused with its reason', () async {
      final repo = FakeScannerRepository()..scan = const Left(DoorRefusedFailure(reason: 'other_event'));
      final cubit = await cubitFor(repo);
      await cubit.kioskScan('qr');

      final s = cubit.state as KioskResult;
      expect(s.admitted, isFalse);
      expect(s.code, 'other_event');
      await cubit.close();
    });
  });
}
