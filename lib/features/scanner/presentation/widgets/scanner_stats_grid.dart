import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';

/// Stats grid for scanner screen showing expected, checked in, and pending guests.
class ScannerStatsGrid extends StatelessWidget {
  final int expectedGuests;
  final int checkedInGuests;
  final int pendingGuests;

  const ScannerStatsGrid({
    super.key,
    required this.expectedGuests,
    required this.checkedInGuests,
    required this.pendingGuests,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: t.translate('scanner_expected'),
            value: expectedGuests.toString(),
            icon: Icons.people,
            color: Colors.blue,
          ),
        ),
        SizedBox(width: context.dynamicWidth(0.029)),
        Expanded(
          child: _StatCard(
            label: t.translate('scanner_checked_in'),
            value: checkedInGuests.toString(),
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ),
        SizedBox(width: context.dynamicWidth(0.029)),
        Expanded(
          child: _StatCard(
            label: t.translate('scanner_pending'),
            value: pendingGuests.toString(),
            icon: Icons.pending,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: context.dynamicWidth(0.024),
            offset: Offset(0, context.dynamicHeight(0.005)),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(context.dynamicWidth(0.024)),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: context.dynamicWidth(0.061)),
          ),
          SizedBox(height: context.dynamicHeight(0.015)),
          Text(
            value,
            style: TextStyle(
              fontSize: context.dynamicWidth(0.069),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: context.dynamicHeight(0.005)),
          Text(
            label,
            style: TextStyle(
              fontSize: context.dynamicWidth(0.029),
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
