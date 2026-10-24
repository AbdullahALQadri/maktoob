import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/end_points.dart';
import '../../domain/entities/event_follow_up.dart';
import '../models/event_follow_up_models.dart';

abstract class EventFollowUpRemoteDataSource {
  Future<List<ActivityItem>> activity(String eventId);

  Future<EventProgress> progress(String eventId);

  Future<int> resendFailed(String eventId);

  Future<void> updateUnsentGuest(String eventId, String invitationId, {required String name, required String phone});
}

class EventFollowUpRemoteDataSourceImpl implements EventFollowUpRemoteDataSource {
  const EventFollowUpRemoteDataSourceImpl({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  @override
  Future<List<ActivityItem>> activity(String eventId) async =>
      ActivityItemModel.listFrom(await apiConsumer.get(Endpoints.eventActivity(eventId)));

  @override
  Future<EventProgress> progress(String eventId) async => EventProgressModel.fromResponse(
    Map<String, dynamic>.from(await apiConsumer.get(Endpoints.eventProgress(eventId)) as Map),
  );

  @override
  Future<int> resendFailed(String eventId) async {
    final response = await apiConsumer.post(Endpoints.eventResendFailed(eventId));
    final data = response is Map ? response['data'] : null;
    return data is Map ? (data['sent'] as num?)?.toInt() ?? 0 : 0;
  }

  @override
  Future<void> updateUnsentGuest(String eventId, String invitationId, {required String name, required String phone}) =>
      apiConsumer.put(Endpoints.unsentGuest(eventId, invitationId), body: {'name': name, 'phone': phone});
}
