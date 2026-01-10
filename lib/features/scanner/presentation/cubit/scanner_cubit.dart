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

  /// Simulate QR code scanning
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
