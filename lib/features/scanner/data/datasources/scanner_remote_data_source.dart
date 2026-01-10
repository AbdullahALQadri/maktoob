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
  // Mock guest data storage (simulating a remote database)
  final List<CheckInGuestModel> _mockGuests = [
    const CheckInGuestModel(
      id: '1',
      name: 'John Smith',
      status: 'VIP',
      companions: 2,
      checkedIn: false,
      qrCode: 'QR001',
    ),
    const CheckInGuestModel(
      id: '2',
      name: 'Sarah Johnson',
      status: 'Regular',
      companions: 0,
      checkedIn: true,
      qrCode: 'QR002',
    ),
    const CheckInGuestModel(
      id: '3',
      name: 'Michael Brown',
      status: 'VIP',
      companions: 1,
      checkedIn: false,
      qrCode: 'QR003',
    ),
    const CheckInGuestModel(
      id: '4',
      name: 'Emily Davis',
      status: 'Regular',
      companions: 3,
      checkedIn: true,
      qrCode: 'QR004',
    ),
    const CheckInGuestModel(
      id: '5',
      name: 'David Wilson',
      status: 'VIP',
      companions: 0,
      checkedIn: false,
      qrCode: 'QR005',
    ),
    const CheckInGuestModel(
      id: '6',
      name: 'Jessica Martinez',
      status: 'Regular',
      companions: 1,
      checkedIn: false,
      qrCode: 'QR006',
    ),
    const CheckInGuestModel(
      id: '7',
      name: 'Christopher Lee',
      status: 'VIP',
      companions: 2,
      checkedIn: true,
      qrCode: 'QR007',
    ),
    const CheckInGuestModel(
      id: '8',
      name: 'Amanda Taylor',
      status: 'Regular',
      companions: 0,
      checkedIn: false,
      qrCode: 'QR008',
    ),
  ];

  // Map to track checked-in status (mutable state for simulation)
  final Map<String, bool> _checkedInStatus = {};

  ScannerRemoteDataSourceImpl() {
    // Initialize checked-in status from mock data
    for (final guest in _mockGuests) {
      _checkedInStatus[guest.id] = guest.checkedIn;
    }
  }

  @override
  Future<ScanResultModel> scanQrCode() async {
    // Simulate network delay for scanning
    await Future.delayed(const Duration(seconds: 2));

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
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

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
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

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
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    final guest = _mockGuests.firstWhere(
      (g) => g.id == guestId,
      orElse: () => throw Exception('Guest not found'),
    );

    return guest.copyWith(
      checkedIn: _checkedInStatus[guestId] ?? guest.checkedIn,
    );
  }
}
