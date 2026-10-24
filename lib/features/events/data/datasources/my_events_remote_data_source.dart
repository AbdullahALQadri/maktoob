import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/end_points.dart';
import '../../domain/entities/event_entity.dart';
import '../models/event_page_model.dart';

abstract class MyEventsRemoteDataSource {
  Future<EventPageModel> getPage({EventStatus? status, String query = '', int page = 1});
}

class MyEventsRemoteDataSourceImpl implements MyEventsRemoteDataSource {
  const MyEventsRemoteDataSourceImpl({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  static const perPage = 20;

  @override
  Future<EventPageModel> getPage({EventStatus? status, String query = '', int page = 1}) async {
    final response = await apiConsumer.get(
      Endpoints.clientEvents,
      queryParameters: {
        if (status != null) 'status': status.apiValue,
        if (query.isNotEmpty) 'q': query,
        'page': page,
        'per_page': perPage,
      },
    );
    return EventPageModel.fromResponse(Map<String, dynamic>.from(response as Map));
  }
}
