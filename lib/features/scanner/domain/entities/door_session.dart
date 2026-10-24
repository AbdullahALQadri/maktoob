import 'package:equatable/equatable.dart';

/// How a door phone signs in to the event.
enum DoorSessionKind {
  /// The host or an institution member, with the app's client account.
  client,

  /// A staff phone paired by a door code (its own door token).
  paired,

  /// A scanner account assigned to the venue.
  scanner,

  /// A phone that only joined the venue hub (no server access of its own).
  lan,
}

/// A door session: one phone working one event.
class DoorSession extends Equatable {
  final String id;
  final DoorSessionKind kind;
  final int eventId;
  final String eventTitle;
  final String deviceName;
  final int? gateId;

  /// For [DoorSessionKind.lan] peers: the hub to talk to (JSON of LanJoinInfo).
  final String? lanJoin;

  /// The server refused the token (removed device, expired login).
  final bool needsAuth;
  final bool revoked;

  const DoorSession({
    required this.id,
    required this.kind,
    required this.eventId,
    required this.eventTitle,
    required this.deviceName,
    this.gateId,
    this.lanJoin,
    this.needsAuth = false,
    this.revoked = false,
  });

  static String idFor(DoorSessionKind kind, int eventId) => '${kind.name}:$eventId';

  /// The host's (or an institution member's) own door for one of their
  /// events. The engine fills in what the phone remembers (name, gate, hub).
  factory DoorSession.client(int eventId, String eventTitle) => DoorSession(
    id: idFor(DoorSessionKind.client, eventId),
    kind: DoorSessionKind.client,
    eventId: eventId,
    eventTitle: eventTitle,
    deviceName: '',
  );

  /// Staff sessions are the door-only app mode (no client account needed).
  bool get isStaffOnly => kind != DoorSessionKind.client;

  bool get hasServer => kind != DoorSessionKind.lan;

  DoorSession copyWith({
    String? eventTitle,
    String? deviceName,
    int? gateId,
    bool clearGate = false,
    String? lanJoin,
    bool? needsAuth,
    bool? revoked,
  }) => DoorSession(
    id: id,
    kind: kind,
    eventId: eventId,
    eventTitle: eventTitle ?? this.eventTitle,
    deviceName: deviceName ?? this.deviceName,
    gateId: clearGate ? null : (gateId ?? this.gateId),
    lanJoin: lanJoin ?? this.lanJoin,
    needsAuth: needsAuth ?? this.needsAuth,
    revoked: revoked ?? this.revoked,
  );

  @override
  List<Object?> get props => [id, kind, eventId, eventTitle, deviceName, gateId, lanJoin, needsAuth, revoked];
}
