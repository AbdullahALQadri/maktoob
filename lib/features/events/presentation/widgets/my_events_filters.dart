import 'package:flutter/material.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/utils/app_colors.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/entities/event_page.dart';
import 'event_status_style.dart';

/// The status tabs of "My events", each with its count, as on the portal.
/// Cancelled shows only when there is one. A row to swipe on phones; it
/// wraps on wider screens.
class MyEventsFilters extends StatelessWidget {
  const MyEventsFilters({
    super.key,
    required this.selected,
    required this.counts,
    required this.onSelect,
    this.wrap = false,
  });

  final EventStatus? selected;
  final EventCounts counts;
  final ValueChanged<EventStatus?> onSelect;
  final bool wrap;

  static const _order = [EventStatus.draft, EventStatus.pendingPayment, EventStatus.active, EventStatus.completed];

  @override
  Widget build(BuildContext context) {
    final statuses = <EventStatus?>[
      null,
      ..._order,
      if (counts.of(EventStatus.cancelled) > 0 || selected == EventStatus.cancelled) EventStatus.cancelled,
    ];
    final chips = [
      for (final status in statuses)
        _Chip(
          label: context.tr(status == null ? 'events_all' : EventStatusStyle.of(status).labelKey),
          count: counts.of(status),
          selected: status == selected,
          onTap: () => onSelect(status),
        ),
    ];
    if (wrap) return Wrap(spacing: 8, runSpacing: 8, children: chips);
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => chips[i],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.count, required this.selected, required this.onTap});

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? context.primaryText : context.textTertiary;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? context.primaryWash : context.cardBg,
        shape: StadiumBorder(side: BorderSide(color: selected ? AppColors.sky200 : context.borderColor)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Container(
            height: 44,
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 14),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 14, color: fg, fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
                ),
                const SizedBox(width: 6),
                Container(
                  constraints: const BoxConstraints(minWidth: 22),
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: selected ? context.cardBg : context.chipBg,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(
                    '$count',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
