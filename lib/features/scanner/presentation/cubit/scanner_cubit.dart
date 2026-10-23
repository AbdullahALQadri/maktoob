import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';

import '../../domain/entities/check_in_guest_entity.dart';
import '../../domain/usecases/check_in_guest_usecase.dart';
import '../../domain/usecases/get_guest_list_usecase.dart';
import '../../domain/usecases/scan_qr_code_usecase.dart';
import 'scanner_state.dart';

class ScannerCubit extends Cubit<ScannerState> {
  final ScanQrCodeUseCase scanQrCodeUseCase;
  final CheckInGuestUseCase checkInGuestUseCase;
  final GetGuestListUseCase getGuestListUseCase;

  ScannerCubit({
    required this.scanQrCodeUseCase,
    required this.checkInGuestUseCase,
    required this.getGuestListUseCase,
  }) : super(const ScannerInitial());

  List<CheckInGuestEntity> _currentGuests = [];
  String _currentSearchQuery = '';
  int? _eventId;

  /// The guest from the last successful scan (for the 409 "already in" view).
  CheckInGuestEntity? _lastScanned;

  /// The host scans guests of one of their own events (owner endpoints, the
  /// client token). Must be set before scanning / loading the list.
  void setEvent(int? eventId) {
    _eventId = eventId;
  }

  /// Load the check-in roster for the selected event.
  Future<void> loadGuestList() async {
    final eventId = _eventId;
    if (eventId == null) {
      // Event not resolved yet — nothing to load.
      emit(ScannerInitial(guests: _currentGuests, searchQuery: _currentSearchQuery));
      return;
    }

    final result = await getGuestListUseCase(
      GetGuestListParams(eventId: eventId, searchQuery: _currentSearchQuery),
    );

    result.fold(
      (failure) => emit(ScannerError(
        message: failure.message ?? 'Failed to load guest list',
        guests: _currentGuests,
        searchQuery: _currentSearchQuery,
      )),
      (guests) {
        _currentGuests = guests;
        emit(ScannerInitial(
          guests: _currentGuests,
          searchQuery: _currentSearchQuery,
        ));
      },
    );
  }

  /// Process a QR code scanned from the camera
  Future<void> processQRCode(String qrCode) async {
    final eventId = _eventId;
    if (eventId == null) {
      emit(ScannerError(
        message: 'No venue selected for this scanner session',
        guests: _currentGuests,
        searchQuery: _currentSearchQuery,
      ));
      return;
    }

    emit(Scanning(
      guests: _currentGuests,
      searchQuery: _currentSearchQuery,
    ));

    final scanResult = await scanQrCodeUseCase(
      ScanQrCodeParams(qrData: qrCode, eventId: eventId),
    );

    scanResult.fold(
      (failure) => emit(ScannerError(
        message: failure.message ?? 'Scan failed',
        guests: _currentGuests,
        searchQuery: _currentSearchQuery,
      )),
      // The scan endpoint returns the full invitation, so emit it directly.
      (guest) {
        _lastScanned = guest;
        emit(GuestScanned(
          guest: guest,
          guests: _currentGuests,
          searchQuery: _currentSearchQuery,
        ));
      },
    );
  }

  /// Check in a guest (by invitation id) with [companions] at the door.
  ///
  /// A guest whose scan said `can_check_in: false` is refused locally with
  /// the server's blocker message (no request is sent).
  Future<void> checkInGuest(String invitationId, {int? companions}) async {
    final scanned = _lastScanned?.id == invitationId ? _lastScanned : null;
    if (scanned != null && !scanned.canCheckIn) {
      emit(ScannerError(
        message: scanned.blockerMessage ?? 'Check-in is not available',
        guests: _currentGuests,
        searchQuery: _currentSearchQuery,
      ));
      return;
    }

    final eventId = _eventId;
    if (eventId == null) {
      emit(ScannerError(
        message: 'No venue selected for this scanner session',
        guests: _currentGuests,
        searchQuery: _currentSearchQuery,
      ));
      return;
    }

    final result = await checkInGuestUseCase(
      CheckInGuestParams(
        invitationId: invitationId,
        eventId: eventId,
        actualCompanions: companions,
      ),
    );

    result.fold(
      (failure) {
        if (failure is AlreadyCheckedInFailure) {
          final known = scanned ??
              CheckInGuestEntity(
                id: invitationId,
                name: '',
                status: 'checked_in',
                companions: 0,
                checkedIn: true,
                qrCode: '',
              );
          emit(GuestAlreadyCheckedIn(
            guest: known.copyWith(checkedIn: true),
            message: failure.message ?? '',
            guests: _currentGuests,
            searchQuery: _currentSearchQuery,
          ));
          return;
        }
        // 422 event_not_active / too_many_companions: the server's message.
        emit(ScannerError(
          message: failure.message ?? 'Check-in failed',
          guests: _currentGuests,
          searchQuery: _currentSearchQuery,
        ));
      },
      (checkedInGuest) {
        // Merge into the local attendance list (replace or append).
        final idx = _currentGuests.indexWhere((g) => g.id == invitationId);
        if (idx != -1) {
          _currentGuests = List.of(_currentGuests)..[idx] = checkedInGuest;
        } else {
          _currentGuests = [..._currentGuests, checkedInGuest];
        }

        emit(GuestCheckedIn(
          guest: checkedInGuest,
          guests: _currentGuests,
          searchQuery: _currentSearchQuery,
        ));
      },
    );
  }

  int _kioskSeq = 0;

  /// Self-service kiosk: scan and, if allowed, check in immediately with the
  /// guest's RSVP companions capped at max_companions (no picker). Always
  /// ends in a [KioskResult]. An empty [message] on refusal means "already
  /// entered" (the UI shows its own text with [KioskResult.checkedInAt]).
  Future<void> kioskScan(String qrCode) async {
    final eventId = _eventId;
    if (eventId == null) {
      emit(KioskResult(admitted: false, seq: ++_kioskSeq, message: 'No venue selected for this scanner session'));
      return;
    }

    final scanResult = await scanQrCodeUseCase(
      ScanQrCodeParams(qrData: qrCode, eventId: eventId),
    );

    final guest = scanResult.fold((_) => null, (g) => g);
    if (guest == null) {
      final failure = scanResult.fold((f) => f, (_) => null);
      emit(KioskResult(admitted: false, seq: ++_kioskSeq, message: failure?.message ?? 'Scan failed'));
      return;
    }
    _lastScanned = guest;

    if (guest.checkedIn) {
      emit(KioskResult(admitted: false, seq: ++_kioskSeq, name: guest.name, checkedInAt: guest.checkedInAt));
      return;
    }
    if (!guest.canCheckIn) {
      emit(KioskResult(
        admitted: false,
        seq: ++_kioskSeq,
        name: guest.name,
        message: guest.blockerMessage ?? 'Check-in is not available',
      ));
      return;
    }

    final companions = guest.defaultCompanions;
    final result = await checkInGuestUseCase(
      CheckInGuestParams(invitationId: guest.id, eventId: eventId, actualCompanions: companions),
    );

    result.fold(
      (failure) => emit(KioskResult(
        admitted: false,
        seq: ++_kioskSeq,
        name: guest.name,
        // 409 → "already entered" view; anything else → the server message.
        message: failure is AlreadyCheckedInFailure ? '' : (failure.message ?? 'Check-in failed'),
        checkedInAt: guest.checkedInAt,
      )),
      (checkedIn) {
        final idx = _currentGuests.indexWhere((g) => g.id == guest.id);
        _currentGuests = idx != -1
            ? (List.of(_currentGuests)..[idx] = checkedIn)
            : [..._currentGuests, checkedIn];
        emit(KioskResult(admitted: true, seq: ++_kioskSeq, name: guest.name, companions: companions));
      },
    );
  }

  /// Update search query and filter guests
  void updateSearchQuery(String query) {
    _currentSearchQuery = query;

    final currentState = state;
    if (currentState is ScannerInitial) {
      emit(currentState.copyWith(searchQuery: query));
    } else {
      emit(ScannerInitial(
        guests: _currentGuests,
        searchQuery: query,
      ));
    }
  }

  /// Clear scanned guest and return to initial
  void clearScannedGuest() {
    emit(ScannerInitial(
      guests: _currentGuests,
      searchQuery: _currentSearchQuery,
    ));
  }
}
