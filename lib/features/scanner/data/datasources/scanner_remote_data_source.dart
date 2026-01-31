import 'dart:math';

import '../models/check_in_guest_model.dart';
import '../models/scan_result_model.dart';

abstract class ScannerRemoteDataSource {
  /// Simulates scanning a QR code and returns a random guest
  Future<ScanResultModel> scanQrCode();

  /// Checks in a guest by their ID
  Future<CheckInGuestModel> checkInGuest(String guestId);

  /// Gets the list of all guests with optional search filter
  Future<List<CheckInGuestModel>> getGuestList({String? searchQuery});

  /// Gets a specific guest by ID
  Future<CheckInGuestModel> getGuestById(String guestId);
}

class ScannerRemoteDataSourceImpl implements ScannerRemoteDataSource {
  // TODO: Replace with actual API data
  final List<CheckInGuestModel> _mockGuests = [];

  // Map to track checked-in status
  final Map<String, bool> _checkedInStatus = {};

  ScannerRemoteDataSourceImpl();

  @override
  Future<ScanResultModel> scanQrCode() async {
    // Simulate network delay for scanning (reduced for better UX)
    await Future.delayed(const Duration(milliseconds: 800));

    // Select a random guest
    final random = Random();
    final randomGuest = _mockGuests[random.nextInt(_mockGuests.length)];

    return ScanResultModel(
      qrCode: randomGuest.qrCode,
      isValid: true,
      guestId: randomGuest.id,
    );
  }

  @override
  Future<CheckInGuestModel> checkInGuest(String guestId) async {
    // Simulate network delay (reduced for better performance)
    await Future.delayed(const Duration(milliseconds: 150));

    final guestIndex = _mockGuests.indexWhere((g) => g.id == guestId);

    if (guestIndex == -1) {
      throw Exception('Guest not found');
    }

    // Update the checked-in status
    _checkedInStatus[guestId] = true;

    // Return updated guest model
    return _mockGuests[guestIndex].copyWith(checkedIn: true);
  }

  @override
  Future<List<CheckInGuestModel>> getGuestList({String? searchQuery}) async {
    // Simulate network delay (reduced for better performance)
    await Future.delayed(const Duration(milliseconds: 150));

    // Get guests with current checked-in status
    List<CheckInGuestModel> guests = _mockGuests.map((guest) {
      return guest.copyWith(
        checkedIn: _checkedInStatus[guest.id] ?? guest.checkedIn,
      );
    }).toList();

    // Apply search filter if provided
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      guests = guests.where((guest) {
        return guest.name.toLowerCase().contains(query) ||
            guest.qrCode.toLowerCase().contains(query);
      }).toList();
    }

    return guests;
  }

  @override
  Future<CheckInGuestModel> getGuestById(String guestId) async {
    // Simulate network delay (reduced for better performance)
    await Future.delayed(const Duration(milliseconds: 100));

    final guest = _mockGuests.firstWhere(
      (g) => g.id == guestId,
      orElse: () => throw Exception('Guest not found'),
    );

    return guest.copyWith(
      checkedIn: _checkedInStatus[guestId] ?? guest.checkedIn,
    );
  }
}
