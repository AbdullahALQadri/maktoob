import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/invitation_entity.dart';
import '../repositories/invitation_repository.dart';

class LoadTemplatesUseCase implements UseCase<List<TemplateEntity>, LoadTemplatesParams> {
  final InvitationRepository repository;

  LoadTemplatesUseCase(this.repository);

  @override
  Future<Either<Failure, List<TemplateEntity>>> call(LoadTemplatesParams params) {
    return repository.getTemplatesForEventType(params.eventTypeId);
  }
}

class LoadTemplatesParams extends Equatable {
  final int eventTypeId;

  const LoadTemplatesParams({required this.eventTypeId});

  @override
  List<Object?> get props => [eventTypeId];
}
