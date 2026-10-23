import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/event_add_ons_entity.dart';
import '../repositories/event_add_ons_repository.dart';

/// Asks for a service on a paid event. The team confirms it is available
/// before the host pays — and the host pays only that service's price.
class RequestEventAddOnUseCase {
  final EventAddOnsRepository repository;

  RequestEventAddOnUseCase(this.repository);

  Future<Either<Failure, EventAddOnsEntity>> call(int eventId, int serviceId, {String? notes}) =>
      repository.requestAddOn(eventId, serviceId, notes: notes);
}
