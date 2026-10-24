import 'package:flutter/material.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/design/mood/banner_mood.dart';
import '../../../../core/design/mood/mood_banner.dart';
import '../../../../core/design/window_size.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../events/domain/entities/event_card.dart';
import '../../domain/entities/home_summary.dart';
import 'spotlight_card.dart';

/// The home banner in the hour's mood (the web dashboard's hero): greeting,
/// one line about what comes next, and the nearest occasion's spotlight.
/// Wide windows put the spotlight beside the greeting, phones under it.
class HomeHero extends StatelessWidget {
  const HomeHero({
    super.key,
    required this.summary,
    required this.firstName,
    required this.onCreate,
    required this.onAction,
    this.onMyEvents,
    this.orgLine,
  });

  final HomeSummary summary;
  final String firstName;

  /// The institution's name and balance, shown under the greeting.
  final String? orgLine;
  final VoidCallback onCreate;
  final VoidCallback? onMyEvents;
  final ValueChanged<EventCard> onAction;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final mood = BannerMood.at(now, summary.gazaOffset);
    final gazaHour = now.toUtc().add(summary.gazaOffset).hour;
    final next = summary.nextEvent;
    final wide = context.windowSize.atLeastExpanded;

    final intro = _Intro(
      mood: mood,
      greeting: context.tr(gazaHour < 12 ? 'home_greeting_morning' : 'home_greeting_evening', {'name': firstName}),
      orgLine: orgLine,
      line: context.tr(
        next != null
            ? 'home_hero_next'
            : summary.isFirstVisit
            ? 'home_hero_welcome'
            : 'home_hero_none_upcoming',
      ),
      // Phones already have the create button and My events in the bottom
      // bar; the banner only offers them when there is nothing to spotlight.
      actions: wide || next == null
          ? _Actions(
              mood: mood,
              createLabel: context.tr(
                summary.isFirstVisit && summary.freeTrialAvailable ? 'home_create_first_free' : 'home_create_event',
              ),
              onCreate: onCreate,
              onMyEvents: summary.isFirstVisit ? null : onMyEvents,
            )
          : null,
    );
    final spot = next == null ? null : SpotlightCard(event: next, mood: mood, onAction: () => onAction(next));

    return MoodBanner(
      mood: mood,
      padding: EdgeInsetsDirectional.all(wide ? 32 : 18),
      child: wide && spot != null
          ? Row(
              children: [
                Expanded(child: intro),
                const SizedBox(width: 28),
                Flexible(
                  child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 520), child: spot),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                intro,
                if (spot != null) ...[const SizedBox(height: 16), spot],
              ],
            ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.mood, required this.greeting, required this.line, this.orgLine, this.actions});

  final BannerMood mood;
  final String greeting;
  final String line;
  final String? orgLine;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final wide = context.windowSize.atLeastExpanded;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MoodChip(mood: mood, label: context.tr('home_mood_chip', {'name': context.tr(mood.nameKey)})),
        const SizedBox(height: 12),
        Text(
          greeting,
          style: TextStyle(fontSize: wide ? 30 : 24, fontWeight: FontWeight.w800, height: 1.3),
        ),
        if (orgLine != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.black.withValues(alpha: .18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.apartment_outlined, size: 16),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(orgLine!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          line,
          style: TextStyle(fontSize: wide ? 16 : 15, color: AppColors.white.withValues(alpha: .88), height: 1.5),
        ),
        if (actions != null) ...[const SizedBox(height: 18), actions!],
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.mood, required this.createLabel, required this.onCreate, this.onMyEvents});

  final BannerMood mood;
  final String createLabel;
  final VoidCallback onCreate;
  final VoidCallback? onMyEvents;

  @override
  Widget build(BuildContext context) {
    const shape = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12)));
    const text = TextStyle(fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Tajawal');
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        FilledButton.icon(
          onPressed: onCreate,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.white,
            foregroundColor: mood.ink,
            minimumSize: const Size(0, 46),
            shape: shape,
            textStyle: text,
          ),
          icon: const Icon(Icons.add, size: 20),
          label: Text(createLabel),
        ),
        if (onMyEvents != null)
          OutlinedButton.icon(
            onPressed: onMyEvents,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.white,
              backgroundColor: AppColors.white.withValues(alpha: .1),
              side: BorderSide(color: AppColors.white.withValues(alpha: .32)),
              minimumSize: const Size(0, 46),
              shape: shape,
              textStyle: text,
            ),
            icon: const Icon(Icons.calendar_month_outlined, size: 20),
            label: Text(context.tr('home_my_events')),
          ),
      ],
    );
  }
}
