import 'package:dio/dio.dart' show MultipartFile;

import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/end_points.dart';
import '../../domain/entities/identity_entities.dart';
import '../models/identity_models.dart';

/// `/auth/identity` (auth:sanctum + client), `{success, message, data}` envelope.
abstract class IdentityRemoteDataSource {
  Future<IdentityOverviewModel> getOverview({String? locale});
  Future<IdentityStateModel> submit(IdentitySubmissionInput input);
}

class IdentityRemoteDataSourceImpl implements IdentityRemoteDataSource {
  final ApiConsumer apiConsumer;

  IdentityRemoteDataSourceImpl({required this.apiConsumer});

  @override
  Future<IdentityOverviewModel> getOverview({String? locale}) async {
    final response = await apiConsumer.get(
      Endpoints.clientIdentity,
      queryParameters: {'locale': ?locale},
    );
    return IdentityOverviewModel.fromJson(response);
  }

  @override
  Future<IdentityStateModel> submit(IdentitySubmissionInput input) async {
    final back = input.backPath;
    final response = await apiConsumer.post(
      Endpoints.clientIdentity,
      body: {
        ...input.toFields(),
        // A MultipartFile makes DioConsumer send multipart/form-data.
        'front': await MultipartFile.fromFile(input.frontPath, filename: _fileName(input.frontPath)),
        if (back != null && back.isNotEmpty) 'back': await MultipartFile.fromFile(back, filename: _fileName(back)),
      },
    );
    final data = response is Map ? (response['data'] ?? response) : null;
    return IdentityStateModel.tryParse(data is Map ? data['identity'] : null) ?? const IdentityStateModel();
  }

  static String _fileName(String path) => path.split(RegExp(r'[\\/]')).last;
}
