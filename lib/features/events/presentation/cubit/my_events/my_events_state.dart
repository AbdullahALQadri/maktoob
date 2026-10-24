import 'package:equatable/equatable.dart';

import '../../../domain/entities/event_card.dart';
import '../../../domain/entities/event_entity.dart';
import '../../../domain/entities/event_page.dart';

enum MyEventsPhase { loading, loaded, loadingMore, failed }

class MyEventsState extends Equatable {
  const MyEventsState({
    this.phase = MyEventsPhase.loading,
    this.status,
    this.query = '',
    this.items = const [],
    this.counts = const EventCounts(),
    this.page = 0,
    this.lastPage = 1,
    this.savedAgo,
    this.error,
  });

  final MyEventsPhase phase;

  /// The status tab; null is "All".
  final EventStatus? status;
  final String query;
  final List<EventCard> items;
  final EventCounts counts;
  final int page;
  final int lastPage;

  /// Set when the list is the last saved copy (offline).
  final Duration? savedAgo;
  final String? error;

  bool get hasMore => page < lastPage;
  bool get isFiltered => status != null || query.isNotEmpty;

  /// Another tab or search: the list starts over.
  MyEventsState filtered({EventStatus? status, required String query}) =>
      MyEventsState(status: status, query: query, counts: counts, savedAgo: savedAgo);

  MyEventsState copyWith({
    MyEventsPhase? phase,
    List<EventCard>? items,
    EventCounts? counts,
    int? page,
    int? lastPage,
    Duration? savedAgo,
    bool fresh = false,
    String? error,
  }) => MyEventsState(
    phase: phase ?? this.phase,
    status: status,
    query: query,
    items: items ?? this.items,
    counts: counts ?? this.counts,
    page: page ?? this.page,
    lastPage: lastPage ?? this.lastPage,
    savedAgo: fresh ? savedAgo : (savedAgo ?? this.savedAgo),
    error: error,
  );

  @override
  List<Object?> get props => [phase, status, query, items, counts, page, lastPage, savedAgo, error];
}
