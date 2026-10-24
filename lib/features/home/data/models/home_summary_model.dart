import '../../../../core/utils/gaza_time.dart';
import '../../domain/entities/home_summary.dart';
import '../../../events/data/models/event_card_model.dart';

/// Parses `GET /client/home` (`{success, data: {...}}`). An answer served from
/// the offline cache carries `_offline.age_seconds`.
class HomeSummaryModel extends HomeSummary {
  const HomeSummaryModel({
    required super.totals,
    required super.events,
    required super.gazaOffset,
    super.nextEvent,
    super.freeTrialAvailable,
    super.savedAgo,
  });

  factory HomeSummaryModel.fromResponse(Map<String, dynamic> response) {
    final data = response['data'] is Map<String, dynamic> ? response['data'] as Map<String, dynamic> : response;
    final totals = data['totals'] is Map ? data['totals'] as Map : const {};
    final next = data['next_event'];
    final offline = response['_offline'];

    return HomeSummaryModel(
      totals: HomeTotals(
        events: _int(totals['events']),
        activeEvents: _int(totals['active_events']),
        invitations: _int(totals['invitations']),
        responses: _int(totals['responses']),
        responseRate: _int(totals['response_rate']),
      ),
      nextEvent: next is Map<String, dynamic> ? EventCardModel.fromJson(next) : null,
      events: [
        for (final e in (data['events'] as List? ?? const []))
          if (e is Map<String, dynamic>) EventCardModel.fromJson(e),
      ],
      freeTrialAvailable: data['free_trial_available'] == true,
      gazaOffset: GazaTime.offsetOf(data['now']) ?? DateTime.now().timeZoneOffset,
      savedAgo: offline is Map ? Duration(seconds: _int(offline['age_seconds'])) : null,
    );
  }

  static int _int(Object? value) => value is num ? value.toInt() : int.tryParse('${value ?? ''}') ?? 0;
}
