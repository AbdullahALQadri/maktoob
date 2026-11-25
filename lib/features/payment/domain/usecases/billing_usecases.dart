import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/upgrade_options.dart';
import '../repositories/billing_repository.dart';

class GetUpgradeOptionsUseCase implements UseCase<UpgradeOptions, String> {
  GetUpgradeOptionsUseCase(this.repository);

  final BillingRepository repository;

  @override
  Future<Either<Failure, UpgradeOptions>> call(String eventId) => repository.upgradeOptions(eventId);
}

class GetCustomUpgradeQuoteUseCase implements UseCase<UpgradeQuote, CustomUpgradeParams> {
  GetCustomUpgradeQuoteUseCase(this.repository);

  final BillingRepository repository;

  @override
  Future<Either<Failure, UpgradeQuote>> call(CustomUpgradeParams params) =>
      repository.customUpgradeQuote(params.eventId, params.invitations);
}

class CustomUpgradeParams extends Equatable {
  const CustomUpgradeParams({required this.eventId, required this.invitations});

  final String eventId;
  final int invitations;

  @override
  List<Object?> get props => [eventId, invitations];
}

class GetProformaUrlUseCase implements UseCase<String, ProformaParams> {
  GetProformaUrlUseCase(this.repository);

  final BillingRepository repository;

  @override
  Future<Either<Failure, String>> call(ProformaParams params) =>
      repository.proformaUrl(params.eventId, funder: params.funder, reference: params.reference);
}

class ProformaParams extends Equatable {
  const ProformaParams({required this.eventId, this.funder, this.reference});

  final String eventId;

  /// Whom the invoice is addressed to (a funder, a head office).
  final String? funder;

  /// A grant, project or purchase order number.
  final String? reference;

  @override
  List<Object?> get props => [eventId, funder, reference];
}
