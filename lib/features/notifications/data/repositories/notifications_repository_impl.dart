import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_data_source.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource remoteDataSource;
  NotificationsRepositoryImpl({required this.remoteDataSource});

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() f) async {
    try {
      return Right(await f());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationsPage>> getNotifications({int page = 1}) =>
      _guard(() => remoteDataSource.getNotifications(page: page));

  @override
  Future<Either<Failure, Unit>> markRead(int id) => _guard(() async {
    await remoteDataSource.markRead(id);
    return unit;
  });

  @override
  Future<Either<Failure, Unit>> markAllRead() => _guard(() async {
    await remoteDataSource.markAllRead();
    return unit;
  });
}
