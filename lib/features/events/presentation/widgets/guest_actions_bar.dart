import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../domain/entities/event_entity.dart';
import '../cubit/event_details/event_details_cubit.dart';
import '../cubit/event_details/event_details_state.dart';
import 'package:maktoob/core/widgets/loading/mk_spinner.dart';

/// Host actions above the guest list of a live event: send the invitations
/// that haven't gone out yet, and add a guest.
class GuestActionsBar extends StatelessWidget {
  final EventDetailsState state;

  const GuestActionsBar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final event = state.event!;
    final unsent = state.unsentCount;
    // No room left under the package: the server would refuse the add.
    final isFull = event.invitationLimit != null && event.remainingInvitations == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InvitationQuotaNote(
          limit: event.invitationLimit,
          remaining: event.remainingInvitations ?? 0,
        ),
        if (unsent > 0)
          Container(
            key: const Key('guest_actions_unsent'),
            padding: const EdgeInsetsDirectional.all(AppSpacing.smd),
            margin: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(color: context.borderColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.outgoing_mail, color: AppColors.primaryColor, size: AppSpacing.iconMd),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    t.translate(event.invitationsSentAt == null
                            ? 'event_unsent_first'
                            : 'event_unsent_new')
                        .replaceAll('{count}', '$unsent'),
                    style: AppTextStyles.bodySmall.copyWith(color: context.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        Row(
          children: [
            if (unsent > 0) ...[
              Expanded(
                child: FilledButton.icon(
                  key: const Key('guest_actions_send'),
                  icon: state.isBusy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: MkSpinner(strokeWidth: 2, color: AppColors.white),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(t.translate('event_send_invitations').replaceAll('{count}', '$unsent')),
                  onPressed: state.isBusy ? null : () => _send(context, t, event, unsent),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Expanded(
              child: OutlinedButton.icon(
                key: const Key('guest_actions_add'),
                icon: const Icon(Icons.person_add_alt_1_outlined),
                label: Text(t.translate('event_add_guest')),
                onPressed: state.isBusy || isFull ? null : () => _add(context, t, event),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String channelLabel(AppLocalizations t, String channel) => switch (channel) {
        'whatsapp' => t.translate('channel_whatsapp'),
        'sms' => t.translate('channel_sms'),
        'email' => t.translate('channel_email'),
        'app' => t.translate('channel_app'),
        _ => channel,
      };

  Future<void> _send(BuildContext context, AppLocalizations t, EventEntity event, int count) async {
    final cubit = context.read<EventDetailsCubit>();
    final channels = event.allowedChannels;
    var method = channels.first;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (d) => StatefulBuilder(
        builder: (d, setState) => AlertDialog(
          title: Text(t.translate('event_send_confirm_title')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.translate('event_send_confirm_body').replaceAll('{count}', '$count')),
              if (channels.length > 1) ...[
                const SizedBox(height: AppSpacing.md),
                Text(t.translate('event_send_channel'), style: AppTextStyles.labelLarge),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    for (final c in channels)
                      ChoiceChip(
                        label: Text(channelLabel(t, c)),
                        selected: method == c,
                        onSelected: (_) => setState(() => method = c),
                      ),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(d, false), child: Text(t.translate('common_cancel'))),
            FilledButton(onPressed: () => Navigator.pop(d, true), child: Text(t.translate('event_send_now'))),
          ],
        ),
      ),
    );
    if (confirmed == true) await cubit.sendInvitations(method);
  }

  Future<void> _add(BuildContext context, AppLocalizations t, EventEntity event) async {
    final cubit = context.read<EventDetailsCubit>();
    final guest = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const _AddGuestDialog(),
    );
    if (guest != null) await cubit.addGuests([guest]);
  }
}

class _AddGuestDialog extends StatefulWidget {
  const _AddGuestDialog();

  @override
  State<_AddGuestDialog> createState() => _AddGuestDialogState();
}

class _AddGuestDialogState extends State<_AddGuestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(t.translate('event_add_guest')),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              key: const Key('add_guest_name'),
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: t.translate('event_guest_name')),
              validator: (v) => (v ?? '').trim().isEmpty ? t.translate('wizard_field_required') : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              key: const Key('add_guest_phone'),
              controller: _phone,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                labelText: t.translate('event_guest_phone'),
                hintText: '059xxxxxxx',
              ),
              validator: (v) {
                final digits = (v ?? '').replaceAll(RegExp(r'[^0-9]'), '');
                return digits.length < 9 ? t.translate('event_guests_invalid_phone') : null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(t.translate('common_cancel'))),
        FilledButton(
          key: const Key('add_guest_submit'),
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(context, {'name': _name.text.trim(), 'phone': _phone.text.trim()});
          },
          child: Text(t.translate('event_add_guest_submit')),
        ),
      ],
    );
  }
}
