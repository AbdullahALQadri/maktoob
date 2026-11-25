import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/guest_group.dart';

abstract class GuestGroupsRepository {
  Future<Either<Failure, GuestGroupsOverview>> groups();

  /// The group with its people.
  Future<Either<Failure, GuestGroup>> group(int id);
  Future<Either<Failure, GuestGroup>> create(String name, {List<GroupGuest> guests = const []});
  Future<Either<Failure, GuestGroup>> rename(int id, String name);

  /// Adds people, keeping the ones already in the group.
  Future<Either<Failure, GuestGroup>> addGuests(int id, List<GroupGuest> guests);
  Future<Either<Failure, GuestGroup>> removeGuest(int id, int guestId);

  /// Deletes the group; its people stay in the guest book.
  Future<Either<Failure, Unit>> delete(int id);
}
