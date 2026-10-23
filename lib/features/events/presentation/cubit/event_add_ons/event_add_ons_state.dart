import 'package:equatable/equatable.dart';

import '../../../domain/entities/event_add_ons_entity.dart';

abstract class EventAddOnsState extends Equatable {
  const EventAddOnsState();

  @override
  List<Object?> get props => [];
}

class EventAddOnsInitial extends EventAddOnsState {
  const EventAddOnsInitial();
}

class EventAddOnsLoading extends EventAddOnsState {
  const EventAddOnsLoading();
}

class EventAddOnsLoaded extends EventAddOnsState {
  final EventAddOnsEntity addOns;

  /// A request / withdraw is in flight (buttons show a spinner).
  final bool busy;

  /// One-shot message after an action (translation key or server text).
  final String? notice;

  const EventAddOnsLoaded(this.addOns, {this.busy = false, this.notice});

  @override
  List<Object?> get props => [addOns, busy, notice];
}

class EventAddOnsError extends EventAddOnsState {
  final String message;

  const EventAddOnsError(this.message);

  @override
  List<Object?> get props => [message];
}
