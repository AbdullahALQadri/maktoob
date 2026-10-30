import 'package:flutter/material.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/design/mood/banner_mood.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/date_words.dart';
import '../../../events/domain/entities/event_card.dart';
import '../../../events/presentation/widgets/event_poster.dart';
import '../../../events/presentation/widgets/step_segments.dart';

/// The nearest occasion inside the banner (`.mk-spot` on the web): poster,
/// title, date, days left, setup step and the one next action.
class SpotlightCard extends StatelessWidget {
  const SpotlightCard({super.key, required this.event, required this.mood, required this.onAction});

  static const steps = ['details', 'guests', 'design', 'settings', 'checkout', 'send'];

  final EventCard event;
  final BannerMood mood;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final date = event.date;
    final type = event.typeName(context.languageCode);
    final meta = [?type, if (date != null) context.eventDateLine(date)].join(' · ');
    final days = event.countdownDays;

    return Container(
      padding: const EdgeInsetsDirectional.all(14),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: .16),
        border: Border.all(color: AppColors.white.withValues(alpha: .18)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.rotate(
                angle: -0.035,
                child: EventPoster(
                  title: event.title,
                  imageUrl: event.imageUrl,
                  width: 92,
                  height: 124,
                  accent: mood.accent,
                  ink: mood.ink,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('home_nearest'),
                      style: TextStyle(color: mood.accent, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, height: 1.4),
                    ),
                    if (meta.isNotEmpty)
                      Text(meta, style: TextStyle(fontSize: 13, color: AppColors.white.withValues(alpha: .8))),
                    if (days != null && days >= 0) ...[const SizedBox(height: 8), _DaysLeft(days: days)],
                  ],
                ),
              ),
            ],
          ),
          if (event.inSetup) ...[const SizedBox(height: 14), _SetupStep(event: event, mood: mood)],
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onAction,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: mood.ink,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Tajawal'),
            ),
            icon: Icon(_icon(event.nextAction), size: 20),
            label: Text(context.tr(event.nextAction.labelKey)),
          ),
        ],
      ),
    );
  }

  static IconData _icon(NextAction action) => switch (action) {
    NextAction.completeDetails => Icons.edit_outlined,
    NextAction.addGuests => Icons.person_add_alt_1_outlined,
    NextAction.chooseDesign => Icons.image_outlined,
    NextAction.pay => Icons.credit_card_outlined,
    NextAction.trackPayment => Icons.schedule_outlined,
    NextAction.sendInvitations => Icons.send_outlined,
    NextAction.viewResults => Icons.bar_chart_outlined,
  };
}

class _DaysLeft extends StatelessWidget {
  const _DaysLeft({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    if (days == 0) {
      return Text(
        context.tr('home_today'),
        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 1),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text('$days', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, height: 1)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            context.daysLeftLabel(days),
            style: TextStyle(fontSize: 14, color: AppColors.white.withValues(alpha: .85)),
          ),
        ),
      ],
    );
  }
}

class _SetupStep extends StatelessWidget {
  const _SetupStep({required this.event, required this.mood});

  final EventCard event;
  final BannerMood mood;

  @override
  Widget build(BuildContext context) {
    final step = event.stepNumber!;
    final name = SpotlightCard.steps[(step - 1).clamp(0, SpotlightCard.steps.length - 1)];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.tr('home_step_of', {'current': step, 'total': event.stepsTotal}),
                style: TextStyle(fontSize: 13, color: AppColors.white.withValues(alpha: .88)),
              ),
            ),
            Text(context.tr('home_step_$name'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        StepSegments(
          current: step,
          total: event.stepsTotal,
          done: AppColors.white.withValues(alpha: .92),
          active: mood.accent,
          rest: AppColors.white.withValues(alpha: .22),
        ),
      ],
    );
  }
}
