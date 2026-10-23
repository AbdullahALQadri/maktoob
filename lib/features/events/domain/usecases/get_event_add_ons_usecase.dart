import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/event_add_ons_entity.dart';
import '../repositories/event_add_ons_repository.dart';

class GetEventAddOnsUseCase {
  final EventAddOnsRepository repository;

  GetEventAddOnsUseCase(this.repository);

  Future<Either<Failure, EventAddOnsEntity>> call(int eventId) => repository.getAddOns(eventId);
}
