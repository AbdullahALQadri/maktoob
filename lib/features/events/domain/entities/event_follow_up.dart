import 'package:equatable/equatable.dart';

import 'event_card.dart';

/// One line of the event's activity: a guest opened the invitation or
/// answered it (backend `EventFollowUp::activity`).
class ActivityItem extends Equatable {
  const ActivityItem({
    required this.invitationId,
    required this.replied,
    required this.name,
    this.reply,
    this.companions = 0,
    this.at,
  });

  final int invitationId;

  /// False when the guest only opened the invitation.
  final bool replied;

  /// `attending`, `not_attending` or `maybe` when [replied].
  final String? reply;
  final String name;
  final int companions;

  /// Wall-clock Gaza time.
  final DateTime? at;

  @override
  List<Object?> get props => [invitationId, replied, reply, name, companions, at];
}

/// One of the portal's six setup steps of an event.
class SetupStep extends Equatable {
  const SetupStep({required this.key, required this.done, required this.current});

  /// details, guests, design, settings, checkout, send.
  final String key;
  final bool done;
  final bool current;

  @override
  List<Object?> get props => [key, done, current];
}

/// Where a draft or an event awaiting payment stands (backend
/// `GET /events/{id}/progress`).
class EventProgress extends Equatable {
  const EventProgress({required this.inSetup, required this.nextAction, required this.steps});

  final bool inSetup;
  final NextAction nextAction;
  final List<SetupStep> steps;

  @override
  List<Object?> get props => [inSetup, nextAction, steps];
}
