import 'package:equatable/equatable.dart';

export 'door_session.dart';
export 'door_status.dart';

/// The event as the door pack describes it (door rules included).
class DoorEventInfo extends Equatable {
  final int id;
  final String title;
  final String status;
  final DateTime? eventDate;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final String? validOn;
  final bool allowCompanions;
  final int? companionLimit;
  final String? venueName;

  const DoorEventInfo({
    required this.id,
    required this.title,
    required this.status,
    this.eventDate,
    this.validFrom,
    this.validUntil,
    this.validOn,
    this.allowCompanions = true,
    this.companionLimit,
    this.venueName,
  });

  DoorEventInfo copyWith({String? status}) => DoorEventInfo(
    id: id,
    title: title,
    status: status ?? this.status,
    eventDate: eventDate,
    validFrom: validFrom,
    validUntil: validUntil,
    validOn: validOn,
    allowCompanions: allowCompanions,
    companionLimit: companionLimit,
    venueName: venueName,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    status,
    eventDate,
    validFrom,
    validUntil,
    validOn,
    allowCompanions,
    companionLimit,
    venueName,
  ];
}

/// One door of the event. `audience` (all / men / women) only warns.
class DoorGate extends Equatable {
  final int id;
  final String name;
  final String audience;
  final bool isActive;

  const DoorGate({required this.id, required this.name, this.audience = 'all', this.isActive = true});

  @override
  List<Object?> get props => [id, name, audience, isActive];
}

/// One admission, wherever it was decided (this phone, the venue hub, another
/// door through the server).
class DoorCheckIn extends Equatable {
  final String uuid;
  final int invitationId;
  final DateTime checkedInAt;
  final int companions;
  final int? gateId;
  final String? deviceName;
  final String? source;

  const DoorCheckIn({
    required this.uuid,
    required this.invitationId,
    required this.checkedInAt,
    this.companions = 0,
    this.gateId,
    this.deviceName,
    this.source,
  });

  @override
  List<Object?> get props => [uuid, invitationId, checkedInAt, companions, gateId, deviceName, source];
}

/// An invitee in the door pack.
class DoorGuest extends Equatable {
  final int id;
  final String name;
  final String? nameEn;
  final String? gender;
  final String? phoneTail;
  final int companions;
  final int? maxCompanions;
  final String rsvp;

  /// The first admission of this invitation, if any.
  final DoorCheckIn? checkIn;

  const DoorGuest({
    required this.id,
    required this.name,
    this.nameEn,
    this.gender,
    this.phoneTail,
    this.companions = 0,
    this.maxCompanions,
    this.rsvp = 'no_response',
    this.checkIn,
  });

  bool get declined => rsvp == 'not_attending';

  DoorGuest withCheckIn(DoorCheckIn? value) => DoorGuest(
    id: id,
    name: name,
    nameEn: nameEn,
    gender: gender,
    phoneTail: phoneTail,
    companions: companions,
    maxCompanions: maxCompanions,
    rsvp: rsvp,
    checkIn: value,
  );

  @override
  List<Object?> get props => [id, name, nameEn, gender, phoneTail, companions, maxCompanions, rsvp, checkIn];
}
