import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/invitation_repository.dart';

class SubmitInvitationUseCase implements UseCase<void, SubmitInvitationParams> {
  final InvitationRepository repository;

  SubmitInvitationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SubmitInvitationParams params) {
    return repository.submitAndActivate(params.eventId);
  }
}

class SubmitInvitationParams extends Equatable {
  final int eventId;

  const SubmitInvitationParams({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}
