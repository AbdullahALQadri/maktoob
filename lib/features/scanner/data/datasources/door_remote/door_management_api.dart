part of '../door_remote_data_source.dart';

/// The host manages the door (client sessions): gates, door codes and
/// paired phones.
mixin _DoorManagementApi {
  DoorHttp get http;

  String _base(DoorSession s) => DoorRemoteDataSource.base(s);

  Future<List<DoorGate>> gates(DoorSession s) async {
    final body = await http.request(s, 'GET', '${_base(s)}/gates');
    return _list(body).map(DoorJson.gate).toList();
  }

  Future<DoorGate> addGate(DoorSession s, String name, String audience) async => DoorJson.gate(
    _data(await http.request(s, 'POST', '${_base(s)}/gates', body: {'name': name, 'audience': audience})),
  );

  Future<DoorGate> updateGate(DoorSession s, int id, {String? name, String? audience, bool? active}) async =>
      DoorJson.gate(
        _data(
          await http.request(
            s,
            'PUT',
            '${_base(s)}/gates/$id',
            body: {
              if (name != null) 'name': name,
              if (audience != null) 'audience': audience,
              if (active != null) 'is_active': active,
            },
          ),
        ),
      );

  Future<void> deleteGate(DoorSession s, int id) => http.request(s, 'DELETE', '${_base(s)}/gates/$id');

  Future<List<DoorCodeModel>> codes(DoorSession s) async =>
      _list(await http.request(s, 'GET', '${_base(s)}/codes')).map(DoorCodeModel.fromJson).toList();

  Future<DoorCodeCreated> createCode(DoorSession s, {String? label, int? gateId, int? maxDevices}) async =>
      DoorCodeCreated.fromJson(
        _data(
          await http.request(
            s,
            'POST',
            '${_base(s)}/codes',
            body: {
              if (label != null && label.isNotEmpty) 'label': label,
              if (gateId != null) 'gate_id': gateId,
              if (maxDevices != null) 'max_devices': maxDevices,
            },
          ),
        ),
      );

  Future<void> cancelCode(DoorSession s, int id) => http.request(s, 'DELETE', '${_base(s)}/codes/$id');

  Future<List<DoorDeviceModel>> devices(DoorSession s) async =>
      _list(await http.request(s, 'GET', '${_base(s)}/devices')).map(DoorDeviceModel.fromJson).toList();

  Future<void> removeDevice(DoorSession s, int id) => http.request(s, 'DELETE', '${_base(s)}/devices/$id');
}
