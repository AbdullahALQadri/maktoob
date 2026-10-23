import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/event_add_ons_entity.dart';

abstract class EventAddOnsRepository {
  Future<Either<Failure, EventAddOnsEntity>> getAddOns(int eventId);

  Future<Either<Failure, EventAddOnsEntity>> requestAddOn(int eventId, int serviceId, {String? notes});

  Future<Either<Failure, EventAddOnsEntity>> withdrawAddOn(int eventId, int serviceId);
}
