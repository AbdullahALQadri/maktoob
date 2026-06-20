import 'package:flutter_bloc/flutter_bloc.dart';

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
  int? _venueId;

  /// The scanner scans guests for a specific venue (the selected event's
  /// venue). Must be set before scanning / loading the list.
  void setVenue(int? venueId) {
    _venueId = venueId;
  }

  /// Load the attendance list for the selected venue.
  Future<void> loadGuestList() async {
    final venueId = _venueId;
    if (venueId == null) {
      // Venue not resolved yet (e.g. event has no venue) — nothing to load.
      emit(ScannerInitial(guests: _currentGuests, searchQuery: _currentSearchQuery));
      return;
    }

    final result = await getGuestListUseCase(
      GetGuestListParams(venueId: venueId, searchQuery: _currentSearchQuery),
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
    final venueId = _venueId;
    if (venueId == null) {
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
      ScanQrCodeParams(qrData: qrCode, venueId: venueId),
    );

    scanResult.fold(
      (failure) => emit(ScannerError(
        message: failure.message ?? 'Scan failed',
        guests: _currentGuests,
        searchQuery: _currentSearchQuery,
      )),
      // The scan endpoint returns the full invitation, so emit it directly.
      (guest) => emit(GuestScanned(
        guest: guest,
        guests: _currentGuests,
        searchQuery: _currentSearchQuery,
      )),
    );
  }

  /// Check in a guest (by invitation id)
  Future<void> checkInGuest(String invitationId) async {
    final venueId = _venueId;
    if (venueId == null) {
      emit(ScannerError(
        message: 'No venue selected for this scanner session',
        guests: _currentGuests,
        searchQuery: _currentSearchQuery,
      ));
      return;
    }

    final result = await checkInGuestUseCase(
      CheckInGuestParams(invitationId: invitationId, venueId: venueId),
    );

    result.fold(
      (failure) => emit(ScannerError(
        message: failure.message ?? 'Check-in failed',
        guests: _currentGuests,
        searchQuery: _currentSearchQuery,
      )),
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
