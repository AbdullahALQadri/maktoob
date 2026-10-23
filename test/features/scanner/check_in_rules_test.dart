import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/config/locale/app_localizations_setup.dart';
import 'package:maktoob/core/error/exceptions.dart';
import 'package:maktoob/features/events/data/datasources/events_remote_data_source.dart';
import 'package:maktoob/features/events/data/models/event_model.dart';
import 'package:maktoob/features/scanner/data/datasources/scanner_remote_data_source.dart';
import 'package:maktoob/features/scanner/data/models/check_in_guest_model.dart';
import 'package:maktoob/features/scanner/data/repositories/scanner_repository_impl.dart';
import 'package:maktoob/features/scanner/domain/usecases/check_in_guest_usecase.dart';
import 'package:maktoob/features/scanner/domain/usecases/get_guest_list_usecase.dart';
import 'package:maktoob/features/scanner/domain/usecases/scan_qr_code_usecase.dart';
import 'package:maktoob/features/scanner/presentation/cubit/scanner_cubit.dart';
import 'package:maktoob/features/scanner/presentation/cubit/scanner_state.dart';
import 'package:maktoob/features/scanner/presentation/widgets/guest_verified_dialog.dart';

Map<String, dynamic> _scan({
  bool canCheckIn = true,
  String? blocker,
  int? max,
  bool declined = false,
  bool already = false,
}) =>
    {
      'id': 7,
      'guest_name': 'سارة',
      'response_status': declined ? 'not_attending' : 'attending',
      'expected_companions': 3,
      'already_checked_in': already,
      'last_check_in': already ? {'checked_in_at': '2026-10-10T17:05:00Z'} : null,
      'event_status': canCheckIn ? 'active' : 'completed',
      'can_check_in': canCheckIn,
      'blocker': canCheckIn ? null : 'event_not_active',
      'blocker_message': blocker,
      'max_companions': max,
      'declined_rsvp': declined,
      'warning': declined ? 'This guest declined the invitation (not attending).' : null,
    };

class _FakeSource implements ScannerRemoteDataSource {
  Map<String, dynamic> scanPayload = _scan();
  Object? checkInError;
  int? sentCompanions;
  int checkInCalls = 0;

  @override
  Future<CheckInGuestModel> scanQrCode(String qrCode, int eventId) async =>
      CheckInGuestModel.fromInvitationJson(scanPayload, qrCode: qrCode);

  @override
  Future<CheckInGuestModel> checkInGuest(String invitationId, int eventId,
      {int? actualCompanions, String? notes}) async {
    checkInCalls++;
    sentCompanions = actualCompanions;
    if (checkInError != null) throw checkInError!;
    return CheckInGuestModel.fromCheckInResponse(
      {
        'success': true,
        'warning': scanPayload['warning'],
        'declined_rsvp': scanPayload['declined_rsvp'],
        'data': {
          'attendance_log': {
            'guest_name': 'سارة',
            'actual_companions': actualCompanions,
            'checked_in_at': '2026-10-10T18:00:00Z',
          },
        },
      },
      invitationId: invitationId,
      requestedCompanions: actualCompanions,
    );
  }

  @override
  Future<List<CheckInGuestModel>> getGuestList(int eventId, {String? searchQuery}) async => [];
}

ScannerCubit _cubit(_FakeSource src) {
  final repo = ScannerRepositoryImpl(remoteDataSource: src);
  return ScannerCubit(
    scanQrCodeUseCase: ScanQrCodeUseCase(repo),
    checkInGuestUseCase: CheckInGuestUseCase(repo),
    getGuestListUseCase: GetGuestListUseCase(repo),
  )..setEvent(1);
}

void main() {
  group('scan payload', () {
    test('parses the new check-in flags', () {
      final g = CheckInGuestModel.fromInvitationJson(
        _scan(canCheckIn: false, blocker: 'الفعالية غير نشطة', max: 2, declined: true),
      );
      expect(g.canCheckIn, isFalse);
      expect(g.blockerMessage, 'الفعالية غير نشطة');
      expect(g.maxCompanions, 2);
      expect(g.declinedRsvp, isTrue);
      expect(g.warning, isNotNull);
      expect(g.defaultCompanions, 2, reason: 'RSVP 3 capped at max 2');
    });

    test('older payloads without flags still allow check-in', () {
      final g = CheckInGuestModel.fromInvitationJson({'id': 1, 'guest_name': 'x'});
      expect(g.canCheckIn, isTrue);
      expect(g.maxCompanions, isNull);
    });
  });

  group('cubit', () {
    test('a blocked guest is refused locally with the blocker message', () async {
      final src = _FakeSource()..scanPayload = _scan(canCheckIn: false, blocker: 'الفعالية انتهت');
      final cubit = _cubit(src);
      await cubit.processQRCode('qr');
      await cubit.checkInGuest('7', companions: 0);

      expect(src.checkInCalls, 0);
      expect((cubit.state as ScannerError).message, 'الفعالية انتهت');
      await cubit.close();
    });

    test('sends the chosen companions; a declined RSVP succeeds with a warning', () async {
      final src = _FakeSource()..scanPayload = _scan(max: 2, declined: true);
      final cubit = _cubit(src);
      await cubit.processQRCode('qr');
      await cubit.checkInGuest('7', companions: 2);

      expect(src.sentCompanions, 2);
      final s = cubit.state as GuestCheckedIn;
      expect(s.guest.declinedRsvp, isTrue);
      expect(s.guest.warning, isNotNull);
      await cubit.close();
    });

    test('409 becomes the friendly "already in" state with the scan time', () async {
      final src = _FakeSource()
        ..scanPayload = _scan(already: true)
        ..checkInError = const ConflictException(message: 'Guest is already checked in.');
      final cubit = _cubit(src);
      await cubit.processQRCode('qr');
      await cubit.checkInGuest('7');

      final s = cubit.state as GuestAlreadyCheckedIn;
      expect(s.guest.name, 'سارة');
      expect(s.guest.checkedInAt, DateTime.utc(2026, 10, 10, 17, 5));
      await cubit.close();
    });

    test('422 shows the server message', () async {
      final src = _FakeSource()
        ..checkInError = const ValidationException(message: 'عدد المرافقين أكبر من المسموح (2).', code: 422);
      final cubit = _cubit(src);
      await cubit.processQRCode('qr');
      await cubit.checkInGuest('7', companions: 3);

      expect(cubit.state, isNot(isA<GuestAlreadyCheckedIn>()));
      expect((cubit.state as ScannerError).message, 'عدد المرافقين أكبر من المسموح (2).');
      await cubit.close();
    });
  });

  group('dialog', () {
    Future<List<int>> pump(WidgetTester tester, CheckInGuestModel guest) async {
      final confirmed = <int>[];
      await tester.runAsync(() async {
        await tester.pumpWidget(MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: AppLocalizationsSetup.supportedLocales,
          localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
          home: Scaffold(
            body: GuestVerifiedDialog(guest: guest, onClose: () {}, onCheckIn: confirmed.add),
          ),
        ));
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pumpAndSettle();
      return confirmed;
    }

    testWidgets('blocked: shows the message and no confirm', (tester) async {
      await pump(
        tester,
        CheckInGuestModel.fromInvitationJson(_scan(canCheckIn: false, blocker: 'الفعالية انتهت')),
      );
      expect(find.text('الفعالية انتهت'), findsOneWidget);
      expect(find.byKey(const Key('scanner_confirm_check_in')), findsNothing);
    });

    testWidgets('declined: warns but allows; picker stops at max', (tester) async {
      final confirmed =
          await pump(tester, CheckInGuestModel.fromInvitationJson(_scan(max: 2, declined: true)));
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
  });

  group('event door statistics', () {
    test('merges checked_in / attendees from /statistics', () {
      final merged = EventsRemoteDataSourceImpl.mergeDoorStatistics(
        {'checked_in': 4, 'checked_in_companions': 3, 'attendees': 7, 'sent': 9},
      );
      expect(merged, {'checked_in': 4, 'checked_in_companions': 3, 'attendees': 7});

      final e = EventModel.fromJson({'id': 1, 'title': 'x', 'status': 'active', ...merged});
      expect(e.checkedIn, 4);
      expect(e.checkedInCompanions, 3);
      expect(e.attendees, 7);
    });
  });
}
