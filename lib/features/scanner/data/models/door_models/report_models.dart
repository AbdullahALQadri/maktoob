part of '../door_models.dart';

/// `GET .../door/summary`: the host's report.
class DoorSummaryModel {
  final int invitations;
  final int checkedIn;
  final int companions;
  final int people;
  final int flagged;

  /// Who came each day of an event of several days (empty for one day).
  final List<DoorDayCount> days;
  final List<DoorGateCount> gates;
  final DoorGateCount noGate;
  final List<DoorDeviceModel> devices;
  final bool canManage;

  const DoorSummaryModel({
    required this.invitations,
    required this.checkedIn,
    required this.companions,
    required this.people,
    required this.flagged,
    this.days = const [],
    required this.gates,
    required this.noGate,
    required this.devices,
    required this.canManage,
  });

  factory DoorSummaryModel.fromJson(Map<String, dynamic> j) {
    final t = _map(j['totals']);
    final noGate = _map(j['no_gate']);
    return DoorSummaryModel(
      invitations: _int(t['invitations']),
      checkedIn: _int(t['checked_in']),
      companions: _int(t['companions']),
      people: _int(t['people']),
      flagged: _int(t['flagged']),
      days: _list(j['days'])
          .map(
            (d) =>
                DoorDayCount(date: '${d['date'] ?? ''}', guests: _int(d['guests']), companions: _int(d['companions'])),
          )
          .toList(),
      gates: _list(j['gates'])
          .map(
            (g) => DoorGateCount(gate: DoorJson.gate(g), guests: _int(g['guests']), companions: _int(g['companions'])),
          )
          .toList(),
      noGate: DoorGateCount(gate: null, guests: _int(noGate['guests']), companions: _int(noGate['companions'])),
      devices: _list(j['devices']).map(DoorDeviceModel.fromJson).toList(),
      canManage: j['can_manage'] == true,
    );
  }
}

/// One day of an event of several days: [date] is Y-m-d (Asia/Gaza).
class DoorDayCount {
  final String date;
  final int guests;
  final int companions;

  const DoorDayCount({required this.date, required this.guests, required this.companions});
}

class DoorGateCount {
  final DoorGate? gate;
  final int guests;
  final int companions;

  const DoorGateCount({required this.gate, required this.guests, required this.companions});
}

class DoorDeviceModel {
  final int id;
  final String kind;
  final String name;
  final int? gateId;
  final DateTime? lastSeenAt;
  final DateTime? lastSyncAt;
  final int pending;
  final bool revoked;
  final int checkIns;

  const DoorDeviceModel({
    required this.id,
    required this.kind,
    required this.name,
    this.gateId,
    this.lastSeenAt,
    this.lastSyncAt,
    this.pending = 0,
    this.revoked = false,
    this.checkIns = 0,
  });

  factory DoorDeviceModel.fromJson(Map<String, dynamic> j) => DoorDeviceModel(
    id: _int(j['id']),
    kind: '${j['kind'] ?? 'paired'}',
    name: '${j['name'] ?? ''}',
    gateId: _intOrNull(j['gate_id']),
    lastSeenAt: _date(j['last_seen_at']),
    lastSyncAt: _date(j['last_sync_at']),
    pending: _int(j['pending']),
    revoked: j['revoked'] == true,
    checkIns: _int(j['check_ins']),
  );
}
