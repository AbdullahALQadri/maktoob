import '../../../../core/utils/gaza_time.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/entities/event_card.dart';

/// Parses one event card of `GET /client/home` (backend `ClientEventCard`).
class EventCardModel extends EventCard {
  const EventCardModel({
    required super.id,
    required super.title,
    required super.status,
    required super.role,
    required super.nextAction,
    super.typeNameAr,
    super.typeNameEn,
    super.date,
    super.imageUrl,
    super.invitations,
    super.opened,
    super.responded,
    super.countdownDays,
    super.stepNumber,
    super.stepsTotal,
  });

  factory EventCardModel.fromJson(Map<String, dynamic> json) {
    final type = json['event_type'];
    final next = json['next_action'];
    final image = json['image_url']?.toString();
    return EventCardModel(
      id: _int(json['id']) ?? 0,
      title: json['title']?.toString() ?? '',
      status: EventStatusApi.parse(json['status']?.toString()),
      role: EventRole.fromString(json['my_role']?.toString()),
      nextAction: NextAction.fromKey(next is Map ? next['key']?.toString() : null),
      typeNameAr: type is Map ? type['name_ar']?.toString() : null,
      typeNameEn: type is Map ? type['name_en']?.toString() : null,
      date: GazaTime.wallClock(json['event_date']),
      imageUrl: image == null || image.isEmpty ? null : image,
      invitations: _int(json['invitations_count']) ?? 0,
      opened: _int(json['opened_count']) ?? 0,
      responded: _int(json['responded_count']) ?? 0,
      countdownDays: _int(json['countdown_days']),
      stepNumber: _int(json['step_number']),
      stepsTotal: _int(json['steps_total']) ?? 6,
    );
  }

  static int? _int(Object? value) => value is num ? value.toInt() : int.tryParse('${value ?? ''}');
}
