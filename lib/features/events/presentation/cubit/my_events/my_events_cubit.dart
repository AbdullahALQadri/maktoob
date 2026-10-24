import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/event_entity.dart';
import '../../../domain/usecases/get_my_events_usecase.dart';
import 'my_events_state.dart';

/// "My events": status tabs with counts, title search (as the host types),
/// and the next page as the list scrolls. A newer request always wins over
/// a slower older one.
class MyEventsCubit extends Cubit<MyEventsState> {
  MyEventsCubit({required this.getPage}) : super(const MyEventsState());

  final GetMyEventsUseCase getPage;
  Timer? _typing;
  int _request = 0;

  /// The first page; what is on screen is replaced when it arrives.
  Future<void> load() => _fetch(page: 1, keepItems: false);

  /// Pull to refresh: the list stays until the new one arrives.
  Future<void> refresh() => _fetch(page: 1, keepItems: true);

  void showStatus(EventStatus? status) {
    if (status == state.status) return;
    emit(state.filtered(status: status, query: state.query));
    load();
  }

  void search(String text) {
    _typing?.cancel();
    _typing = Timer(const Duration(milliseconds: 350), () {
      final query = text.trim();
      if (isClosed || query == state.query) return;
      emit(state.filtered(status: state.status, query: query));
      load();
    });
  }

  /// Back to every event: no status tab, no search.
  void clearFilters() {
    _typing?.cancel();
    emit(state.filtered(status: null, query: ''));
    load();
  }

  Future<void> loadMore() async {
    if (state.phase != MyEventsPhase.loaded || !state.hasMore) return;
    await _fetch(page: state.page + 1, keepItems: true);
  }

  Future<void> _fetch({required int page, required bool keepItems}) async {
    final ticket = ++_request;
    if (page > 1) {
      emit(state.copyWith(phase: MyEventsPhase.loadingMore));
    } else if (!keepItems || state.items.isEmpty) {
      emit(state.copyWith(phase: MyEventsPhase.loading, items: const []));
    }

    final result = await getPage(status: state.status, query: state.query, page: page);
    if (isClosed || ticket != _request) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          // A failed refresh or next page keeps what the host already sees.
          phase: state.items.isEmpty ? MyEventsPhase.failed : MyEventsPhase.loaded,
          error: failure.message,
        ),
      ),
      (data) => emit(
        state.copyWith(
          phase: MyEventsPhase.loaded,
          items: page == 1 ? data.items : [...state.items, ...data.items],
          counts: data.counts,
          page: data.page,
          lastPage: data.lastPage,
          savedAgo: data.savedAgo,
          fresh: true,
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _typing?.cancel();
    return super.close();
  }
}
