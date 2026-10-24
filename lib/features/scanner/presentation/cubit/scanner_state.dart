import 'package:equatable/equatable.dart';

import '../../domain/entities/check_in_guest_entity.dart';

abstract class ScannerState extends Equatable {
  const ScannerState();

  @override
  List<Object?> get props => [];
}

/// Shared by the states that show the stats and the guest list.
mixin GuestListView on ScannerState {
  List<CheckInGuestEntity> get guests;
  String get searchQuery;

  int get expectedGuests => guests.length;
  int get checkedInGuests => guests.where((g) => g.checkedIn).length;
  int get pendingGuests => guests.where((g) => !g.checkedIn).length;

  /// The list is already filtered by the door store (Arabic-tolerant).
  List<CheckInGuestEntity> get filteredGuests => guests;
}

/// Initial state when scanner is ready
class ScannerInitial extends ScannerState with GuestListView {
  @override
  final List<CheckInGuestEntity> guests;
  @override
  final String searchQuery;

  const ScannerInitial({this.guests = const [], this.searchQuery = ''});

  ScannerInitial copyWith({List<CheckInGuestEntity>? guests, String? searchQuery}) {
    return ScannerInitial(guests: guests ?? this.guests, searchQuery: searchQuery ?? this.searchQuery);
  }

  @override
  List<Object?> get props => [guests, searchQuery];
}

/// State while scanning is in progress
class Scanning extends ScannerState with GuestListView {
  @override
  final List<CheckInGuestEntity> guests;
  @override
  final String searchQuery;

  const Scanning({this.guests = const [], this.searchQuery = ''});

  @override
  List<Object?> get props => [guests, searchQuery];
}

/// State when a guest is scanned successfully
class GuestScanned extends ScannerState with GuestListView {
  final CheckInGuestEntity guest;
  @override
  final List<CheckInGuestEntity> guests;
  @override
  final String searchQuery;

  const GuestScanned({required this.guest, this.guests = const [], this.searchQuery = ''});

  /// Already came in today and the QR is still valid: let back in.
  bool get isReturning => guest.checkedIn && guest.canCheckIn;

  @override
  List<Object?> get props => [guest, guests, searchQuery];
}

/// State when a guest is checked in successfully
class GuestCheckedIn extends ScannerState with GuestListView {
  final CheckInGuestEntity guest;
  @override
  final List<CheckInGuestEntity> guests;
  @override
  final String searchQuery;

  const GuestCheckedIn({required this.guest, this.guests = const [], this.searchQuery = ''});

  @override
  List<Object?> get props => [guest, guests, searchQuery];
}

/// State when an error occurs. [code] is a door rule code the UI translates
/// (an offline door has no server text); [message] is the server's own text
/// when it decided.
class ScannerError extends ScannerState with GuestListView {
  final String message;
  final String? code;
  final int? maxCompanions;
  @override
  final List<CheckInGuestEntity> guests;
  @override
  final String searchQuery;

  const ScannerError({
    required this.message,
    this.code,
    this.maxCompanions,
    this.guests = const [],
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [message, code, maxCompanions, guests, searchQuery];
}

/// Self-service kiosk: the outcome of one scan + automatic check-in.
/// [admitted] true → green welcome (with [returning]: welcome back, first
/// came in at [checkedInAt]); false → red with [code] / [message].
class KioskResult extends ScannerState {
  final bool admitted;
  final bool returning;
  final String name;
  final int companions;
  final String? code;
  final String message;
  final DateTime? checkedInAt;
  final String? checkedInDevice;
  final List<String> warnings;

  /// Increments per scan so two identical results still rebuild.
  final int seq;

  const KioskResult({
    required this.admitted,
    required this.seq,
    this.returning = false,
    this.name = '',
    this.companions = 0,
    this.code,
    this.message = '',
    this.checkedInAt,
    this.checkedInDevice,
    this.warnings = const [],
  });

  @override
  List<Object?> get props => [
    admitted,
    returning,
    name,
    companions,
    code,
    message,
    checkedInAt,
    checkedInDevice,
    warnings,
    seq,
  ];
}
