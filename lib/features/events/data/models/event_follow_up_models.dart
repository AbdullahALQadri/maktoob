import '../../../../core/utils/gaza_time.dart';
import '../../domain/entities/event_card.dart';
import '../../domain/entities/event_follow_up.dart';

/// `GET /events/{id}/activity` items.
class ActivityItemModel extends ActivityItem {
  const ActivityItemModel({
    required super.invitationId,
    required super.replied,
    required super.name,
    super.reply,
    super.companions,
    super.at,
  });

  factory ActivityItemModel.fromJson(Map<String, dynamic> json) => ActivityItemModel(
    invitationId: (json['invitation_id'] as num?)?.toInt() ?? 0,
    replied: json['type'] == 'replied',
    reply: json['reply']?.toString(),
    name: json['name']?.toString() ?? '',
    companions: (json['companions'] as num?)?.toInt() ?? 0,
    at: GazaTime.wallClock(json['at']),
  );

  static List<ActivityItem> listFrom(Object? response) {
    final data = response is Map ? response['data'] : response;
    return [
      for (final item in (data as List? ?? const []))
        if (item is Map<String, dynamic>) ActivityItemModel.fromJson(item),
    ];
  }
}

/// `GET /events/{id}/progress`.
class EventProgressModel extends EventProgress {
  const EventProgressModel({required super.inSetup, required super.nextAction, required super.steps});

  factory EventProgressModel.fromResponse(Map<String, dynamic> response) {
    final data = response['data'] is Map ? response['data'] as Map : response;
    final next = data['next_action'];
    return EventProgressModel(
      inSetup: data['in_setup'] == true,
      nextAction: NextAction.fromKey(next is Map ? next['key']?.toString() : null),
      steps: [
        for (final step in (data['steps'] as List? ?? const []))
          if (step is Map)
            SetupStep(key: step['key']?.toString() ?? '', done: step['done'] == true, current: step['current'] == true),
      ],
    );
  }
}
