import 'package:flutter/material.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/date_words.dart';
import '../../domain/entities/event_entity.dart';
import 'event_status_style.dart';
import '../../domain/entities/event_card.dart';
import 'event_poster.dart';

/// An event card as on the web portal: the invitation on a stage with its
/// status and countdown, the date block and title, then the setup step or
/// how many guests answered.
class EventCardTile extends StatelessWidget {
  const EventCardTile({super.key, required this.event, required this.onTap});

  final EventCard event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = EventStatusStyle.of(event.status);
    final date = event.date;
    final days = event.countdownDays;
    return Material(
      color: context.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: context.borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 150,
              color: context.themeSurface,
              alignment: Alignment.center,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Center(
                    child: EventPoster(title: event.title, imageUrl: event.imageUrl, width: 78, height: 106),
                  ),
                  PositionedDirectional(
                    top: 10,
                    start: 10,
                    child: _Chip(context.tr(style.labelKey), style.background, style.foreground),
                  ),
                  if (days != null && event.status != EventStatus.cancelled)
                    PositionedDirectional(
                      top: 10,
                      end: 10,
                      child: _Chip(
                        context.countdownLabel(days),
                        AppColors.white,
                        days <= 7 ? AppColors.amber700 : AppColors.tertiaryColor,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      if (date != null) ...[_DateBlock(date: date), const SizedBox(width: 10)],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: context.textPrimary),
                            ),
                            Text(
                              _meta(context),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, color: context.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _Progress(event: event),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _meta(BuildContext context) => [
    ?event.typeName(context.languageCode),
    if (event.date case final date?) context.clockTime(date),
    context.tr('home_card_guests', {'count': event.invitations}),
  ].join(' · ');
}

class _Progress extends StatelessWidget {
  const _Progress({required this.event});

  final EventCard event;

  @override
  Widget build(BuildContext context) {
    final setup = event.inSetup;
    final label = setup
        ? context.tr('home_step_of', {'current': event.stepNumber!, 'total': event.stepsTotal})
        : context.tr('home_card_responded');
    final value = setup
        ? context.tr(event.nextAction.labelKey)
        : context.tr('home_card_of', {'done': event.responded, 'total': event.invitations});
    final share = setup ? event.stepNumber! / event.stepsTotal : event.responseShare;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: TextStyle(fontSize: 13, color: context.textTertiary)),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.textTertiary),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: share.clamp(0, 1).toDouble(),
            minHeight: 6,
            backgroundColor: context.chipBg,
            color: setup ? AppColors.primaryColor : AppColors.green600,
          ),
        ),
      ],
    );
  }
}

class _DateBlock extends StatelessWidget {
  const _DateBlock({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      padding: const EdgeInsetsDirectional.symmetric(vertical: 5),
      decoration: BoxDecoration(color: context.primaryWash, borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Text(
            '${date.day}',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: context.primaryText, height: 1.1),
          ),
          Text(
            context.monthShort(date),
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: context.primaryText),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label, this.background, this.foreground);

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: foreground),
      ),
    );
  }
}
