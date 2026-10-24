import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/check_in_guest_entity.dart';
import '../../domain/entities/door_entities.dart';
import '../../domain/repositories/scanner_repository.dart';
import '../../domain/usecases/check_in_guest_usecase.dart';
import '../../domain/usecases/get_guest_list_usecase.dart';
import '../../domain/usecases/scan_qr_code_usecase.dart';
import 'scanner_state.dart';

/// The door screen. Works with no internet: the scan is answered from the
/// downloaded guest list, the check-in is decided by the server when it is
/// reachable, else by the venue hub, else by this phone, and kept until
/// uploaded. Other doors' check-ins arrive through the status stream.
class ScannerCubit extends Cubit<ScannerState> {
  final ScannerRepository repository;
  final ScanQrCodeUseCase scanQrCodeUseCase;
  final CheckInGuestUseCase checkInGuestUseCase;
  final GetGuestListUseCase getGuestListUseCase;

  ScannerCubit({
    required this.repository,
    required this.scanQrCodeUseCase,
    required this.checkInGuestUseCase,
    required this.getGuestListUseCase,
  }) : super(const ScannerInitial());

  List<CheckInGuestEntity> _currentGuests = [];
  String _currentSearchQuery = '';
  StreamSubscription<DoorStatus>? _statusSub;
  Timer? _reload;
  int _seenCheckedIn = -1;
  int _seenGuests = -1;
  bool _open = false;

  /// The guest from the last successful scan (for the "already in" view).
  CheckInGuestEntity? _lastScanned;

  int _kioskSeq = 0;

  /// Opens the door for [session] and loads the list from the phone.
  Future<void> openSession(DoorSession session) async {
    _open = true;
    _statusSub ??= repository.statusStream.listen(_onStatus);
    await repository.open(session);
    await loadGuestList();
  }

  void _onStatus(DoorStatus s) {
    // Someone came in at another door, or the list was downloaded again.
    if (s.checkedIn == _seenCheckedIn && s.guests == _seenGuests) return;
    _seenCheckedIn = s.checkedIn;
    _seenGuests = s.guests;
    _reload?.cancel();
    _reload = Timer(const Duration(milliseconds: 400), () {
      final current = state;
      if (current is ScannerInitial || current is GuestCheckedIn || current is ScannerError) {
        unawaited(loadGuestList());
      }
    });
  }

  /// Load the check-in roster for the open event (from the phone).
  Future<void> loadGuestList() async {
    if (!_open || isClosed) return;
    final result = await getGuestListUseCase(GetGuestListParams(searchQuery: _currentSearchQuery));
    if (isClosed) return;
    result.fold(
      (failure) =>
          emit(ScannerError(message: failure.message ?? '', guests: _currentGuests, searchQuery: _currentSearchQuery)),
      (guests) {
        _currentGuests = guests;
        emit(ScannerInitial(guests: _currentGuests, searchQuery: _currentSearchQuery));
      },
    );
  }

  ScannerError _error(Failure failure) => ScannerError(
    message: failure.message ?? '',
    code: failure is DoorRefusedFailure ? failure.reason : null,
    maxCompanions: failure is DoorRefusedFailure ? failure.maxCompanions : null,
    guests: _currentGuests,
    searchQuery: _currentSearchQuery,
  );

  /// Process a QR code scanned from the camera
  Future<void> processQRCode(String qrCode) async {
    emit(Scanning(guests: _currentGuests, searchQuery: _currentSearchQuery));
    final scanResult = await scanQrCodeUseCase(ScanQrCodeParams(qrData: qrCode));
    scanResult.fold((failure) => emit(_error(failure)), (guest) {
      _lastScanned = guest;
      emit(GuestScanned(guest: guest, guests: _currentGuests, searchQuery: _currentSearchQuery));
    });
  }

  /// Check in a guest (by invitation id) with [companions] at the door.
  /// [manual]: picked from the list. A scan that said the door refuses is
  /// refused here without asking anyone.
  Future<void> checkInGuest(String invitationId, {int? companions, bool manual = false}) async {
    final scanned = _lastScanned?.id == invitationId ? _lastScanned : null;
    if (scanned != null && !scanned.canCheckIn) {
      emit(
        ScannerError(
          message: scanned.blockerMessage ?? '',
          code: scanned.blockerCode,
          guests: _currentGuests,
          searchQuery: _currentSearchQuery,
        ),
      );
      return;
    }

    final result = await checkInGuestUseCase(
      CheckInGuestParams(
        invitationId: invitationId,
        actualCompanions: companions,
        manual: manual,
        maxCompanions: scanned?.unlisted == true ? scanned!.maxCompanions : null,
      ),
    );

    // A guest another door had let in comes back as admitted, `returning`.
    result.fold((failure) => emit(_error(failure)), (checkedIn) {
      final shown = scanned == null
          ? checkedIn
          : checkedIn.copyWith(name: checkedIn.name.isEmpty ? scanned.name : null);
      final idx = _currentGuests.indexWhere((g) => g.id == invitationId);
      _currentGuests = idx != -1 ? (List.of(_currentGuests)..[idx] = shown) : [..._currentGuests, shown];
      emit(GuestCheckedIn(guest: shown, guests: _currentGuests, searchQuery: _currentSearchQuery));
    });
  }

  /// Self-service kiosk: scan and, if allowed, check in immediately with the
  /// guest's RSVP companions capped at max_companions (no picker). Always
  /// ends in a [KioskResult].
  Future<void> kioskScan(String qrCode) async {
    final scanResult = await scanQrCodeUseCase(ScanQrCodeParams(qrData: qrCode));
    final guest = scanResult.fold((_) => null, (g) => g);
    if (guest == null) {
      final failure = scanResult.fold((f) => f, (_) => null);
      emit(
        KioskResult(
          admitted: false,
          seq: ++_kioskSeq,
          code: failure is DoorRefusedFailure ? failure.reason : 'not_found',
          message: failure?.message ?? '',
        ),
      );
      return;
    }
    _lastScanned = guest;

    if (!guest.canCheckIn) {
      emit(
        KioskResult(
          admitted: false,
          seq: ++_kioskSeq,
          name: guest.name,
          code: guest.blockerCode,
          message: guest.blockerMessage ?? '',
        ),
      );
      return;
    }
    // Already came in today (stepped out, came back): welcome back, nothing
    // is recorded again.
    if (guest.checkedIn) {
      emit(
        KioskResult(
          admitted: true,
          returning: true,
          seq: ++_kioskSeq,
          name: guest.name,
          checkedInAt: guest.checkedInAt,
          checkedInDevice: guest.checkedInDevice,
        ),
      );
      return;
    }

    final companions = guest.defaultCompanions;
    final result = await checkInGuestUseCase(
      CheckInGuestParams(
        invitationId: guest.id,
        actualCompanions: companions,
        maxCompanions: guest.unlisted ? guest.maxCompanions : null,
      ),
    );

    result.fold(
      (failure) => emit(
        KioskResult(
          admitted: false,
          seq: ++_kioskSeq,
          name: guest.name,
          code: failure is DoorRefusedFailure ? failure.reason : null,
          message: failure.message ?? '',
        ),
      ),
      (checkedIn) {
        final idx = _currentGuests.indexWhere((g) => g.id == guest.id);
        _currentGuests = idx != -1
            ? (List.of(_currentGuests)..[idx] = checkedIn.copyWith(name: guest.name))
            : [..._currentGuests, checkedIn];
        // Another door had let them in first: a return, shown as such.
        emit(
          KioskResult(
            admitted: true,
            returning: checkedIn.returning,
            seq: ++_kioskSeq,
            name: guest.name,
            companions: checkedIn.returning ? checkedIn.companions : companions,
            checkedInAt: checkedIn.returning ? checkedIn.checkedInAt : null,
            checkedInDevice: checkedIn.returning ? checkedIn.checkedInDevice : null,
            warnings: checkedIn.warnings,
          ),
        );
      },
    );
  }

  /// Update search query and filter guests (Arabic-tolerant, on the phone).
  void updateSearchQuery(String query) {
    _currentSearchQuery = query;
    unawaited(loadGuestList());
  }

  /// Clear scanned guest and return to initial
  void clearScannedGuest() {
    emit(ScannerInitial(guests: _currentGuests, searchQuery: _currentSearchQuery));
  }

  @override
  Future<void> close() async {
    _reload?.cancel();
    await _statusSub?.cancel();
    if (_open) await repository.close();
    return super.close();
  }
}
