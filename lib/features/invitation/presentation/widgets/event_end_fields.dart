import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../domain/utils/event_setup_rules.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';

/// Business types (workshops, conferences): when it ends, and whether it lasts
/// several days. Several days: the guests' QR works every day of it and each
/// day counts its own attendance. Weddings and family occasions never show it.
class EventEndFields extends StatelessWidget {
  final InvitationState state;

  const EventEndFields({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cubit = context.read<InvitationCubit>();
    final start = state.eventDate;
    final lastDay = state.eventEndDate;
    final multiDay = lastDay != null;
    final end = state.eventEndTime;
    final invalid =
        !multiDay && end != null && state.eventTime != null && !EventSetupRules.isEndAfterStart(state.eventTime!, end);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          key: const Key('wizard_multi_day'),
          contentPadding: EdgeInsetsDirectional.zero,
          value: multiDay,
          activeTrackColor: AppColors.primaryColor,
          title: Text(l?.translate('wizard_multi_day_label') ?? '', style: const TextStyle(fontSize: 14)),
          onChanged: start == null
              ? null
              : (on) => cubit.updateEndDate(on ? DateTime(start.year, start.month, start.day + 1) : null),
        ),
        if (multiDay) ...[
          _PickerBox(
            key: const Key('wizard_last_day'),
            label: l?.translate('wizard_last_day_label') ?? '',
            icon: Icons.event_rounded,
            text: MaterialLocalizations.of(context).formatMediumDate(lastDay),
            onTap: () async {
              final first = DateTime(start!.year, start.month, start.day + 1);
              final picked = await showDatePicker(
                context: context,
                initialDate: lastDay.isBefore(first) ? first : lastDay,
                firstDate: first,
                lastDate: DateTime(start.year, start.month, start.day + EventSetupRules.maxEventDays - 1),
              );
              if (picked != null) cubit.updateEndDate(picked);
            },
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l?.translate('wizard_multi_day_note') ?? '',
            style: const TextStyle(fontSize: 12, color: AppColors.gray500),
          ),
          const SizedBox(height: AppSpacing.smd),
        ],
        _PickerBox(
          label: l?.translate('wizard_event_end_time_label') ?? '',
          icon: Icons.schedule_rounded,
          invalid: invalid,
          text: end != null ? MaterialLocalizations.of(context).formatTimeOfDay(end) : null,
          hint: l?.translate('wizard_event_end_time_hint') ?? '',
          onTap: () async {
            final s = state.eventTime;
            final picked = await showTimePicker(
              context: context,
              initialTime:
                  end ??
                  (s != null
                      ? TimeOfDay(hour: (s.hour + 2) % 24, minute: s.minute)
                      : const TimeOfDay(hour: 20, minute: 0)),
            );
            if (picked != null) cubit.updateEndTime(picked);
          },
        ),
        if (invalid) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            l?.translate('wizard_end_before_start') ?? '',
            style: const TextStyle(fontSize: 12, color: AppColors.red500),
          ),
        ],
      ],
    );
  }
}

/// A labelled field that opens a picker.
class _PickerBox extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? text;
  final String hint;
  final bool invalid;
  final VoidCallback onTap;

  const _PickerBox({
    super.key,
    required this.label,
    required this.icon,
    required this.text,
    required this.onTap,
    this.hint = '',
    this.invalid = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
        const SizedBox(height: AppSpacing.xs),
        InkWell(
          borderRadius: AppSpacing.borderRadiusLg,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceBg,
              borderRadius: AppSpacing.borderRadiusLg,
              border: Border.all(color: invalid ? AppColors.red500 : AppColors.gray200),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.gray500, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    text ?? hint,
                    style: TextStyle(fontSize: 14, color: text != null ? context.textPrimary : AppColors.gray400),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
