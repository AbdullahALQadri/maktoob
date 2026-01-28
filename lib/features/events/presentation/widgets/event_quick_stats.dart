import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../domain/entities/event_entity.dart';

/// Quick stats card showing invited, attending and declined counts.
class EventQuickStats extends StatelessWidget {
  final EventEntity event;

  const EventQuickStats({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Container(
      margin: EdgeInsets.all(context.dynamicWidth(0.04)),
      padding: EdgeInsets.all(context.dynamicWidth(0.051)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.061)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              label: t.translate('event_details_invited'),
              value: event.invitations.toString(),
              color: AppColors.blue500,
              icon: Icons.mail_outline,
            ),
          ),
          _VerticalDivider(),
          Expanded(
            child: _StatItem(
              label: t.translate('event_details_attending'),
              value: event.attending.toString(),
              color: AppColors.green600,
              icon: Icons.check_circle_outline,
            ),
          ),
          _VerticalDivider(),
          Expanded(
            child: _StatItem(
              label: t.translate('event_details_declined'),
              value: event.declined.toString(),
              color: AppColors.red500,
              icon: Icons.cancel_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: context.dynamicWidth(0.101),
          height: context.dynamicWidth(0.101),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: context.dynamicWidth(0.051)),
        ),
        SizedBox(height: context.dynamicHeight(0.01)),
        Text(
          value,
          style: AppTextStyles.headlineSmall,
        ),
        SizedBox(height: context.dynamicHeight(0.002)),
        Text(
          label,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: context.dynamicWidth(0.12),
      color: AppColors.gray200,
    );
  }
}
