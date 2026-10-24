import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/config/locale/app_localizations_setup.dart';
import 'package:maktoob/core/error/failures.dart';
import 'package:maktoob/features/events/data/datasources/events_remote_data_source.dart';
import 'package:maktoob/features/events/data/models/event_model.dart';
import 'package:maktoob/features/scanner/domain/entities/check_in_guest_entity.dart';
import 'package:maktoob/features/scanner/domain/entities/door_entities.dart';
import 'package:maktoob/features/scanner/presentation/cubit/scanner_state.dart';
import 'package:maktoob/features/scanner/presentation/widgets/guest_verified_dialog.dart';
import 'package:maktoob/features/scanner/presentation/widgets/returning_guest_dialog.dart';

import 'fake_scanner_repository.dart';

void main() {
  group('entity', () {
    test('companions to preselect are the RSVP count capped at the maximum', () {
      expect(guestEntity(max: 2).defaultCompanions, 2, reason: 'RSVP 3 capped at max 2');
      expect(guestEntity().defaultCompanions, 3, reason: 'no maximum');
    });
  });

  group('cubit', () {
    test('a blocked guest is refused locally with the door reason', () async {
      final repo = FakeScannerRepository()..scan = Right(guestEntity(canCheckIn: false, blockerCode: 'qr_expired'));
      final cubit = await cubitFor(repo);
      await cubit.processQRCode('qr');
      await cubit.checkInGuest('7', companions: 0);

      expect(repo.checkInCalls, 0);
      expect((cubit.state as ScannerError).code, 'qr_expired');
      await cubit.close();
    });

    test('sends the chosen companions; a declined RSVP succeeds with a warning', () async {
      final repo = FakeScannerRepository()..scan = Right(guestEntity(max: 2, declined: true));
      final cubit = await cubitFor(repo);
      await cubit.processQRCode('qr');
      await cubit.checkInGuest('7', companions: 2);

      expect(repo.sentCompanions, 2);
      expect(repo.sentManual, isFalse);
      final s = cubit.state as GuestCheckedIn;
      expect(s.guest.declinedRsvp, isTrue);
      expect(s.guest.warnings, contains('declined'));
      await cubit.close();
    });

    test('picked from the list (no QR) is recorded as manual', () async {
      final repo = FakeScannerRepository();
      final cubit = await cubitFor(repo);
      await cubit.checkInGuest('7', companions: 1, manual: true);

      expect(repo.sentManual, isTrue);
      expect(cubit.state, isA<GuestCheckedIn>());
      await cubit.close();
    });

    test('a guest scanned again the same day is a return, shown as such', () async {
      final repo = FakeScannerRepository()..scan = Right(guestEntity(already: true));
      final cubit = await cubitFor(repo);
      await cubit.processQRCode('qr');

      expect((cubit.state as GuestScanned).isReturning, isTrue);
      await cubit.close();
    });

    test('another door, the hub or the server let them in first: admitted as a return', () async {
      final repo = FakeScannerRepository()..checkInResult = guestEntity(already: true, returning: true);
      final cubit = await cubitFor(repo);
      await cubit.processQRCode('qr');
      await cubit.checkInGuest('7');

      final s = cubit.state as GuestCheckedIn;
      expect(s.guest.returning, isTrue);
      expect(s.guest.checkedInAt, DateTime.utc(2026, 10, 10, 17, 5), reason: 'the first entry');
      expect(s.guest.checkedInDevice, 'Women 1');
      await cubit.close();
    });

    test('a refusal carries its code (and the server text when the server decided)', () async {
      final repo = FakeScannerRepository()
        ..checkInFailure = const DoorRefusedFailure(
          reason: 'too_many_companions',
          maxCompanions: 2,
          message: 'الحد الأقصى 2',
        );
      final cubit = await cubitFor(repo);
      await cubit.processQRCode('qr');
      await cubit.checkInGuest('7', companions: 3);

      final s = cubit.state as ScannerError;
      expect(s.code, 'too_many_companions');
      expect(s.maxCompanions, 2);
      expect(s.message, 'الحد الأقصى 2');
      await cubit.close();
    });

    test('an unknown QR is an error with its code, nothing is checked in', () async {
      final repo = FakeScannerRepository()..scan = const Left(DoorRefusedFailure(reason: 'not_found'));
      final cubit = await cubitFor(repo);
      await cubit.processQRCode('qr');

      expect((cubit.state as ScannerError).code, 'not_found');
      expect(repo.checkInCalls, 0);
      await cubit.close();
    });
  });

  group('dialog', () {
    Future<List<int>> pump(WidgetTester tester, CheckInGuestEntity guest, {DoorGate? gate}) async {
      final confirmed = <int>[];
      await tester.runAsync(() async {
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ar'),
            supportedLocales: AppLocalizationsSetup.supportedLocales,
            localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
            home: Scaffold(
              body: GuestVerifiedDialog(guest: guest, gate: gate, onClose: () {}, onCheckIn: confirmed.add),
            ),
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pumpAndSettle();
      return confirmed;
    }

    testWidgets('blocked offline: shows the translated reason and no confirm', (tester) async {
      await pump(tester, guestEntity(canCheckIn: false, blockerCode: 'qr_expired'));
      expect(find.text('انتهت صلاحية الدعوة'), findsOneWidget);
      expect(find.byKey(const Key('scanner_confirm_check_in')), findsNothing);
    });

    testWidgets('declined: warns but allows; picker stops at max', (tester) async {
      final confirmed = await pump(tester, guestEntity(max: 2, declined: true));
      expect(find.byKey(const Key('scanner_declined_warning')), findsOneWidget);

      final value = tester.widget<Text>(find.byKey(const Key('scanner_companions_value')));
      expect(value.data, '2');
      final plus = tester.widget<IconButton>(find.byKey(const Key('scanner_companions_plus')));
      expect(plus.onPressed, isNull, reason: 'already at max');

      await tester.tap(find.byKey(const Key('scanner_companions_minus')));
      await tester.pump();
      await tester.ensureVisible(find.byKey(const Key('scanner_confirm_check_in')));
      await tester.tap(find.byKey(const Key('scanner_confirm_check_in')));
      expect(confirmed, [1]);
    });

    testWidgets('a returning guest: welcome back with the first entry, nothing to confirm', (tester) async {
      var closed = false;
      await tester.runAsync(() async {
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ar'),
            supportedLocales: AppLocalizationsSetup.supportedLocales,
            localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
            home: Scaffold(
              body: ReturningGuestDialog(guest: guestEntity(already: true), onClose: () => closed = true),
            ),
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pumpAndSettle();

      expect(find.text('رجوع للقاعة ✓'), findsOneWidget);
      expect(find.byKey(const Key('door_returning_first')), findsOneWidget);
      expect(find.text('سارة'), findsOneWidget);
      expect(find.byKey(const Key('scanner_confirm_check_in')), findsNothing);
      await tester.tap(find.byKey(const Key('door_returning_ok')));
      expect(closed, isTrue);
    });

    testWidgets('a woman at the men\'s gate: warns, never blocks', (tester) async {
      await pump(
        tester,
        guestEntity(warnings: ['wrong_gate']),
        gate: const DoorGate(id: 1, name: 'رجال ١', audience: 'men'),
      );
      expect(find.byKey(const Key('scanner_warning_wrong_gate')), findsOneWidget);
      expect(find.text('هذه البوابة مخصصة لـالرجال'), findsOneWidget);
      expect(find.byKey(const Key('scanner_confirm_check_in')), findsOneWidget);
    });
  });

  group('event door statistics', () {
    test('merges checked_in / attendees from /statistics', () {
      final merged = EventsRemoteDataSourceImpl.mergeDoorStatistics({
        'checked_in': 4,
        'checked_in_companions': 3,
        'attendees': 7,
        'sent': 9,
      });
      expect(merged, {'checked_in': 4, 'checked_in_companions': 3, 'attendees': 7});

      final e = EventModel.fromJson({'id': 1, 'title': 'x', 'status': 'active', ...merged});
      expect(e.checkedIn, 4);
      expect(e.checkedInCompanions, 3);
      expect(e.attendees, 7);
    });
  });
}
