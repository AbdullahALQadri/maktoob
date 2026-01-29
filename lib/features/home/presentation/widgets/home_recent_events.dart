import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../events/presentation/screens/view_all_events_screen.dart';
import '../../domain/entities/recent_event_entity.dart';
import 'recent_event_card_widget.dart';

/// Recent events section for home screen.
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
      padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.04)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: t.translate('home_recent_events'),
            actionText: t.translate('home_view_all'),
            isRtl: !t.isEnLocale,
            onActionTap: () => _navigateToViewAll(context),
          ),
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
    return Padding(
      padding: EdgeInsets.only(bottom: context.dynamicHeight(0.02)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: context.dynamicWidth(0.051),
              fontWeight: FontWeight.bold,
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
