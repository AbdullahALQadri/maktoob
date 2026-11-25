import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/guest_group.dart';
import '../repositories/guest_groups_repository.dart';

class GetGuestGroupsUseCase implements UseCase<GuestGroupsOverview, NoParams> {
  GetGuestGroupsUseCase(this.repository);

  final GuestGroupsRepository repository;

  @override
  Future<Either<Failure, GuestGroupsOverview>> call(NoParams params) => repository.groups();
}

class GetGuestGroupUseCase implements UseCase<GuestGroup, int> {
  GetGuestGroupUseCase(this.repository);

  final GuestGroupsRepository repository;

  @override
  Future<Either<Failure, GuestGroup>> call(int id) => repository.group(id);
}

class CreateGuestGroupUseCase implements UseCase<GuestGroup, String> {
  CreateGuestGroupUseCase(this.repository);

  final GuestGroupsRepository repository;

  @override
  Future<Either<Failure, GuestGroup>> call(String name) => repository.create(name.trim());
}

class DeleteGuestGroupUseCase implements UseCase<Unit, int> {
  DeleteGuestGroupUseCase(this.repository);

  final GuestGroupsRepository repository;

  @override
  Future<Either<Failure, Unit>> call(int id) => repository.delete(id);
}

/// One change to an open group: a new name, people added, someone removed.
class ChangeGuestGroupUseCase implements UseCase<GuestGroup, GuestGroupChange> {
  ChangeGuestGroupUseCase(this.repository);

  final GuestGroupsRepository repository;

  @override
  Future<Either<Failure, GuestGroup>> call(GuestGroupChange change) {
    if (change.name != null) return repository.rename(change.groupId, change.name!.trim());
    if (change.removeGuestId != null) return repository.removeGuest(change.groupId, change.removeGuestId!);
    return repository.addGuests(change.groupId, change.addGuests);
  }
}

class GuestGroupChange extends Equatable {
  const GuestGroupChange.rename(this.groupId, String this.name)
      : addGuests = const [],
        removeGuestId = null;

  const GuestGroupChange.add(this.groupId, this.addGuests)
      : name = null,
        removeGuestId = null;

  const GuestGroupChange.remove(this.groupId, int this.removeGuestId)
      : name = null,
        addGuests = const [];

  final int groupId;
  final String? name;
  final List<GroupGuest> addGuests;
  final int? removeGuestId;

  @override
  List<Object?> get props => [groupId, name, addGuests, removeGuestId];
}
