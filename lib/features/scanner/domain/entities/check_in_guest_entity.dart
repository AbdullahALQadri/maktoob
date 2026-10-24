import 'package:equatable/equatable.dart';

class CheckInGuestEntity extends Equatable {
  final String id;
  final String name;
  final String status;
  final int companions;
  final bool checkedIn;
  final String qrCode;

  /// Door rules. When [canCheckIn] is false, [blockerCode] says why (a code
  /// the UI translates; decided on the phone, offline) and [blockerMessage]
  /// is the server's own text when the server decided.
  final bool canCheckIn;
  final String? blockerMessage;
  final String? blockerCode;

  /// Upper bound for companions at the door; null = no limit.
  final int? maxCompanions;

  /// The guest declined the RSVP: check-in is still allowed, with [warning].
  final bool declinedRsvp;
  final String? warning;

  /// Door warnings (codes): declined, wrong_gate, unlisted.
  final List<String> warnings;

  final String? gender;
  final String? phoneTail;

  /// When / where the guest was (first) checked in, if known.
  final DateTime? checkedInAt;
  final String? checkedInDevice;
  final int? checkedInGateId;

  /// A genuine invitation (signed QR) that is not in the downloaded list yet.
  final bool unlisted;

  /// Decided on this phone or by the venue hub, not by the server.
  final bool decidedOffline;

  /// A check-in result: the guest had already come in (stepped out, came
  /// back) and was let back in; [checkedInAt] is that first entry.
  final bool returning;

  const CheckInGuestEntity({
    required this.id,
    required this.name,
    required this.status,
    required this.companions,
    required this.checkedIn,
    required this.qrCode,
    this.canCheckIn = true,
    this.blockerMessage,
    this.blockerCode,
    this.maxCompanions,
    this.declinedRsvp = false,
    this.warning,
    this.warnings = const [],
    this.gender,
    this.phoneTail,
    this.checkedInAt,
    this.checkedInDevice,
    this.checkedInGateId,
    this.unlisted = false,
    this.decidedOffline = false,
    this.returning = false,
  });

  bool get isVip => status == 'VIP';

  /// Companions to preselect: the RSVP count, capped at [maxCompanions].
  int get defaultCompanions {
    final max = maxCompanions;
    if (max == null) return companions;
    return companions.clamp(0, max);
  }

  CheckInGuestEntity copyWith({
    String? id,
    String? name,
    String? status,
    int? companions,
    bool? checkedIn,
    String? qrCode,
    DateTime? checkedInAt,
    String? warning,
    String? checkedInDevice,
    int? checkedInGateId,
    bool? decidedOffline,
  }) {
    return CheckInGuestEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      companions: companions ?? this.companions,
      checkedIn: checkedIn ?? this.checkedIn,
      qrCode: qrCode ?? this.qrCode,
      canCheckIn: canCheckIn,
      blockerMessage: blockerMessage,
      blockerCode: blockerCode,
      maxCompanions: maxCompanions,
      declinedRsvp: declinedRsvp,
      warning: warning ?? this.warning,
      warnings: warnings,
      gender: gender,
      phoneTail: phoneTail,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      checkedInDevice: checkedInDevice ?? this.checkedInDevice,
      checkedInGateId: checkedInGateId ?? this.checkedInGateId,
      unlisted: unlisted,
      decidedOffline: decidedOffline ?? this.decidedOffline,
      returning: returning,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    status,
    companions,
    checkedIn,
    qrCode,
    canCheckIn,
    blockerMessage,
    blockerCode,
    maxCompanions,
    declinedRsvp,
    warning,
    warnings,
    gender,
    phoneTail,
    checkedInAt,
    checkedInDevice,
    checkedInGateId,
    unlisted,
    decidedOffline,
    returning,
  ];
}
