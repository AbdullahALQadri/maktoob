import 'package:flutter/material.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/design/window_size.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../events/domain/entities/event_card.dart';
import '../../../events/presentation/widgets/event_card_grid.dart';
import '../../../events/presentation/widgets/event_card_tile.dart';

/// "My events" on home: a row to swipe on a phone, a grid on wider screens.
/// It pads itself: the phone row runs to the screen edge so the next card
/// peeks in.
class HomeEventsSection extends StatelessWidget {
  const HomeEventsSection({super.key, required this.events, required this.onOpen, required this.onViewAll});

  final List<EventCard> events;
  final ValueChanged<EventCard> onOpen;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final compact = context.windowSize.isCompact;
    final gutter = EdgeInsetsDirectional.symmetric(horizontal: context.pageGutter);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: gutter,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.tr('home_my_events'),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: context.textPrimary),
                ),
              ),
              TextButton(onPressed: onViewAll, child: Text(context.tr('home_view_all'))),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (compact)
          _Row(events: events, onOpen: onOpen)
        else
          Padding(
            padding: gutter,
            child: EventCardGrid(events: events, onOpen: onOpen),
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.events, required this.onOpen});

  final List<EventCard> events;
  final ValueChanged<EventCard> onOpen;

  @override
  Widget build(BuildContext context) {
    final gutter = context.pageGutter;
    return SizedBox(
      height: 278,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsetsDirectional.symmetric(horizontal: gutter),
        clipBehavior: Clip.none,
        itemCount: events.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => SizedBox(
          width: 248,
          child: EventCardTile(event: events[i], onTap: () => onOpen(events[i])),
        ),
      ),
    );
  }
}
