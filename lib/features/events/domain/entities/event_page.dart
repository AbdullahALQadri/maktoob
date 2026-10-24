import 'package:equatable/equatable.dart';

import 'event_card.dart';
import 'event_entity.dart';

/// How many events the host has in each status (the filter tabs).
class EventCounts extends Equatable {
  const EventCounts({this.all = 0, this.byStatus = const {}});

  final int all;
  final Map<EventStatus, int> byStatus;

  /// [status] null means all of them.
  int of(EventStatus? status) => status == null ? all : (byStatus[status] ?? 0);

  @override
  List<Object?> get props => [all, byStatus];
}

/// One page of "My events" (backend `GET /client/events`).
class EventPage extends Equatable {
  const EventPage({
    required this.items,
    required this.page,
    required this.lastPage,
    required this.counts,
    this.savedAgo,
  });

  final List<EventCard> items;
  final int page;
  final int lastPage;
  final EventCounts counts;

  /// Set when the phone is offline and this is the last saved copy.
  final Duration? savedAgo;

  bool get hasMore => page < lastPage;

  @override
  List<Object?> get props => [items, page, lastPage, counts, savedAgo];
}
