import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../domain/entities/event_entity.dart';

/// Empty state widget for events list.
class EventsEmptyState extends StatelessWidget {
  final EventStatus status;

  const EventsEmptyState({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final config = _getConfig(status, t);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.dynamicWidth(0.08)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: context.dynamicWidth(0.2),
              height: context.dynamicWidth(0.2),
              decoration: BoxDecoration(
                color: config.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                config.icon,
                size: context.dynamicWidth(0.101),
                color: config.color,
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.025)),
            Text(
              config.title,
              style: TextStyle(
                fontSize: context.dynamicWidth(0.045),
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.dynamicHeight(0.01)),
            Text(
              config.subtitle,
              style: TextStyle(
                fontSize: context.dynamicWidth(0.035),
                color: context.iconSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  _EmptyStateConfig _getConfig(EventStatus status, AppLocalizations t) {
    return switch (status) {
      EventStatus.active => _EmptyStateConfig(
          title: t.translate('events_no_ongoing'),
          subtitle: t.translate('events_start_creating'),
          icon: Icons.event_available,
          color: AppColors.green600,
        ),
      EventStatus.completed => _EmptyStateConfig(
          title: t.translate('events_no_completed'),
          subtitle: t.translate('events_completed_appear'),
          icon: Icons.check_circle_outline,
          color: AppColors.blue500,
        ),
      EventStatus.draft => _EmptyStateConfig(
          title: t.translate('events_no_drafts'),
          subtitle: t.translate('events_drafts_appear'),
          icon: Icons.edit_note,
          color: AppColors.amber500,
        ),
    };
  }
}

class _EmptyStateConfig {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _EmptyStateConfig({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
