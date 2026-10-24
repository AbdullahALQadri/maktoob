import 'package:flutter/material.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/design/window_size.dart';
import '../../../../core/utils/app_colors.dart';
import '../../domain/entities/home_summary.dart';

/// The four numbers of the web dashboard: two by two on a phone, one row
/// from tablets up.
class HomeKpis extends StatelessWidget {
  const HomeKpis({super.key, required this.totals});

  final HomeTotals totals;

  @override
  Widget build(BuildContext context) {
    final items = [
      _Kpi('${totals.events}', 'home_kpi_events', Icons.calendar_month_outlined, AppColors.primaryDark),
      _Kpi('${totals.activeEvents}', 'home_kpi_active', Icons.check_circle_outline, AppColors.green600),
      _Kpi('${totals.invitations}', 'home_kpi_invitations', Icons.groups_outlined, context.brandInk),
      _Kpi(
        totals.invitations > 0 ? '${totals.responses} · ${totals.responseRate}%' : '${totals.responses}',
        'home_kpi_responses',
        Icons.chat_bubble_outline,
        AppColors.primaryDark,
      ),
    ];
    final columns = context.windowSize.isCompact ? 2 : 4;
    final rows = [for (var i = 0; i < items.length; i += columns) items.sublist(i, i + columns)];

    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        border: Border.all(color: context.borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (var r = 0; r < rows.length; r++)
            DecoratedBox(
              decoration: BoxDecoration(
                border: r == 0 ? null : Border(top: BorderSide(color: context.borderColor)),
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var c = 0; c < rows[r].length; c++) ...[
                      if (c > 0) VerticalDivider(width: 1, thickness: 1, color: context.borderColor),
                      Expanded(child: rows[r][c]),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi(this.value, this.labelKey, this.icon, this.color);

  final String value;
  final String labelKey;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.all(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: context.textPrimary,
                      height: 1.15,
                    ),
                  ),
                ),
                Text(context.tr(labelKey), maxLines: 2, style: TextStyle(fontSize: 13, color: context.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
