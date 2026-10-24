import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../config/locale/l10n_context.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/date_words.dart';
import '../../../domain/entities/event_entity.dart';
import '../event_poster.dart';
import '../event_status_style.dart';

/// The top of the event page: poster, status and days left, the date, the
/// place on one line with its map, and how many invitations are used.
class EventSummaryCard extends StatelessWidget {
  const EventSummaryCard({super.key, required this.event});

  final EventEntity event;

  /// Whole days to the event in the phone's calendar; null without a date.
  static int? daysLeft(EventEntity event) {
    final date = event.details?.startsAt ?? event.eventDate;
    if (date == null) return null;
    return DateUtils.dateOnly(date).difference(DateUtils.dateOnly(DateTime.now())).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final style = EventStatusStyle.of(event.status);
    final date = event.details?.startsAt ?? event.eventDate;
    final days = daysLeft(event);
    final mapUrl = event.details?.mapUrl;
    final limit = event.invitationLimit;
    return Container(
      padding: const EdgeInsetsDirectional.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        border: Border.all(color: context.borderColor),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EventPoster(title: event.name, imageUrl: event.imageUrl, width: 84, height: 112),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _Pill(context.tr(style.labelKey), style.background, style.foreground),
                    if (days != null && event.status != EventStatus.cancelled)
                      _Pill(context.countdownLabel(days), context.primaryWash, context.brandInk),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  event.name,
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: context.textPrimary),
                ),
                if (date != null)
                  Text(context.eventDateLine(date), style: TextStyle(fontSize: 13, color: context.textSecondary)),
                if (event.venueLine.isNotEmpty)
                  InkWell(
                    onTap: mapUrl == null
                        ? null
                        : () => launchUrl(Uri.parse(mapUrl), mode: LaunchMode.externalApplication),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.symmetric(vertical: 2),
                      child: Text(
                        mapUrl == null ? event.venueLine : '${event.venueLine} · ${context.tr('event_page_map')}',
                        style: TextStyle(
                          fontSize: 13,
                          color: mapUrl == null ? context.textSecondary : context.primaryText,
                          fontWeight: mapUrl == null ? FontWeight.w400 : FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                if (limit != null && limit > 0)
                  Text(
                    context.tr('event_page_invitations_used', {'used': event.invitations, 'limit': limit}),
                    style: TextStyle(fontSize: 13, color: context.textTertiary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.label, this.background, this.foreground);

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 9, vertical: 2),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: foreground),
      ),
    );
  }
}
