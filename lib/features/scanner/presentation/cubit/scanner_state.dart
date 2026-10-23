import 'package:equatable/equatable.dart';

import '../../domain/entities/check_in_guest_entity.dart';

abstract class ScannerState extends Equatable {
  const ScannerState();

  @override
  List<Object?> get props => [];
}

/// Initial state when scanner is ready
class ScannerInitial extends ScannerState {
  final List<CheckInGuestEntity> guests;
  final String searchQuery;

  const ScannerInitial({
    this.guests = const [],
    this.searchQuery = '',
  });

  int get expectedGuests => guests.length;
  int get checkedInGuests => guests.where((g) => g.checkedIn).length;
  int get pendingGuests => guests.where((g) => !g.checkedIn).length;

  List<CheckInGuestEntity> get filteredGuests {
    if (searchQuery.isEmpty) return guests;
    return guests.where((guest) {
      return guest.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          guest.qrCode.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  ScannerInitial copyWith({
    List<CheckInGuestEntity>? guests,
    String? searchQuery,
  }) {
    return ScannerInitial(
      guests: guests ?? this.guests,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [guests, searchQuery];
}

/// State while scanning is in progress
class Scanning extends ScannerState {
  final List<CheckInGuestEntity> guests;
  final String searchQuery;

  const Scanning({
    this.guests = const [],
    this.searchQuery = '',
  });

  int get expectedGuests => guests.length;
  int get checkedInGuests => guests.where((g) => g.checkedIn).length;
  int get pendingGuests => guests.where((g) => !g.checkedIn).length;

  List<CheckInGuestEntity> get filteredGuests {
    if (searchQuery.isEmpty) return guests;
    return guests.where((guest) {
      return guest.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          guest.qrCode.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  List<Object?> get props => [guests, searchQuery];
}

/// State when a guest is scanned successfully
class GuestScanned extends ScannerState {
  final CheckInGuestEntity guest;
  final List<CheckInGuestEntity> guests;
  final String searchQuery;

  const GuestScanned({
    required this.guest,
    this.guests = const [],
    this.searchQuery = '',
  });

  bool get isAlreadyCheckedIn => guest.checkedIn;

  int get expectedGuests => guests.length;
  int get checkedInGuests => guests.where((g) => g.checkedIn).length;
  int get pendingGuests => guests.where((g) => !g.checkedIn).length;

  List<CheckInGuestEntity> get filteredGuests {
    if (searchQuery.isEmpty) return guests;
    return guests.where((guest) {
      return guest.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          guest.qrCode.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  List<Object?> get props => [guest, guests, searchQuery];
}

/// State when a guest is checked in successfully
class GuestCheckedIn extends ScannerState {
  final CheckInGuestEntity guest;
  final List<CheckInGuestEntity> guests;
  final String searchQuery;

  const GuestCheckedIn({
    required this.guest,
    this.guests = const [],
    this.searchQuery = '',
  });

  int get expectedGuests => guests.length;
  int get checkedInGuests => guests.where((g) => g.checkedIn).length;
  int get pendingGuests => guests.where((g) => !g.checkedIn).length;

  List<CheckInGuestEntity> get filteredGuests {
    if (searchQuery.isEmpty) return guests;
    return guests.where((guest) {
      return guest.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          guest.qrCode.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  List<Object?> get props => [guest, guests, searchQuery];
}

/// State when an error occurs
class ScannerError extends ScannerState {
  final String message;
  final List<CheckInGuestEntity> guests;
  final String searchQuery;

  const ScannerError({
    required this.message,
    this.guests = const [],
    this.searchQuery = '',
  });

  int get expectedGuests => guests.length;
  int get checkedInGuests => guests.where((g) => g.checkedIn).length;
  int get pendingGuests => guests.where((g) => !g.checkedIn).length;

  List<CheckInGuestEntity> get filteredGuests {
    if (searchQuery.isEmpty) return guests;
    return guests.where((guest) {
      return guest.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          guest.qrCode.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  List<Object?> get props => [message, guests, searchQuery];
}

/// Check-in refused with 409: the guest already came in ("دخل مسبقاً").
/// Extends [ScannerError] so stats / list rendering stay unchanged.
class GuestAlreadyCheckedIn extends ScannerError {
  final CheckInGuestEntity guest;

  const GuestAlreadyCheckedIn({
    required this.guest,
    required super.message,
    super.guests,
    super.searchQuery,
  });

  @override
  List<Object?> get props => [guest, message, guests, searchQuery];
}

/// Self-service kiosk: the outcome of one scan + automatic check-in.
/// [admitted] true → green welcome; false → red with [message].
class KioskResult extends ScannerState {
  final bool admitted;
  final String name;
  final int companions;
  final String message;
  final DateTime? checkedInAt;

  /// Increments per scan so two identical results still rebuild.
  final int seq;

  const KioskResult({
    required this.admitted,
    required this.seq,
    this.name = '',
    this.companions = 0,
    this.message = '',
    this.checkedInAt,
  });

  @override
  List<Object?> get props => [admitted, name, companions, message, checkedInAt, seq];
}
