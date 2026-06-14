import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../events/presentation/screens/view_all_events_screen.dart';
import '../../domain/entities/recent_event_entity.dart';
import 'recent_event_card_widget.dart';

/// Recent events section.
///
/// Section header in titleLarge weight per DESIGN.md, with a single text
/// action — no gradient pills, no decorative icons in the header.
class HomeRecentEvents extends StatelessWidget {
  final List<RecentEventEntity> events;
  final Function(String)? onViewEvent;

  const HomeRecentEvents({
    super.key,
    required this.events,
    this.onViewEvent,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: t.translate('home_recent_events'),
            actionText: t.translate('home_view_all'),
            isRtl: !t.isEnLocale,
            onActionTap: () => _navigateToViewAll(context),
          ),
          if (events.isEmpty)
            const _EmptyState()
          else
            _EventsList(events: events, onViewEvent: onViewEvent),
        ],
      ),
    );
  }

  void _navigateToViewAll(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ViewAllEventsScreen()),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final bool isRtl;
  final VoidCallback onActionTap;

  const _SectionHeader({
    required this.title,
    required this.actionText,
    required this.isRtl,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: text.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
          AppTextButton(
            text: actionText,
            onPressed: onActionTap,
            suffixIcon: isRtl ? Icons.arrow_back : Icons.arrow_forward,
          ),
        ],
      ),
    );
  }
}

class _EventsList extends StatelessWidget {
  final List<RecentEventEntity> events;
  final Function(String)? onViewEvent;

  const _EventsList({required this.events, this.onViewEvent});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return RecentEventCardWidget(
          event: event,
          index: index,
          onTap: onViewEvent != null
              ? () => onViewEvent!(event.id.toString())
              : null,
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 20,
        vertical: 32,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 32,
            color: context.textTertiary,
          ),
          const SizedBox(height: 12),
          Text(
            'No recent events',
            style: text.titleMedium?.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Events you create will appear here.',
            style: text.bodyMedium?.copyWith(color: context.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
