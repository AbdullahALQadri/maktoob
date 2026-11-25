import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/guest_group.dart';
import '../../domain/usecases/guest_group_usecases.dart';
import 'guest_groups_state.dart';

/// "Guest groups": the list, and making a new one.
class GuestGroupsCubit extends Cubit<GuestGroupsState> {
  GuestGroupsCubit({required this.getGroups, required this.createGroup}) : super(const GuestGroupsState());

  final GetGuestGroupsUseCase getGroups;
  final CreateGuestGroupUseCase createGroup;

  Future<void> load() async {
    // What is shown stays while refreshing.
    if (state.overview == null) emit(const GuestGroupsState());
    final result = await getGroups(const NoParams());
    if (isClosed) return;
    emit(result.fold(
      (failure) => state.copyWith(loading: false, message: failure.message ?? ''),
      (overview) => GuestGroupsState(overview: overview, loading: false),
    ));
  }

  /// Makes a group and returns it, or null when it was refused.
  Future<GuestGroup?> create(String name) async {
    if (name.trim().isEmpty) return null;
    emit(state.copyWith(busy: true));
    final result = await createGroup(name);
    if (isClosed) return null;
    final group = result.fold((_) => null, (g) => g);
    emit(state.copyWith(busy: false, message: result.fold((failure) => failure.message ?? '', (_) => null)));
    if (group != null) await load();
    return group;
  }
}
