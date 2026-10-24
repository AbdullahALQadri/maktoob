part of '../door_models.dart';

class DoorCodeModel {
  final int id;
  final String? label;
  final String hint;
  final int? gateId;
  final int maxDevices;
  final int usedCount;
  final DateTime? expiresAt;
  final bool revoked;
  final bool usable;

  const DoorCodeModel({
    required this.id,
    this.label,
    required this.hint,
    this.gateId,
    required this.maxDevices,
    required this.usedCount,
    this.expiresAt,
    this.revoked = false,
    this.usable = true,
  });

  factory DoorCodeModel.fromJson(Map<String, dynamic> j) => DoorCodeModel(
    id: _int(j['id']),
    label: _str(j['label']),
    hint: '${j['hint'] ?? ''}',
    gateId: _intOrNull(j['gate_id']),
    maxDevices: _int(j['max_devices'], 1),
    usedCount: _int(j['used_count']),
    expiresAt: _date(j['expires_at']),
    revoked: j['revoked'] == true,
    usable: j['usable'] != false,
  );
}

/// A freshly created door code: the plain code is shown once.
class DoorCodeCreated {
  final String code;
  final String shareText;
  final DoorCodeModel doorCode;

  const DoorCodeCreated({required this.code, required this.shareText, required this.doorCode});

  factory DoorCodeCreated.fromJson(Map<String, dynamic> j) => DoorCodeCreated(
    code: '${j['code'] ?? ''}',
    shareText: '${j['share_text'] ?? ''}',
    doorCode: DoorCodeModel.fromJson(_map(j['door_code'])),
  );
}

/// `POST /door/pair`.
class DoorPairing {
  final String token;
  final DoorEventInfo event;
  final List<DoorGate> gates;
  final int? gateId;
  final String deviceName;

  const DoorPairing({
    required this.token,
    required this.event,
    required this.gates,
    required this.gateId,
    required this.deviceName,
  });

  factory DoorPairing.fromJson(Map<String, dynamic> j) {
    final device = _map(j['device']);
    return DoorPairing(
      token: '${j['token'] ?? ''}',
      event: DoorJson.event(_map(j['event'])),
      gates: _list(j['gates']).map(DoorJson.gate).toList(),
      gateId: _intOrNull(device['gate_id']),
      deviceName: '${device['name'] ?? ''}',
    );
  }
}
