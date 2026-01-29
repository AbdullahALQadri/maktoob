import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../events/domain/entities/event_entity.dart';

/// Event card for scanner selection screen.
class ScannerEventCard extends StatelessWidget {
  final EventEntity event;
  final int index;
  final VoidCallback? onTap;

  const ScannerEventCard({
    super.key,
    required this.event,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: context.dynamicHeight(0.02)),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
            child: _CardContent(event: event, t: t),
          ),
        ),
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  final EventEntity event;
  final AppLocalizations t;

  const _CardContent({required this.event, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.08),
            blurRadius: context.dynamicWidth(0.051),
            offset: Offset(0, context.dynamicHeight(0.01)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderRow(event: event),
          SizedBox(height: context.dynamicHeight(0.02)),
          Container(height: context.dynamicHeight(0.001), color: context.borderColor),
          SizedBox(height: context.dynamicHeight(0.015)),
          _DetailsRow(event: event),
          SizedBox(height: context.dynamicHeight(0.015)),
          _StatsRow(event: event, t: t),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final EventEntity event;

  const _HeaderRow({required this.event});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: context.dynamicWidth(0.12),
          height: context.dynamicWidth(0.12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryColor, AppColors.tertiaryColor],
            ),
            borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
          ),
          child: Icon(
            _getEventIcon(event.type),
            color: Colors.white,
            size: context.dynamicWidth(0.061),
          ),
        ),
        SizedBox(width: context.dynamicWidth(0.035)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.name,
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.043),
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: context.dynamicHeight(0.005)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.dynamicWidth(0.021),
                  vertical: context.dynamicHeight(0.002),
                ),
                decoration: BoxDecoration(
                  color: AppColors.green600.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(context.dynamicWidth(0.016)),
                ),
                child: Text(
                  event.type,
                  style: TextStyle(
                    fontSize: context.dynamicWidth(0.029),
                    fontWeight: FontWeight.w600,
                    color: AppColors.green600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getEventIcon(String type) {
    return switch (type.toLowerCase()) {
      'wedding' => Icons.favorite,
      'birthday' => Icons.cake,
      'conference' => Icons.business,
      'meeting' => Icons.groups,
      'party' => Icons.celebration,
      _ => Icons.event,
    };
  }
}

class _DetailsRow extends StatelessWidget {
  final EventEntity event;

  const _DetailsRow({required this.event});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _InfoItem(icon: Icons.calendar_today, text: '${event.date}\n${event.time}')),
        Expanded(child: _InfoItem(icon: Icons.location_on, text: event.venue)),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: context.dynamicWidth(0.04), color: context.iconSecondary),
        SizedBox(width: context.dynamicWidth(0.021)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: context.dynamicWidth(0.029),
              color: context.textSecondary,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final EventEntity event;
  final AppLocalizations t;

  const _StatsRow({required this.event, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.029)),
      decoration: BoxDecoration(
        color: context.overlayBg,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.024)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: t.translate('scanner_expected'), value: event.attending.toString(), color: AppColors.blue500),
          _StatDivider(),
          _StatItem(label: t.translate('scanner_checked_in'), value: event.checkedIn.toString(), color: AppColors.green600),
          _StatDivider(),
          _StatItem(label: t.translate('scanner_pending'), value: (event.attending - event.checkedIn).toString(), color: AppColors.amber500),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: context.dynamicWidth(0.045),
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.002)),
        Text(
          label,
          style: TextStyle(
            fontSize: context.dynamicWidth(0.024),
            color: context.iconSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.dynamicWidth(0.003),
      height: context.dynamicHeight(0.039),
      color: context.borderColor,
    );
  }
}
