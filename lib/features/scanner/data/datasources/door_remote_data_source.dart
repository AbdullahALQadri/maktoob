import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../../core/api/end_points.dart';
import '../../domain/entities/door_entities.dart';
import '../models/door_models.dart';
import 'door_http.dart';

export 'door_http.dart';

part 'door_remote/door_management_api.dart';
part 'door_remote/door_staff_api.dart';

/// What the phone tells the server about itself on every door call.
class DoorDeviceInfo {
  final String uuid;
  final String name;
  final int? gateId;
  final int pending;

  const DoorDeviceInfo({required this.uuid, required this.name, this.gateId, this.pending = 0});

  String get platform => kIsWeb ? 'web' : Platform.operatingSystem;

  Map<String, dynamic> toQuery() => {
    'device_uuid': uuid,
    'device_name': name,
    'platform': platform,
    'gate_id': gateId ?? '',
    'pending': pending,
  };

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'name': name,
    'platform': platform,
    'gate_id': gateId,
    'pending': pending,
  };
}

class DoorUploadResponse {
  final List<DoorUploadResult> results;
  final DateTime? serverTime;

  const DoorUploadResponse(this.results, this.serverTime);
}

Map<String, dynamic> _data(Map<String, dynamic> body) =>
    body['data'] is Map ? Map<String, dynamic>.from(body['data'] as Map) : body;

List<Map<String, dynamic>> _list(dynamic body) {
  final data = body is Map && body['data'] != null ? body['data'] : body;
  return data is List ? data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList() : const [];
}

/// The door endpoints (backend `routes/api/{client,door,scanner}.php`):
/// the door's own sync calls here, the host's management and the staff
/// sign-in in door_remote/.
class DoorRemoteDataSource with _DoorManagementApi, _DoorStaffApi {
  @override
  final DoorHttp http;

  DoorRemoteDataSource(this.http);

  /// Where a session's door API lives: the host's events, a paired phone's
  /// own `/door`, or a scanner account's assigned event.
  static String base(DoorSession s) => switch (s.kind) {
    DoorSessionKind.client => Endpoints.doorForEvent(s.eventId),
    DoorSessionKind.scanner => Endpoints.doorForScanner(s.eventId),
    DoorSessionKind.paired => Endpoints.doorPaired,
    DoorSessionKind.lan => throw StateError('A hub-only phone has no server API'),
  };

  Future<DoorPackModel> pack(DoorSession s, DoorDeviceInfo device) async {
    final body = await http.request(
      s,
      'GET',
      '${base(s)}/pack',
      query: device.toQuery(),
      timeout: const Duration(seconds: 90),
    );
    return DoorPackModel.fromJson(_data(body));
  }

  Future<DoorChangesModel> changes(DoorSession s, int since, DoorDeviceInfo device) async {
    final body = await http.request(s, 'GET', '${base(s)}/changes', query: {...device.toQuery(), 'since': since});
    return DoorChangesModel.fromJson(_data(body));
  }

  Future<DoorUploadResponse> upload(
    DoorSession s,
    List<Map<String, dynamic>> items,
    DoorDeviceInfo device,
    DateTime sentAtUtc, {
    Duration? timeout,
  }) async {
    final body = await http.request(
      s,
      'POST',
      '${base(s)}/check-ins',
      body: {'device': device.toJson(), 'sent_at': sentAtUtc.toIso8601String(), 'items': items},
      timeout: timeout,
    );
    final data = _data(body);
    final results = (data['results'] is List)
        ? (data['results'] as List)
              .whereType<Map>()
              .map((r) => DoorUploadResult.fromJson(Map<String, dynamic>.from(r)))
              .toList()
        : const <DoorUploadResult>[];
    return DoorUploadResponse(results, DateTime.tryParse('${data['server_time'] ?? ''}')?.toUtc());
  }

  /// A QR not in the pack (a guest added at the venue). Null when unknown.
  Future<DoorPackGuest?> lookup(DoorSession s, String raw, {Duration? timeout}) async {
    try {
      final body = await http.request(s, 'POST', '${base(s)}/lookup', body: {'qr': raw}, timeout: timeout);
      return DoorPackGuest.fromJson(_data(body));
    } on DoorHttpException catch (e) {
      if (e.kind == DoorErrorKind.refused && e.status == 404) return null;
      rethrow;
    }
  }

  Future<DoorSummaryModel> summary(DoorSession s) async =>
      DoorSummaryModel.fromJson(_data(await http.request(s, 'GET', '${base(s)}/summary')));
}
