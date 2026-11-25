import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';

import '../../domain/entities/guest_group.dart';
import '../../domain/usecases/guest_group_usecases.dart';
import 'guest_groups_state.dart';

/// One open group: its people, its name, and deleting it.
class GuestGroupCubit extends Cubit<GuestGroupState> {
  GuestGroupCubit({
    required this.getGroup,
    required this.changeGroup,
    required this.deleteGroup,
    required this.groupId,
  }) : super(const GuestGroupState());

  final GetGuestGroupUseCase getGroup;
  final ChangeGuestGroupUseCase changeGroup;
  final DeleteGuestGroupUseCase deleteGroup;
  final int groupId;

  Future<void> load() async {
    final result = await getGroup(groupId);
    if (isClosed) return;
    emit(result.fold(
      (failure) => state.copyWith(loading: false, message: failure.message ?? ''),
      (group) => GuestGroupState(group: group, loading: false),
    ));
  }

  Future<bool> rename(String name) => _change(GuestGroupChange.rename(groupId, name));

  Future<bool> addGuest(String name, String phone) =>
      _change(GuestGroupChange.add(groupId, [GroupGuest(name: name, phone: phone)]));

  Future<bool> removeGuest(int guestId) => _change(GuestGroupChange.remove(groupId, guestId));

  Future<void> delete() async {
    emit(state.copyWith(busy: true));
    final result = await deleteGroup(groupId);
    if (isClosed) return;
    emit(result.fold(
      // No connection: it is deleted when it returns; the screen closes now.
      (failure) => state.copyWith(busy: false, message: failure.message ?? '', deleted: failure is QueuedOfflineFailure),
      (_) => state.copyWith(busy: false, deleted: true),
    ));
  }

  /// The open group with [change] made on the phone.
  GuestGroup? _applied(GuestGroupChange change) {
    final group = state.group;
    if (group == null) return null;
    final guests = change.removeGuestId != null
        ? group.guests.where((g) => g.id != change.removeGuestId).toList()
        : [...group.guests, ...change.addGuests];
    return GuestGroup(id: group.id, name: change.name ?? group.name, guestsCount: guests.length, guests: guests);
  }

  /// True when the change was saved (or queued for when the connection
  /// returns); the group shown is then the new one.
  Future<bool> _change(GuestGroupChange change) async {
    emit(state.copyWith(busy: true));
    final result = await changeGroup(change);
    if (isClosed) return false;
    emit(result.fold(
      (failure) => state.copyWith(
        busy: false,
        message: failure.message ?? '',
        // No connection: the change is queued, and shown as it will be.
        group: failure is QueuedOfflineFailure ? _applied(change) : null,
      ),
      (group) => GuestGroupState(group: group, loading: false),
    ));
    return result.isRight() || result.fold((failure) => failure is QueuedOfflineFailure, (_) => false);
  }
}
