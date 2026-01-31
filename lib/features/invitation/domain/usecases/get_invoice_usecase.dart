import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/invitation_entity.dart';
import '../repositories/invitation_repository.dart';

class GetInvoiceUseCase implements UseCase<InvoiceEntity, GetInvoiceParams> {
  final InvitationRepository repository;

  GetInvoiceUseCase(this.repository);

  @override
  Future<Either<Failure, InvoiceEntity>> call(GetInvoiceParams params) {
    return repository.getInvoiceSummary(params.eventId);
  }
}

class GetInvoiceParams extends Equatable {
  final int eventId;

  const GetInvoiceParams({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}
