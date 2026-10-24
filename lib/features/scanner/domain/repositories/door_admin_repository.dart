import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/door_models.dart';
import '../entities/door_entities.dart';

/// The host's management of an event's doors (needs a connection): gates,
/// door codes for staff phones, the phones themselves and the entry report.
abstract class DoorAdminRepository {
  Future<Either<Failure, DoorSummaryModel>> summary(DoorSession session);
  Future<Either<Failure, List<DoorGate>>> gates(DoorSession session);
  Future<Either<Failure, DoorGate>> addGate(DoorSession session, String name, String audience);
  Future<Either<Failure, DoorGate>> updateGate(
    DoorSession session,
    int id, {
    String? name,
    String? audience,
    bool? active,
  });
  Future<Either<Failure, void>> deleteGate(DoorSession session, int id);
  Future<Either<Failure, List<DoorCodeModel>>> codes(DoorSession session);
  Future<Either<Failure, DoorCodeCreated>> createCode(
    DoorSession session, {
    String? label,
    int? gateId,
    int? maxDevices,
  });
  Future<Either<Failure, void>> cancelCode(DoorSession session, int id);
  Future<Either<Failure, void>> removeDevice(DoorSession session, int id);
}
