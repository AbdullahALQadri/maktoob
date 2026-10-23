import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';

/// Optional RSVP settings: the last day guests can answer, and a personal
/// message shown on the invitation page. Both can be skipped.
class RsvpSettingsSection extends StatefulWidget {
  final InvitationState state;

  const RsvpSettingsSection({super.key, required this.state});

  @override
  State<RsvpSettingsSection> createState() => _RsvpSettingsSectionState();
}

class _RsvpSettingsSectionState extends State<RsvpSettingsSection> {
  late final TextEditingController _message =
      TextEditingController(text: widget.state.invitationMessage ?? '');

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  static String _format(DateTime d) =>
      '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDeadline(BuildContext context) async {
    final cubit = context.read<InvitationCubit>();
    final today = DateUtils.dateOnly(DateTime.now());
    final eventDay = widget.state.eventDate == null ? null : DateUtils.dateOnly(widget.state.eventDate!);
    // The backend requires the deadline to be before the event day.
    final last = eventDay?.subtract(const Duration(days: 1)) ?? today.add(const Duration(days: 365 * 3));
    if (last.isBefore(today)) return;

    final picked = await showDatePicker(
      context: context,
      initialDate: widget.state.rsvpDeadline ?? last,
      firstDate: today,
      lastDate: last,
    );
    if (picked != null) cubit.updateRsvpDeadline(picked);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final deadline = widget.state.rsvpDeadline;

    return Container(
      key: const Key('rsvp_settings_section'),
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_available_outlined, color: AppColors.primary, size: AppSpacing.iconMd),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  t.translate('rsvp_settings_title'),
                  style: AppTextStyles.titleSmall.copyWith(color: context.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            t.translate('rsvp_settings_optional'),
            style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          InkWell(
            key: const Key('rsvp_deadline_field'),
            borderRadius: AppSpacing.borderRadiusMd,
            onTap: () => _pickDeadline(context),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: t.translate('rsvp_deadline_label'),
                border: const OutlineInputBorder(),
                suffixIcon: deadline == null
                    ? const Icon(Icons.calendar_today_outlined)
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => context.read<InvitationCubit>().updateRsvpDeadline(null),
                      ),
              ),
              child: Text(
                deadline == null ? t.translate('rsvp_deadline_none') : _format(deadline),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: deadline == null ? context.textSecondary : context.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            key: const Key('rsvp_message_field'),
            controller: _message,
            maxLines: 3,
            maxLength: 500,
            onChanged: context.read<InvitationCubit>().updateInvitationMessage,
            decoration: InputDecoration(
              labelText: t.translate('rsvp_message_label'),
              hintText: t.translate('rsvp_message_hint'),
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
