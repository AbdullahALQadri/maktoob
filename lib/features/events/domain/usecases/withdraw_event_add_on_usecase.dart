import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/event_add_ons_entity.dart';
import '../repositories/event_add_ons_repository.dart';

/// Withdraws a service request before it is paid.
class WithdrawEventAddOnUseCase {
  final EventAddOnsRepository repository;

  WithdrawEventAddOnUseCase(this.repository);

  Future<Either<Failure, EventAddOnsEntity>> call(int eventId, int serviceId) =>
      repository.withdrawAddOn(eventId, serviceId);
}
