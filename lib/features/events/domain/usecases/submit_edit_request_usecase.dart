import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/edit_request_entity.dart';
import '../repositories/events_repository.dart';

class SubmitEditRequestUseCase
    implements UseCase<EditRequestEntity, SubmitEditRequestParams> {
  final EventsRepository repository;

  SubmitEditRequestUseCase(this.repository);

  @override
  Future<Either<Failure, EditRequestEntity>> call(
      SubmitEditRequestParams params) async {
    return await repository.submitEditRequest(params.eventId, params.changes);
  }
}

class SubmitEditRequestParams extends Equatable {
  final String eventId;
  final UpdateEventParams changes;

  const SubmitEditRequestParams({
    required this.eventId,
    required this.changes,
  });

  @override
  List<Object?> get props => [eventId, changes];
}
