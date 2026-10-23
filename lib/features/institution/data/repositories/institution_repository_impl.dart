import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/institution_entity.dart';
import '../../domain/repositories/institution_repository.dart';
import '../datasources/institution_remote_data_source.dart';

class InstitutionRepositoryImpl implements InstitutionRepository {
  final InstitutionRemoteDataSource remoteDataSource;

  InstitutionRepositoryImpl({required this.remoteDataSource});

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() call) async {
    try {
      return Right(await call());
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on NoInternetConnectionException {
      return const Left(NetworkFailure(message: 'No internet connection'));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, InstitutionOverviewEntity>> getOverview() =>
      _guard(remoteDataSource.getOverview);

  @override
  Future<Either<Failure, InstitutionOverviewEntity>> saveProfile(InstitutionProfileInput input) =>
      _guard(() => remoteDataSource.saveProfile(input));

  @override
  Future<Either<Failure, List<InstitutionMemberEntity>>> getMembers() =>
      _guard(remoteDataSource.getMembers);

  @override
  Future<Either<Failure, void>> inviteMember({required String phone, required String role}) =>
      _guard(() => remoteDataSource.inviteMember(phone: phone, role: role));

  @override
  Future<Either<Failure, void>> updateMemberRole(int memberId, String role) =>
      _guard(() => remoteDataSource.updateMemberRole(memberId, role));

  @override
  Future<Either<Failure, void>> removeMember(int memberId) =>
      _guard(() => remoteDataSource.removeMember(memberId));

  @override
  Future<Either<Failure, void>> acceptInvite(int inviteId) =>
      _guard(() => remoteDataSource.acceptInvite(inviteId));

  @override
  Future<Either<Failure, void>> declineInvite(int inviteId) =>
      _guard(() => remoteDataSource.declineInvite(inviteId));

  @override
  Future<Either<Failure, InstitutionCreditsEntity>> getCredits() =>
      _guard(remoteDataSource.getCredits);

  @override
  Future<Either<Failure, InstitutionOverviewEntity>> uploadDocument({required String type, required String filePath}) =>
      _guard(() => remoteDataSource.uploadDocument(type: type, filePath: filePath));

  @override
  Future<Either<Failure, InstitutionOverviewEntity>> deleteDocument(int documentId) =>
      _guard(() => remoteDataSource.deleteDocument(documentId));
}
