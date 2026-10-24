import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/identity_entities.dart';

abstract class IdentityRepository {
  /// `GET /auth/identity`: state, my submissions and the form's options
  /// (labels in [locale] when given).
  Future<Either<Failure, IdentityOverviewEntity>> getOverview({String? locale});

  /// `POST /auth/identity`: a new submission (replaces a pending one).
  Future<Either<Failure, IdentityStateEntity>> submit(IdentitySubmissionInput input);
}
