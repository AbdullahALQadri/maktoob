import 'package:flutter/material.dart';

import '../../../../../core/design/window_size.dart';
import '../../../domain/entities/event_entity.dart';
import '../event_messages_card.dart';
import '../event_occasion_card.dart';
import '../event_package_card.dart';
import '../event_replies_card.dart';

/// Everything the host entered, as the portal and the team see it.
class EventDetailsTabView extends StatelessWidget {
  const EventDetailsTabView({super.key, required this.event});

  final EventEntity event;

  @override
  Widget build(BuildContext context) {
    final gutter = context.pageGutter;
    const gap = SizedBox(height: 16);
    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(gutter, 16, gutter, 32),
      children: [
        EventOccasionCard(event: event),
        gap,
        EventRepliesCard(event: event),
        gap,
        EventMessagesCard(event: event),
        gap,
        EventPackageCard(event: event),
      ],
    );
  }
}
