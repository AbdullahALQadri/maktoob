import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/identity_entities.dart';
import '../repositories/identity_repository.dart';

class SubmitIdentityUseCase implements UseCase<IdentityStateEntity, IdentitySubmissionInput> {
  final IdentityRepository repository;

  SubmitIdentityUseCase(this.repository);

  @override
  Future<Either<Failure, IdentityStateEntity>> call(IdentitySubmissionInput params) =>
      repository.submit(params);
}
