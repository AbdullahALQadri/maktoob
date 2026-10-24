import 'package:equatable/equatable.dart';

import '../../../events/domain/entities/event_card.dart';

/// The numbers at a glance; same scope and meaning as the web dashboard.
class HomeTotals extends Equatable {
  const HomeTotals({
    this.events = 0,
    this.activeEvents = 0,
    this.invitations = 0,
    this.responses = 0,
    this.responseRate = 0,
  });

  final int events;
  final int activeEvents;
  final int invitations;
  final int responses;

  /// Percent, 0..100.
  final int responseRate;

  @override
  List<Object?> get props => [events, activeEvents, invitations, responses, responseRate];
}

/// Everything the home screen shows, from one call.
class HomeSummary extends Equatable {
  const HomeSummary({
    required this.totals,
    required this.events,
    required this.gazaOffset,
    this.nextEvent,
    this.freeTrialAvailable = false,
    this.savedAgo,
  });

  final HomeTotals totals;

  /// The nearest occasion still coming up: the banner's spotlight.
  final EventCard? nextEvent;

  /// Up to six events, the ones still waiting on the client first.
  final List<EventCard> events;

  /// Individuals get one free first invitation; institutions never do.
  final bool freeTrialAvailable;

  /// Gaza's UTC offset as the server reported it (turns the banner mood).
  final Duration gazaOffset;

  /// Set when the phone is offline and this is the last saved copy.
  final Duration? savedAgo;

  bool get isFirstVisit => totals.events == 0;
  bool get isSavedCopy => savedAgo != null;

  @override
  List<Object?> get props => [totals, nextEvent, events, freeTrialAvailable, gazaOffset, savedAgo];
}
