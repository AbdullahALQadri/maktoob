import '../../domain/entities/occasion_group_entity.dart';

int _asInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

class OccasionTypeModel extends OccasionTypeEntity {
  const OccasionTypeModel({
    required super.id,
    required super.slug,
    required super.nameAr,
    required super.nameEn,
  });

  factory OccasionTypeModel.fromJson(Map<String, dynamic> json) {
    final nameAr = (json['name_ar'] ?? json['name'] ?? '').toString();
    return OccasionTypeModel(
      id: _asInt(json['id']),
      slug: (json['slug'] ?? '').toString(),
      nameAr: nameAr,
      nameEn: (json['name_en'] ?? nameAr).toString(),
    );
  }
}

class OccasionGroupModel extends OccasionGroupEntity {
  const OccasionGroupModel({
    required super.id,
    required super.slug,
    required super.nameAr,
    required super.nameEn,
    required super.types,
  });

  factory OccasionGroupModel.fromJson(Map<String, dynamic> json) {
    final rawTypes = json['event_types'] ?? json['types'];
    final nameAr = (json['name_ar'] ?? json['name'] ?? '').toString();
    return OccasionGroupModel(
      id: _asInt(json['id']),
      slug: (json['slug'] ?? '').toString(),
      nameAr: nameAr,
      nameEn: (json['name_en'] ?? nameAr).toString(),
      types: rawTypes is List
          ? rawTypes
              .whereType<Map>()
              .map((t) =>
                  OccasionTypeModel.fromJson(Map<String, dynamic>.from(t)))
              .toList()
          : const [],
    );
  }

  /// Parses `GET /public/event-types` → `{event_types:[...], groups:[...]}`.
  /// Tolerates a `data` wrapper. Groups without types are dropped.
  static List<OccasionGroupModel> listFromResponse(dynamic response) {
    dynamic groups;
    if (response is Map) {
      final data = response['data'];
      groups = response['groups'] ?? (data is Map ? data['groups'] : null);
    }
    final parsed = groups is List
        ? groups
            .whereType<Map>()
            .map((g) =>
                OccasionGroupModel.fromJson(Map<String, dynamic>.from(g)))
            .where((g) => g.types.isNotEmpty)
            .toList()
        : <OccasionGroupModel>[];
    if (parsed.isNotEmpty) return parsed;

    // A server without occasion groups yet still sends the flat type list:
    // show it as one group instead of an empty screen.
    final rawTypes = response is Map
        ? (response['event_types'] ??
            (response['data'] is Map ? response['data']['event_types'] : null))
        : null;
    if (rawTypes is! List || rawTypes.isEmpty) return const [];
    final all = OccasionGroupModel.fromJson({
      'id': 0,
      'slug': 'all',
      'name_ar': 'كل المناسبات',
      'name_en': 'All occasions',
      'event_types': rawTypes,
    });
    return all.types.isEmpty ? const [] : [all];
  }
}
