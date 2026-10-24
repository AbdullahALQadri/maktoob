import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/end_points.dart';
import '../models/home_summary_model.dart';

abstract class HomeRemoteDataSource {
  Future<HomeSummaryModel> getHome();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  const HomeRemoteDataSourceImpl({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  /// The offline cache (DioConsumer) answers with the last saved copy when
  /// the phone has no connection, so no local copy is kept here.
  @override
  Future<HomeSummaryModel> getHome() async {
    final response = await apiConsumer.get(Endpoints.clientHome);
    return HomeSummaryModel.fromResponse(Map<String, dynamic>.from(response as Map));
  }
}
