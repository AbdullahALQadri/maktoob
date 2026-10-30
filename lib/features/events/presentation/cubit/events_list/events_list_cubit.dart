import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../domain/entities/event_entity.dart';
import '../../../domain/usecases/get_events_usecase.dart';
import '../../../domain/usecases/filter_events_usecase.dart';
import 'events_list_state.dart';

class EventsListCubit extends Cubit<EventsListState> {
  final GetEventsUseCase getEventsUseCase;
  final FilterEventsUseCase filterEventsUseCase;

  EventsListCubit({
    required this.getEventsUseCase,
    required this.filterEventsUseCase,
  }) : super(const EventsListState());

  /// Load all events
  Future<void> loadEvents() async {
    emit(state.copyWith(status: EventsListStatus.loading, clearErrorMessage: true));

    final result = await getEventsUseCase(const NoParams());

    result.fold(
      (failure) => emit(state.copyWith(
        status: EventsListStatus.failure,
        errorMessage: failure.message,
      )),
      (events) => emit(state.copyWith(
        status: EventsListStatus.success,
        events: events,
        filteredEvents: _applyFilters(events, state.searchQuery, state.filterStatus),
        clearErrorMessage: true,
      )),
    );
  }

  /// Clear all filters
  void clearFilters() {
    emit(state.copyWith(
      searchQuery: '',
      clearFilterStatus: true,
      filteredEvents: state.events,
    ));
  }

  /// Refresh events
  Future<void> refreshEvents() async {
    await loadEvents();
  }

  /// Apply filters to events list
  List<EventEntity> _applyFilters(
    List<EventEntity> events,
    String searchQuery,
    EventStatus? filterStatus,
  ) {
    return events.where((event) {
      // Filter by search query
      final matchesSearch = searchQuery.isEmpty ||
          event.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          event.type.toLowerCase().contains(searchQuery.toLowerCase()) ||
          event.venue.toLowerCase().contains(searchQuery.toLowerCase());

      // Filter by status
      final matchesFilter = filterStatus == null || event.status == filterStatus;

      return matchesSearch && matchesFilter;
    }).toList();
  }

}
