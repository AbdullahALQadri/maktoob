import 'package:equatable/equatable.dart';

class CheckInGuestEntity extends Equatable {
  final String id;
  final String name;
  final String status;
  final int companions;
  final bool checkedIn;
  final String qrCode;

  /// Scan flags from the backend (CheckInService::scanFlags). When
  /// [canCheckIn] is false, [blockerMessage] explains why (e.g. the event is
  /// not active) and no check-in may be offered.
  final bool canCheckIn;
  final String? blockerMessage;

  /// Upper bound for companions at the door; null = no limit sent.
  final int? maxCompanions;

  /// The guest declined the RSVP: check-in is still allowed, with [warning].
  final bool declinedRsvp;
  final String? warning;

  /// When the guest was (last) checked in, if known.
  final DateTime? checkedInAt;

  const CheckInGuestEntity({
    required this.id,
    required this.name,
    required this.status,
    required this.companions,
    required this.checkedIn,
    required this.qrCode,
    this.canCheckIn = true,
    this.blockerMessage,
    this.maxCompanions,
    this.declinedRsvp = false,
    this.warning,
    this.checkedInAt,
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
      maxCompanions: maxCompanions,
      declinedRsvp: declinedRsvp,
      warning: warning ?? this.warning,
      checkedInAt: checkedInAt ?? this.checkedInAt,
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
        maxCompanions,
        declinedRsvp,
        warning,
        checkedInAt,
      ];
}
