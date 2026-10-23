import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/end_points.dart';
import '../models/event_add_ons_model.dart';

/// Extra services on a paid event. Every call returns the fresh summary.
abstract class EventAddOnsRemoteDataSource {
  Future<EventAddOnsModel> getAddOns(int eventId);

  Future<EventAddOnsModel> requestAddOn(int eventId, int serviceId, {String? notes});

  Future<EventAddOnsModel> withdrawAddOn(int eventId, int serviceId);
}

class EventAddOnsRemoteDataSourceImpl implements EventAddOnsRemoteDataSource {
  final ApiConsumer apiConsumer;

  EventAddOnsRemoteDataSourceImpl({required this.apiConsumer});

  Map<String, dynamic> _map(dynamic response) =>
      response is Map ? Map<String, dynamic>.from(response) : const {};

  @override
  Future<EventAddOnsModel> getAddOns(int eventId) async =>
      EventAddOnsModel.fromJson(_map(await apiConsumer.get(Endpoints.eventAddOns(eventId))));

  @override
  Future<EventAddOnsModel> requestAddOn(int eventId, int serviceId, {String? notes}) async {
    final response = await apiConsumer.post(
      Endpoints.eventAddOns(eventId),
      body: {
        'extra_service_id': serviceId,
        'quantity': 1,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
    );
    return EventAddOnsModel.fromJson(_map(response));
  }

  @override
  Future<EventAddOnsModel> withdrawAddOn(int eventId, int serviceId) async =>
      EventAddOnsModel.fromJson(_map(await apiConsumer.delete(Endpoints.eventAddOn(eventId, serviceId))));
}
