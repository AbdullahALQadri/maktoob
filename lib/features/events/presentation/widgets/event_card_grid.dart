import 'package:flutter/material.dart';

import '../../domain/entities/event_card.dart';
import 'event_card_tile.dart';

/// Event cards in as many columns as fit (2 to 4, about 300 wide each).
/// Rows take their tallest card's height, so large text never clips.
class EventCardGrid extends StatelessWidget {
  const EventCardGrid({super.key, required this.events, required this.onOpen});

  final List<EventCard> events;
  final ValueChanged<EventCard> onOpen;

  static const _gap = 16.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / 300).floor().clamp(2, 4);
        final width = (constraints.maxWidth - _gap * (columns - 1)) / columns;
        return Wrap(
          spacing: _gap,
          runSpacing: _gap,
          children: [
            for (final event in events)
              SizedBox(
                width: width,
                child: EventCardTile(event: event, onTap: () => onOpen(event)),
              ),
          ],
        );
      },
    );
  }
}
