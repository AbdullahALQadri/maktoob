import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/invitation_entity.dart';
import '../repositories/invitation_repository.dart';

class LoadEventTypesUseCase implements UseCase<List<EventTypeEntity>, NoParams> {
  final InvitationRepository repository;

  LoadEventTypesUseCase(this.repository);

  @override
  Future<Either<Failure, List<EventTypeEntity>>> call(NoParams params) {
    return repository.getEventTypes();
  }
}
