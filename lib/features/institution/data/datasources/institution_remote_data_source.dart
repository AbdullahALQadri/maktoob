import 'package:dio/dio.dart' show MultipartFile;

import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/end_points.dart';
import '../../domain/entities/institution_entity.dart';
import '../models/institution_models.dart';

/// `/institution/*` (auth:sanctum + client). New endpoints use the
/// `{success, message, data}` envelope.
abstract class InstitutionRemoteDataSource {
  Future<InstitutionOverviewModel> getOverview();
  Future<InstitutionOverviewModel> saveProfile(InstitutionProfileInput input);
  Future<List<InstitutionMemberModel>> getMembers();
  Future<void> inviteMember({required String phone, required String role});
  Future<void> updateMemberRole(int memberId, String role);
  Future<void> removeMember(int memberId);
  Future<void> acceptInvite(int inviteId);
  Future<void> declineInvite(int inviteId);
  Future<InstitutionCreditsModel> getCredits();
  Future<InstitutionOverviewModel> uploadDocument({required String type, required String filePath});
  Future<InstitutionOverviewModel> deleteDocument(int documentId);
}

class InstitutionRemoteDataSourceImpl implements InstitutionRemoteDataSource {
  final ApiConsumer apiConsumer;

  InstitutionRemoteDataSourceImpl({required this.apiConsumer});

  @override
  Future<InstitutionOverviewModel> getOverview() async {
    final response = await apiConsumer.get(Endpoints.institution);
    return InstitutionOverviewModel.fromJson(response);
  }

  @override
  Future<InstitutionOverviewModel> saveProfile(InstitutionProfileInput input) async {
    final logo = input.logoPath;
    final response = await apiConsumer.post(
      Endpoints.institutionProfile,
      body: {
        ...input.toFields(),
        // A MultipartFile makes DioConsumer send multipart/form-data.
        if (logo != null && logo.isNotEmpty)
          'logo': await MultipartFile.fromFile(logo, filename: logo.split('/').last),
      },
    );
    return InstitutionOverviewModel.fromJson(response);
  }

  @override
  Future<List<InstitutionMemberModel>> getMembers() async {
    final response = await apiConsumer.get(Endpoints.institutionMembers);
    return InstitutionMemberModel.listFrom(response);
  }

  @override
  Future<void> inviteMember({required String phone, required String role}) async {
    await apiConsumer.post(Endpoints.institutionMembers, body: {'phone': phone, 'role': role});
  }

  @override
  Future<void> updateMemberRole(int memberId, String role) async {
    await apiConsumer.put(Endpoints.institutionMember(memberId), body: {'role': role});
  }

  @override
  Future<void> removeMember(int memberId) async {
    await apiConsumer.delete(Endpoints.institutionMember(memberId));
  }

  @override
  Future<void> acceptInvite(int inviteId) async {
    await apiConsumer.post(Endpoints.institutionInviteAccept(inviteId));
  }

  @override
  Future<void> declineInvite(int inviteId) async {
    await apiConsumer.delete(Endpoints.institutionInvite(inviteId));
  }

  @override
  Future<InstitutionCreditsModel> getCredits() async {
    final response = await apiConsumer.get(Endpoints.institutionCredits);
    return InstitutionCreditsModel.fromJson(response);
  }

  @override
  Future<InstitutionOverviewModel> uploadDocument({required String type, required String filePath}) async {
    final response = await apiConsumer.post(
      Endpoints.institutionDocuments,
      body: {
        'type': type,
        'file': await MultipartFile.fromFile(filePath, filename: filePath.split('/').last),
      },
    );
    return InstitutionOverviewModel.fromJson(response);
  }

  @override
  Future<InstitutionOverviewModel> deleteDocument(int documentId) async {
    final response = await apiConsumer.delete(Endpoints.institutionDocument(documentId));
    return InstitutionOverviewModel.fromJson(response);
  }
}
