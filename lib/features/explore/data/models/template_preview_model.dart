import '../../domain/entities/template_preview_entity.dart';

class TemplatePreviewModel extends TemplatePreviewEntity {
  const TemplatePreviewModel({
    required super.id,
    required super.imageUrl,
    required super.thumbnailUrl,
    super.title,
    super.eventTypeId,
  });

  factory TemplatePreviewModel.fromJson(Map<String, dynamic> json) {
    final imageUrl = (json['image_url'] ?? json['url'] ?? '').toString();
    final thumb = json['thumbnail_url']?.toString();
    final title = json['title']?.toString();
    final rawId = json['id'];
    final rawType = json['event_type_id'];
    return TemplatePreviewModel(
      id: rawId is int ? rawId : int.tryParse('$rawId') ?? 0,
      title: (title == null || title.isEmpty) ? null : title,
      imageUrl: imageUrl,
      thumbnailUrl: (thumb == null || thumb.isEmpty) ? imageUrl : thumb,
      eventTypeId: rawType is int
          ? rawType
          : (rawType == null ? null : int.tryParse('$rawType')),
    );
  }

  /// Parses `GET /public/templates` → `{success, data:{templates:[...]}}`.
  static List<TemplatePreviewModel> listFromResponse(dynamic response) {
    dynamic items;
    if (response is Map) {
      final data = response['data'];
      items = data is Map
          ? (data['templates'] ?? data['images'])
          : response['templates'];
    }
    if (items is! List) return const [];
    return items
        .whereType<Map>()
        .map((m) => TemplatePreviewModel.fromJson(Map<String, dynamic>.from(m)))
        .where((t) => t.imageUrl.isNotEmpty)
        .toList();
  }
}
