import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../data/models/door_models.dart';

/// Who came each day of an event of several days (nothing for a one-day
/// event): each day counts its own attendance, a return within a day does not.
class DoorDaysReport extends StatelessWidget {
  final List<DoorDayCount> days;

  const DoorDaysReport({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) return const SizedBox.shrink();
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.translate('door_report_by_day'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          AppSpacing.verticalSpace8,
          for (var i = 0; i < days.length; i++)
            Container(
              key: Key('door_day_${days[i].date}'),
              margin: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
              padding: const EdgeInsetsDirectional.all(AppSpacing.smd),
              decoration: BoxDecoration(
                borderRadius: AppSpacing.borderRadiusMd,
                border: Border.all(color: AppColors.gray200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${t.translate('door_day_n').replaceAll('{n}', '${i + 1}')} · ${days[i].date}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    t
                        .translate('door_report_gate_count')
                        .replaceAll('{guests}', '${days[i].guests}')
                        .replaceAll('{companions}', '${days[i].companions}'),
                    style: const TextStyle(color: AppColors.gray600),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
