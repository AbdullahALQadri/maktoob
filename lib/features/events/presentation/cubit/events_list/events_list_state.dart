import 'package:equatable/equatable.dart';
import '../../../domain/entities/event_entity.dart';

enum EventsListStatus { initial, loading, success, failure }

class EventsListState extends Equatable {
  final EventsListStatus status;
  final List<EventEntity> events;
  final List<EventEntity> filteredEvents;
  final String searchQuery;
  final EventStatus? filterStatus;
  final String? errorMessage;

  const EventsListState({
    this.status = EventsListStatus.initial,
    this.events = const [],
    this.filteredEvents = const [],
    this.searchQuery = '',
    this.filterStatus,
    this.errorMessage,
  });

  bool get isLoading => status == EventsListStatus.loading;
  bool get isSuccess => status == EventsListStatus.success;
  bool get isFailure => status == EventsListStatus.failure;
  bool get isEmpty => filteredEvents.isEmpty && status == EventsListStatus.success;

  int get totalEvents => events.length;
  int get activeEvents => events.where((e) => e.status == EventStatus.active).length;
  int get draftEvents => events.where((e) => e.status == EventStatus.draft).length;
  int get completedEvents => events.where((e) => e.status == EventStatus.completed).length;

  EventsListState copyWith({
    EventsListStatus? status,
    List<EventEntity>? events,
    List<EventEntity>? filteredEvents,
    String? searchQuery,
    EventStatus? filterStatus,
    bool clearFilterStatus = false,
    String? errorMessage,
  }) {
    return EventsListState(
      status: status ?? this.status,
      events: events ?? this.events,
      filteredEvents: filteredEvents ?? this.filteredEvents,
      searchQuery: searchQuery ?? this.searchQuery,
      filterStatus: clearFilterStatus ? null : (filterStatus ?? this.filterStatus),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        events,
        filteredEvents,
        searchQuery,
        filterStatus,
        errorMessage,
      ];
}
