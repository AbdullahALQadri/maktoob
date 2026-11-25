import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/repository_guard.dart';
import '../../domain/entities/upgrade_options.dart';
import '../../domain/repositories/billing_repository.dart';
import '../datasources/billing_remote_data_source.dart';

class BillingRepositoryImpl implements BillingRepository {
  BillingRepositoryImpl({required this.remoteDataSource});

  final BillingRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, UpgradeOptions>> upgradeOptions(String eventId) =>
      guardCall(() => remoteDataSource.upgradeOptions(eventId));

  @override
  Future<Either<Failure, UpgradeQuote>> customUpgradeQuote(String eventId, int invitations) =>
      guardCall(() => remoteDataSource.customUpgradeQuote(eventId, invitations));

  @override
  Future<Either<Failure, String>> proformaUrl(String eventId, {String? funder, String? reference}) =>
      guardCall(() => remoteDataSource.proformaUrl(eventId, funder: funder, reference: reference));
}
