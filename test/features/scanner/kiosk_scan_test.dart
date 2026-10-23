import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/core/error/exceptions.dart';
import 'package:maktoob/features/scanner/data/datasources/scanner_remote_data_source.dart';
import 'package:maktoob/features/scanner/data/models/check_in_guest_model.dart';
import 'package:maktoob/features/scanner/data/repositories/scanner_repository_impl.dart';
import 'package:maktoob/features/scanner/domain/usecases/check_in_guest_usecase.dart';
import 'package:maktoob/features/scanner/domain/usecases/get_guest_list_usecase.dart';
import 'package:maktoob/features/scanner/domain/usecases/scan_qr_code_usecase.dart';
import 'package:maktoob/features/scanner/presentation/cubit/scanner_cubit.dart';
import 'package:maktoob/features/scanner/presentation/cubit/scanner_state.dart';

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
  group('kiosk mode', () {
    test('auto-checks in with RSVP companions capped at max', () async {
      final src = _FakeSource()..scanPayload = _scan(max: 2);
      final cubit = _cubit(src);
      await cubit.kioskScan('qr');

      expect(src.checkInCalls, 1);
      expect(src.sentCompanions, 2, reason: 'RSVP 3 capped at max 2');
      final s = cubit.state as KioskResult;
      expect(s.admitted, isTrue);
      expect(s.name, 'سارة');
      expect(s.companions, 2);
      await cubit.close();
    });

    test('a blocked QR (not yet valid / expired) is refused without a request', () async {
      final src = _FakeSource()..scanPayload = _scan(canCheckIn: false, blocker: 'الدعوة صالحة يوم 20/11/2026');
      final cubit = _cubit(src);
      await cubit.kioskScan('qr');

      expect(src.checkInCalls, 0);
      final s = cubit.state as KioskResult;
      expect(s.admitted, isFalse);
      expect(s.message, 'الدعوة صالحة يوم 20/11/2026');
      await cubit.close();
    });

    test('an already-entered guest shows "already in" with the time', () async {
      final src = _FakeSource()..scanPayload = _scan(already: true);
      final cubit = _cubit(src);
      await cubit.kioskScan('qr');

      expect(src.checkInCalls, 0);
      final s = cubit.state as KioskResult;
      expect(s.admitted, isFalse);
      expect(s.message, isEmpty);
      expect(s.checkedInAt, isNotNull);
      await cubit.close();
    });

    test('a 409 race also maps to "already in"', () async {
      final src = _FakeSource()
        ..checkInError = const ConflictException(message: 'Guest is already checked in.');
      final cubit = _cubit(src);
      await cubit.kioskScan('qr');

      final s = cubit.state as KioskResult;
      expect(s.admitted, isFalse);
      expect(s.message, isEmpty);
      await cubit.close();
    });
  });
}
