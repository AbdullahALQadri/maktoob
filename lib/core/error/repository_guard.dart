import 'package:dartz/dartz.dart';

import 'exceptions.dart';
import 'failures.dart';

/// Runs a data-source call and turns its exceptions into the matching
/// [Failure], so repositories stay one line per method.
Future<Either<Failure, T>> guardCall<T>(Future<T> Function() call) async {
  try {
    return Right(await call());
  } on ValidationException catch (e) {
    return Left(ValidationFailure(message: e.message));
  } on NetworkException catch (e) {
    return Left(NetworkFailure(message: e.message));
  } on UnauthorizedException catch (e) {
    return Left(AuthenticationFailure(message: e.message, code: e.code));
  } on ServerException catch (e) {
    return Left(ServerFailure(message: e.message, code: e.code));
  } catch (e) {
    return Left(UnexpectedFailure(message: e.toString()));
  }
}
