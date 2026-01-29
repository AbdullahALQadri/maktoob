import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../domain/entities/event_entity.dart';

/// Response analytics card with progress bars.
class EventAnalyticsCard extends StatelessWidget {
  final EventEntity event;

  const EventAnalyticsCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final total = event.invitations;
    final attendingPercent = total > 0 ? (event.attending / total * 100).round() : 0;
    final pendingPercent = total > 0 ? (event.pending / total * 100).round() : 0;
    final declinedPercent = total > 0 ? (event.declined / total * 100).round() : 0;
    final checkedInPercent = event.attending > 0
        ? (event.checkedIn / event.attending * 100).round()
        : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.analytics_outlined,
            title: t.translate('event_details_analytics'),
            gradient: [AppColors.blue500, AppColors.cyan500],
          ),
          const SizedBox(height: 24),
          _ProgressBar(
            label: t.translate('event_details_attending'),
            value: event.attending,
            total: total,
            percent: attendingPercent,
            color: AppColors.green600,
          ),
          const SizedBox(height: 16),
          _ProgressBar(
            label: t.translate('event_details_pending'),
            value: event.pending,
            total: total,
            percent: pendingPercent,
            color: AppColors.amber500,
          ),
          const SizedBox(height: 16),
          _ProgressBar(
            label: t.translate('event_details_declined'),
            value: event.declined,
            total: total,
            percent: declinedPercent,
            color: AppColors.red500,
          ),
          const SizedBox(height: 16),
          _ProgressBar(
            label: t.translate('event_details_checked_in'),
            value: event.checkedIn,
            total: event.attending,
            percent: checkedInPercent,
            color: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Color> gradient;

  const _CardHeader({
    required this.icon,
    required this.title,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradient),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(title, style: AppTextStyles.titleLarge),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final String label;
  final int value;
  final int total;
  final int percent;
  final Color color;

  const _ProgressBar({
    required this.label,
    required this.value,
    required this.total,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.labelMedium),
            Text('$value / $total ($percent%)', style: AppTextStyles.caption),
          ],
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: percent / 100),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, animValue, child) {
            return Container(
              height: 10,
              decoration: BoxDecoration(
                color: context.borderColor,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: animValue,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
