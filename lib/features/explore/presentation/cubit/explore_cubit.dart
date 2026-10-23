import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_occasion_groups_usecase.dart';
import '../../domain/usecases/get_public_templates_usecase.dart';
import 'explore_state.dart';

/// Drives the browse-without-account home. Public endpoints only.
class ExploreCubit extends Cubit<ExploreState> {
  final GetOccasionGroupsUseCase getOccasionGroupsUseCase;
  final GetPublicTemplatesUseCase getPublicTemplatesUseCase;

  ExploreCubit({
    required this.getOccasionGroupsUseCase,
    required this.getPublicTemplatesUseCase,
  }) : super(const ExploreInitial());

  Future<void> load() async {
    emit(const ExploreLoading());
    final result = await getOccasionGroupsUseCase();
    if (isClosed) return;
    await result.fold(
      (failure) async => emit(ExploreError(failure.message ?? '')),
      (groups) async {
        emit(ExploreLoaded(groups: groups));
        if (groups.isNotEmpty) await selectGroup(groups.first.id);
      },
    );
  }

  Future<void> selectGroup(int groupId) async {
    final current = state;
    if (current is! ExploreLoaded) return;
    final group = current.groups.where((g) => g.id == groupId).firstOrNull;
    if (group == null || group.types.isEmpty) return;
    emit(current.copyWith(selectedGroupId: groupId));
    await selectType(group.types.first.id);
  }

  Future<void> selectType(int typeId) async {
    final current = state;
    if (current is! ExploreLoaded) return;
    emit(current.copyWith(selectedTypeId: typeId, templatesLoading: true));
    final result = await getPublicTemplatesUseCase(eventTypeId: typeId);
    if (isClosed) return;
    final latest = state;
    // Ignore a stale answer if the user picked another type meanwhile.
    if (latest is! ExploreLoaded || latest.selectedTypeId != typeId) return;
    emit(latest.copyWith(
      templates: result.getOrElse(() => const []),
      templatesLoading: false,
    ));
  }
}
