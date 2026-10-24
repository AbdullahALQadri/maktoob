import 'package:flutter/material.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/date_words.dart';
import '../../domain/entities/event_card.dart';
import '../../domain/entities/event_entity.dart';
import 'event_poster.dart';
import 'event_status_style.dart';

/// One event in the phone list: poster, title with its status, the date,
/// the host's role when it is an institution's event, then the setup step
/// or how many guests answered.
class EventRowTile extends StatelessWidget {
  const EventRowTile({super.key, required this.event, required this.onTap});

  final EventCard event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = EventStatusStyle.of(event.status);
    final date = event.date;
    final setup = event.inSetup;
    return Material(
      color: context.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EventPoster(title: event.title, imageUrl: event.imageUrl, width: 56, height: 72),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: context.textPrimary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _Pill(label: context.tr(style.labelKey), style: style),
                      ],
                    ),
                    if (date != null) ...[
                      const SizedBox(height: 4),
                      Text(context.eventDateLine(date), style: TextStyle(fontSize: 13, color: context.textSecondary)),
                    ],
                    if (event.role != EventRole.owner) ...[
                      const SizedBox(height: 4),
                      Text(
                        context.tr('institution_role_${event.role.apiValue}'),
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.brandInk),
                      ),
                    ],
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: (setup ? event.stepNumber! / event.stepsTotal : event.responseShare)
                            .clamp(0, 1)
                            .toDouble(),
                        minHeight: 6,
                        backgroundColor: context.chipBg,
                        color: setup ? AppColors.primaryColor : AppColors.green600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      setup
                          ? '${context.tr('home_step_of', {'current': event.stepNumber!, 'total': event.stepsTotal})} · ${context.tr(event.nextAction.labelKey)}'
                          : '${context.tr('home_card_responded')} ${context.tr('home_card_of', {'done': event.responded, 'total': event.invitations})}',
                      style: TextStyle(fontSize: 13, color: context.textTertiary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.style});

  final String label;
  final EventStatusStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: style.background, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: style.foreground),
      ),
    );
  }
}
