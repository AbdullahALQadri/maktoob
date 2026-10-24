import 'package:equatable/equatable.dart';

import 'door_entities.dart';

/// What the door phone knows about its connection and its queue.
enum DoorLink {
  /// The server answered recently.
  online,

  /// Connected to the venue hub (no server).
  hub,

  /// No server, no hub: deciding alone.
  offline,
}

class DoorStatus extends Equatable {
  final DoorSession? session;
  final DoorEventInfo? event;
  final List<DoorGate> gates;
  final DoorLink link;
  final bool hasPack;
  final int guests;
  final int checkedIn;
  final int pending;
  final int refused;
  final DateTime? packDownloadedAt;
  final DateTime? lastSyncAt;
  final bool syncing;

  /// This phone runs the venue hub; [peers] phones are connected to it.
  final bool hubRunning;
  final List<String> hubAddresses;
  final int peers;

  /// Last problem worth showing (a code the UI translates).
  final String? problem;

  const DoorStatus({
    this.session,
    this.event,
    this.gates = const [],
    this.link = DoorLink.offline,
    this.hasPack = false,
    this.guests = 0,
    this.checkedIn = 0,
    this.pending = 0,
    this.refused = 0,
    this.packDownloadedAt,
    this.lastSyncAt,
    this.syncing = false,
    this.hubRunning = false,
    this.hubAddresses = const [],
    this.peers = 0,
    this.problem,
  });

  DoorGate? get gate {
    final id = session?.gateId;
    if (id == null) return null;
    for (final g in gates) {
      if (g.id == id) return g;
    }
    return null;
  }

  DoorStatus copyWith({
    DoorSession? session,
    DoorEventInfo? event,
    List<DoorGate>? gates,
    DoorLink? link,
    bool? hasPack,
    int? guests,
    int? checkedIn,
    int? pending,
    int? refused,
    DateTime? packDownloadedAt,
    DateTime? lastSyncAt,
    bool? syncing,
    bool? hubRunning,
    List<String>? hubAddresses,
    int? peers,
    String? problem,
    bool clearProblem = false,
  }) => DoorStatus(
    session: session ?? this.session,
    event: event ?? this.event,
    gates: gates ?? this.gates,
    link: link ?? this.link,
    hasPack: hasPack ?? this.hasPack,
    guests: guests ?? this.guests,
    checkedIn: checkedIn ?? this.checkedIn,
    pending: pending ?? this.pending,
    refused: refused ?? this.refused,
    packDownloadedAt: packDownloadedAt ?? this.packDownloadedAt,
    lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    syncing: syncing ?? this.syncing,
    hubRunning: hubRunning ?? this.hubRunning,
    hubAddresses: hubAddresses ?? this.hubAddresses,
    peers: peers ?? this.peers,
    problem: clearProblem ? null : (problem ?? this.problem),
  );

  @override
  List<Object?> get props => [
    session,
    event,
    gates,
    link,
    hasPack,
    guests,
    checkedIn,
    pending,
    refused,
    packDownloadedAt,
    lastSyncAt,
    syncing,
    hubRunning,
    hubAddresses,
    peers,
    problem,
  ];
}
