import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/end_points.dart';
import '../models/occasion_group_model.dart';
import '../models/template_preview_model.dart';

/// Guest browsing calls. Public endpoints only: an authenticated path here
/// would 401 and trigger AuthCubit.forceLogout() for someone never logged in.
abstract class ExploreRemoteDataSource {
  Future<List<OccasionGroupModel>> getOccasionGroups();

  Future<List<TemplatePreviewModel>> getTemplates({int? eventTypeId});
}

class ExploreRemoteDataSourceImpl implements ExploreRemoteDataSource {
  final ApiConsumer apiConsumer;

  ExploreRemoteDataSourceImpl({required this.apiConsumer});

  @override
  Future<List<OccasionGroupModel>> getOccasionGroups() async {
    final response = await apiConsumer.get(Endpoints.publicEventTypes);
    return OccasionGroupModel.listFromResponse(response);
  }

  @override
  Future<List<TemplatePreviewModel>> getTemplates({int? eventTypeId}) async {
    final response = await apiConsumer.get(
      Endpoints.publicTemplates,
      queryParameters: {'event_type_id': ?eventTypeId},
    );
    return TemplatePreviewModel.listFromResponse(response);
  }
}
