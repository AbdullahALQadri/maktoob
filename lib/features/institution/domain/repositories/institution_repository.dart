import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/institution_entity.dart';

abstract class InstitutionRepository {
  Future<Either<Failure, InstitutionOverviewEntity>> getOverview();
  Future<Either<Failure, InstitutionOverviewEntity>> saveProfile(InstitutionProfileInput input);
  Future<Either<Failure, List<InstitutionMemberEntity>>> getMembers();
  Future<Either<Failure, void>> inviteMember({required String phone, required String role});
  Future<Either<Failure, void>> updateMemberRole(int memberId, String role);
  Future<Either<Failure, void>> removeMember(int memberId);
  Future<Either<Failure, void>> acceptInvite(int inviteId);
  Future<Either<Failure, void>> declineInvite(int inviteId);
  Future<Either<Failure, InstitutionCreditsEntity>> getCredits();
  Future<Either<Failure, InstitutionOverviewEntity>> uploadDocument({required String type, required String filePath});
  Future<Either<Failure, InstitutionOverviewEntity>> deleteDocument(int documentId);
}
