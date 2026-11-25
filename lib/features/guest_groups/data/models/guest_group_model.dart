import '../../domain/entities/guest_group.dart';

class GuestGroupModel extends GuestGroup {
  const GuestGroupModel({required super.id, required super.name, super.guestsCount, super.guests});

  factory GuestGroupModel.fromJson(Map<String, dynamic> json) {
    final list = json['guests'];
    final guests = [
      for (final item in list is List ? list : const [])
        if (item is Map)
          GroupGuest(
            id: _int(item['id']),
            name: '${item['name'] ?? ''}',
            phone: _text(item['phone']),
          ),
    ];
    return GuestGroupModel(
      id: _int(json['id']) ?? 0,
      name: '${json['name'] ?? ''}',
      guestsCount: _int(json['guests_count']) ?? guests.length,
      guests: guests,
    );
  }

  /// One group, inside "data" or bare.
  factory GuestGroupModel.fromResponse(dynamic response) => GuestGroupModel.fromJson(_data(response));

  static GuestGroupsOverview overview(dynamic response) {
    final data = _data(response);
    final list = data['groups'];
    return GuestGroupsOverview(
      totalGuests: _int(data['total_guests']) ?? 0,
      groups: [
        for (final item in list is List ? list : const [])
          if (item is Map) GuestGroupModel.fromJson(Map<String, dynamic>.from(item)),
      ],
    );
  }

  static List<Map<String, String>> guestsToJson(List<GroupGuest> guests) => [
        for (final guest in guests)
          {
            'name': guest.name.trim(),
            if ((guest.phone ?? '').trim().isNotEmpty) 'phone': guest.phone!.trim(),
          },
      ];

  static Map<String, dynamic> _data(dynamic response) {
    final root = response is Map ? response['data'] ?? response : null;
    return root is Map ? Map<String, dynamic>.from(root) : const {};
  }

  static int? _int(dynamic value) => value is num ? value.toInt() : int.tryParse('${value ?? ''}');

  static String? _text(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
