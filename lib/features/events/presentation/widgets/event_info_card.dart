import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../domain/entities/event_entity.dart';

/// Event information card showing date, venue and RSVP deadline.
class EventInfoCard extends StatelessWidget {
  final EventEntity event;

  const EventInfoCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

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
            icon: Icons.info_outline,
            title: t.translate('event_details_info'),
            gradient: [AppColors.primaryColor, AppColors.tertiaryColor],
          ),
          const SizedBox(height: 20),
          _InfoRow(
            icon: Icons.calendar_today,
            label: t.translate('event_details_date_time'),
            value: event.eventDate != null
                ? _formatDateTime(event.eventDate!)
                : '${event.date} at ${event.time}',
            color: AppColors.blue500,
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.location_on,
            label: t.translate('event_details_venue'),
            value: event.venueAddress != null
                ? '${event.venue}\n${event.venueAddress}'
                : event.venue,
            color: AppColors.emerald500,
          ),
          if (event.rsvpDeadline != null) ...[
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.access_time,
              label: t.translate('event_details_rsvp_deadline'),
              value: _formatDate(event.rsvpDeadline!),
              color: AppColors.amber500,
            ),
          ],
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year} at $hour:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.labelLarge),
            ],
          ),
        ),
      ],
    );
  }
}
