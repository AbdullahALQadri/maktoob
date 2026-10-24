part of '../door_engine.dart';

/// What the phone found for a scanned QR (decided locally, instantly).
class DoorVerdict {
  final DoorGuest? guest;
  final String? blocker;
  final List<String> warnings;
  final bool unlisted;
  final int? maxCompanions;

  const DoorVerdict({this.guest, this.blocker, this.warnings = const [], this.unlisted = false, this.maxCompanions});

  bool get canAdmit => guest != null && blocker == null;

  /// Already came in today (stepped out, came back): let back in, nothing is
  /// recorded again.
  bool get returning => guest?.checkIn != null;
}

enum DoorDecidedBy { server, hub, device }

/// The outcome of letting a guest in (or not).
///
/// [returning]: the guest had already come in; they are let back in and
/// [checkIn] is that first entry (the attendance), nothing new is recorded.
class DoorAdmission {
  final bool admitted;
  final bool returning;
  final String? code;
  final String? message;
  final DoorGuest? guest;
  final DoorCheckIn? checkIn;
  final DoorDecidedBy decidedBy;
  final List<String> warnings;
  final int? maxCompanions;

  const DoorAdmission({
    required this.admitted,
    this.returning = false,
    this.code,
    this.message,
    this.guest,
    this.checkIn,
    this.decidedBy = DoorDecidedBy.device,
    this.warnings = const [],
    this.maxCompanions,
  });
}
