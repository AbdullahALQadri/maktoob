import '../../domain/entities/event_entity.dart';
import '../../domain/entities/event_page.dart';
import 'event_card_model.dart';

/// Parses `GET /client/events`:
/// `{success, data: [card], meta: {current_page, last_page}, counts: {all, draft, ...}}`.
class EventPageModel extends EventPage {
  const EventPageModel({
    required super.items,
    required super.page,
    required super.lastPage,
    required super.counts,
    super.savedAgo,
  });

  factory EventPageModel.fromResponse(Map<String, dynamic> response) {
    final meta = response['meta'] is Map ? response['meta'] as Map : const {};
    final counts = response['counts'] is Map ? response['counts'] as Map : const {};
    final offline = response['_offline'];
    return EventPageModel(
      items: [
        for (final item in (response['data'] as List? ?? const []))
          if (item is Map<String, dynamic>) EventCardModel.fromJson(item),
      ],
      page: _int(meta['current_page'], 1),
      lastPage: _int(meta['last_page'], 1),
      counts: EventCounts(
        all: _int(counts['all'], 0),
        byStatus: {for (final status in EventStatus.values) status: _int(counts[status.apiValue], 0)},
      ),
      savedAgo: offline is Map ? Duration(seconds: _int(offline['age_seconds'], 0)) : null,
    );
  }

  static int _int(Object? value, int fallback) =>
      value is num ? value.toInt() : int.tryParse('${value ?? ''}') ?? fallback;
}
