import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/identity_entities.dart';
import '../../domain/identity_failures.dart';
import '../../domain/repositories/identity_repository.dart';
import '../datasources/identity_remote_data_source.dart';

class IdentityRepositoryImpl implements IdentityRepository {
  final IdentityRemoteDataSource remoteDataSource;
  final NetworkInfo? networkInfo;

  IdentityRepositoryImpl({required this.remoteDataSource, this.networkInfo});

  @override
  Future<Either<Failure, IdentityOverviewEntity>> getOverview({String? locale}) =>
      _guard(() => remoteDataSource.getOverview(locale: locale));

  /// Photos are uploaded live: offline, nothing is queued (the screen says
  /// a connection is needed) because ID images must not sit in a queue.
  @override
  Future<Either<Failure, IdentityStateEntity>> submit(IdentitySubmissionInput input) async {
    if (networkInfo != null && !await networkInfo!.isConnected) {
      return const Left(NetworkFailure(message: 'identity_needs_connection'));
    }
    return _guard(() => remoteDataSource.submit(input));
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() call) async {
    try {
      return Right(await call());
    } on ValidationException catch (e) {
      return Left(IdentityValidationFailure(
        message: e.message,
        code: e.code,
        fieldErrors: {
          for (final entry in e.errors.entries)
            if (entry.value.isNotEmpty) entry.key: entry.value.first,
        },
      ));
    } on NoInternetConnectionException {
      return const Left(NetworkFailure(message: 'identity_needs_connection'));
    } on NetworkException {
      return const Left(NetworkFailure(message: 'identity_needs_connection'));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
