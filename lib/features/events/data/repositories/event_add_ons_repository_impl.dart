import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/event_add_ons_entity.dart';
import '../../domain/repositories/event_add_ons_repository.dart';
import '../datasources/event_add_ons_remote_data_source.dart';

class EventAddOnsRepositoryImpl implements EventAddOnsRepository {
  final EventAddOnsRemoteDataSource remoteDataSource;

  EventAddOnsRepositoryImpl({required this.remoteDataSource});

  Future<Either<Failure, EventAddOnsEntity>> _run(Future<EventAddOnsEntity> Function() call) async {
    try {
      return Right(await call());
    } on AppException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnexpectedFailure(message: '$e'));
    }
  }

  @override
  Future<Either<Failure, EventAddOnsEntity>> getAddOns(int eventId) =>
      _run(() => remoteDataSource.getAddOns(eventId));

  @override
  Future<Either<Failure, EventAddOnsEntity>> requestAddOn(int eventId, int serviceId, {String? notes}) =>
      _run(() => remoteDataSource.requestAddOn(eventId, serviceId, notes: notes));

  @override
  Future<Either<Failure, EventAddOnsEntity>> withdrawAddOn(int eventId, int serviceId) =>
      _run(() => remoteDataSource.withdrawAddOn(eventId, serviceId));
}
