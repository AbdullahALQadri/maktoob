part of '../door_remote_data_source.dart';

/// Door staff sign-in: a phone paired by a door code, or a scanner account.
mixin _DoorStaffApi {
  DoorHttp get http;

  Future<DoorPairing> pair({required String code, required String deviceUuid, required String deviceName}) async {
    final body = await http.request(
      null,
      'POST',
      Endpoints.doorPair,
      body: {
        'code': code,
        'device_uuid': deviceUuid,
        'device_name': deviceName,
        'platform': kIsWeb ? 'web' : Platform.operatingSystem,
      },
    );
    return DoorPairing.fromJson(_data(body));
  }

  Future<void> setPairedGate(DoorSession s, int? gateId) =>
      http.request(s, 'PUT', Endpoints.doorPairedGate, body: {'gate_id': gateId});

  Future<void> logoutPaired(DoorSession s) => http.request(s, 'POST', Endpoints.doorPairedLogout);

  /// Scanner account login: the token, then the events it may scan today.
  Future<String> scannerLogin(String email, String password) async {
    final body = await http.request(null, 'POST', Endpoints.scannerLogin, body: {'email': email, 'password': password});
    final data = _data(body);
    final token = '${data['token'] ?? body['token'] ?? ''}';
    if (token.isEmpty) throw const DoorHttpException(DoorErrorKind.auth);
    return token;
  }

  Future<List<DoorEventInfo>> scannerEvents(String token) async {
    final body = await http.request(null, 'GET', Endpoints.scannerAssignmentsActive, bearer: token);
    final events = <int, DoorEventInfo>{};
    for (final a in _list(_data(body)['assignments'] ?? const [])) {
      final event = a['event'];
      if (event is Map) {
        final e = DoorJson.event(Map<String, dynamic>.from(event));
        events[e.id] = e;
        continue;
      }
      // A general venue assignment covers every event at the venue.
      final venue = a['venue'];
      final venueId = venue is Map ? int.tryParse('${venue['id']}') : null;
      if (venueId == null) continue;
      final venueEvents = await http.request(null, 'GET', Endpoints.scannerVenueEvents(venueId), bearer: token);
      for (final ve in _list(_data(venueEvents)['events'] ?? const [])) {
        final e = DoorJson.event(ve);
        events[e.id] = e;
      }
    }
    return events.values.toList();
  }
}
