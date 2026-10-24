import 'package:flutter/painting.dart';

import '../../../../core/utils/app_colors.dart';
import '../../domain/entities/event_entity.dart';

/// Label and colours of an event status pill, as on the web portal
/// (`dashboard.partials.status`, `mk-pill`). Every pill pairs colour with a
/// word, so status never depends on colour alone.
class EventStatusStyle {
  const EventStatusStyle(this.labelKey, this.background, this.foreground);

  final String labelKey;
  final Color background;
  final Color foreground;

  static EventStatusStyle of(EventStatus status) => switch (status) {
    EventStatus.draft => const EventStatusStyle('events_draft', AppColors.gray100, AppColors.gray700),
    EventStatus.pendingPayment => const EventStatusStyle(
      'event_status_pending_payment',
      AppColors.amber100,
      AppColors.amber700,
    ),
    EventStatus.active => const EventStatusStyle('events_active', AppColors.green100, AppColors.green800),
    EventStatus.completed => const EventStatusStyle('events_completed', AppColors.navy50, AppColors.tertiaryColor),
    EventStatus.cancelled => const EventStatusStyle('event_status_cancelled', AppColors.red100, AppColors.red500),
  };
}
