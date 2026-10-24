import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/door_entities.dart';
import '../../domain/repositories/door_admin_repository.dart';
import '../datasources/door_remote_data_source.dart';
import '../models/door_models.dart';

class DoorAdminRepositoryImpl implements DoorAdminRepository {
  final DoorRemoteDataSource remote;

  DoorAdminRepositoryImpl({required this.remote});

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() call) async {
    try {
      return Right(await call());
    } on DoorHttpException catch (e) {
      return Left(switch (e.kind) {
        DoorErrorKind.network => NetworkFailure(message: e.message),
        DoorErrorKind.auth || DoorErrorKind.revoked => AuthenticationFailure(message: e.message),
        _ => ServerFailure(message: e.message, code: e.status),
      });
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DoorSummaryModel>> summary(DoorSession session) => _guard(() => remote.summary(session));

  @override
  Future<Either<Failure, List<DoorGate>>> gates(DoorSession session) => _guard(() => remote.gates(session));

  @override
  Future<Either<Failure, DoorGate>> addGate(DoorSession session, String name, String audience) =>
      _guard(() => remote.addGate(session, name, audience));

  @override
  Future<Either<Failure, DoorGate>> updateGate(
    DoorSession session,
    int id, {
    String? name,
    String? audience,
    bool? active,
  }) => _guard(() => remote.updateGate(session, id, name: name, audience: audience, active: active));

  @override
  Future<Either<Failure, void>> deleteGate(DoorSession session, int id) => _guard(() => remote.deleteGate(session, id));

  @override
  Future<Either<Failure, List<DoorCodeModel>>> codes(DoorSession session) => _guard(() => remote.codes(session));

  @override
  Future<Either<Failure, DoorCodeCreated>> createCode(
    DoorSession session, {
    String? label,
    int? gateId,
    int? maxDevices,
  }) => _guard(() => remote.createCode(session, label: label, gateId: gateId, maxDevices: maxDevices));

  @override
  Future<Either<Failure, void>> cancelCode(DoorSession session, int id) => _guard(() => remote.cancelCode(session, id));

  @override
  Future<Either<Failure, void>> removeDevice(DoorSession session, int id) =>
      _guard(() => remote.removeDevice(session, id));
}
