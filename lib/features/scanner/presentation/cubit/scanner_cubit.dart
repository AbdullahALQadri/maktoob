import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
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

  /// Load initial guest list
  Future<void> loadGuestList() async {
    final result = await getGuestListUseCase(const GetGuestListParams());

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

  /// Simulate QR code scanning (legacy method for testing)
  Future<void> startScanning() async {
    emit(Scanning(
      guests: _currentGuests,
      searchQuery: _currentSearchQuery,
    ));

    final scanResult = await scanQrCodeUseCase(const NoParams());

    await scanResult.fold(
      (failure) async {
        emit(ScannerError(
          message: failure.message ?? 'Scan failed',
          guests: _currentGuests,
          searchQuery: _currentSearchQuery,
        ));
      },
      (result) async {
        if (result.guestId != null) {
          // Get the guest details
          final guestResult = await getGuestListUseCase(const GetGuestListParams());

          guestResult.fold(
            (failure) => emit(ScannerError(
              message: failure.message ?? 'Failed to get guest details',
              guests: _currentGuests,
              searchQuery: _currentSearchQuery,
            )),
            (guests) {
              _currentGuests = guests;
              final guest = guests.firstWhere(
                (g) => g.id == result.guestId,
                orElse: () => throw Exception('Guest not found'),
              );
              emit(GuestScanned(
                guest: guest,
                guests: _currentGuests,
                searchQuery: _currentSearchQuery,
              ));
            },
          );
        } else {
          emit(ScannerError(
            message: 'Invalid QR code',
            guests: _currentGuests,
            searchQuery: _currentSearchQuery,
          ));
        }
      },
    );
  }

  /// Process a QR code scanned from the camera
  Future<void> processQRCode(String qrCode) async {
    emit(Scanning(
      guests: _currentGuests,
      searchQuery: _currentSearchQuery,
    ));

    // Try to extract guest ID from QR code
    // QR code format could be: "guest_id:123" or just "123" or a JSON string
    String? guestId;

    try {
      // Try to parse as simple ID
      if (qrCode.contains(':')) {
        guestId = qrCode.split(':').last.trim();
      } else if (qrCode.startsWith('{')) {
        // Try to parse as JSON (basic parsing)
        final match = RegExp(r'"(?:guest_id|id|guestId)":\s*"?(\w+)"?').firstMatch(qrCode);
        guestId = match?.group(1);
      } else {
        // Assume the QR code is the guest ID itself
        guestId = qrCode.trim();
      }
    } catch (e) {
      guestId = qrCode.trim();
    }

    if (guestId == null || guestId.isEmpty) {
      emit(ScannerError(
        message: 'Invalid QR code format',
        guests: _currentGuests,
        searchQuery: _currentSearchQuery,
      ));
      return;
    }

    // Find the guest in the current list
    final guestIndex = _currentGuests.indexWhere((g) => g.id == guestId);

    if (guestIndex != -1) {
      final guest = _currentGuests[guestIndex];
      emit(GuestScanned(
        guest: guest,
        guests: _currentGuests,
        searchQuery: _currentSearchQuery,
      ));
    } else {
      // Guest not found in local list, try to fetch from server
      final guestResult = await getGuestListUseCase(const GetGuestListParams());

      guestResult.fold(
        (failure) => emit(ScannerError(
          message: 'Guest not found',
          guests: _currentGuests,
          searchQuery: _currentSearchQuery,
        )),
        (guests) {
          _currentGuests = guests;
          final foundIndex = guests.indexWhere((g) => g.id == guestId);

          if (foundIndex != -1) {
            emit(GuestScanned(
              guest: guests[foundIndex],
              guests: _currentGuests,
              searchQuery: _currentSearchQuery,
            ));
          } else {
            emit(ScannerError(
              message: 'Guest not found in the system',
              guests: _currentGuests,
              searchQuery: _currentSearchQuery,
            ));
          }
        },
      );
    }
  }

  /// Check in a guest
  Future<void> checkInGuest(String guestId) async {
    final result = await checkInGuestUseCase(
      CheckInGuestParams(guestId: guestId),
    );

    result.fold(
      (failure) => emit(ScannerError(
        message: failure.message ?? 'Check-in failed',
        guests: _currentGuests,
        searchQuery: _currentSearchQuery,
      )),
      (checkedInGuest) async {
        // Update local guest list
        _currentGuests = _currentGuests.map((g) {
          if (g.id == guestId) {
            return checkedInGuest;
          }
          return g;
        }).toList();

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

  /// Reset to initial state
  void resetToInitial() {
    emit(ScannerInitial(
      guests: _currentGuests,
      searchQuery: _currentSearchQuery,
    ));
  }

  /// Clear scanned guest and return to initial
  void clearScannedGuest() {
    emit(ScannerInitial(
      guests: _currentGuests,
      searchQuery: _currentSearchQuery,
    ));
  }
}
