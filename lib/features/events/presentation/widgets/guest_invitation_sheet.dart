import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../domain/entities/guest_entity.dart';

/// Bottom sheet the host opens by tapping a guest: the guest's QR (same URL
/// the public page /i/{short_url} encodes and the door scanner accepts), a
/// share/copy link, and the invitation timeline.
class GuestInvitationSheet extends StatelessWidget {
  final GuestEntity guest;

  /// Host actions on a live event; null hides the button. Each returns
  /// whether it succeeded (the sheet closes on success).
  final Future<bool> Function()? onResend;
  final Future<bool> Function()? onRemove;

  const GuestInvitationSheet({
    super.key,
    required this.guest,
    this.onResend,
    this.onRemove,
  });

  /// Resending is for an invitation that already went out (or failed) and
  /// that the guest hasn't answered; unsent ones go with "Send invitations".
  static bool canResend(GuestEntity g) =>
      const ['sent', 'delivered', 'opened', 'failed'].contains(g.invitationStatus);

  static Future<void> show(
    BuildContext context,
    GuestEntity guest, {
    Future<bool> Function()? onResend,
    Future<bool> Function()? onRemove,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (_) => GuestInvitationSheet(
        guest: guest,
        onResend: onResend != null && canResend(guest) ? onResend : null,
        onRemove: guest.isCheckedIn ? null : onRemove,
      ),
    );
  }

  /// Ordered timeline rows: (translation key, time or null when not reached).
  static List<(String, DateTime?)> timeline(GuestEntity g) => [
        ('guest_sheet_sent', g.sentAt),
        ('guest_sheet_opened', g.openedAt),
        ('guest_sheet_responded', g.respondedAt),
        ('guest_sheet_checked_in', g.checkedInAt),
      ];

  static String formatTime(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}/${two(d.month)}/${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final url = guest.invitationUrl;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(guest.name,
                style: AppTextStyles.titleLarge
                    .copyWith(color: context.textPrimary),
                textAlign: TextAlign.center),
            if (guest.phone.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(guest.phone,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: context.textSecondary)),
            ],
            const SizedBox(height: AppSpacing.md),
            if (url == null || url.isEmpty)
              Text(t.translate('guest_sheet_no_link'),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: context.textSecondary))
            else ...[
              Center(
                child: Container(
                  padding: const EdgeInsetsDirectional.all(AppSpacing.smd),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: context.borderColor),
                  ),
                  child: QrImageView(
                    data: url,
                    size: 200,
                    backgroundColor: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(t.translate('guest_sheet_qr_hint'),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: context.textSecondary)),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.copy_rounded),
                      label: Text(t.translate('guest_sheet_copy_link')),
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: url));
                        if (context.mounted) {
                          AppSnackBar.showSuccess(context,
                              message: t.translate('guest_sheet_link_copied'));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.share_rounded),
                      label: Text(t.translate('guest_sheet_share_link')),
                      onPressed: () => SharePlus.instance.share(ShareParams(text: url)),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsetsDirectional.all(AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: context.borderColor),
              ),
              child: Column(
                children: [
                  for (final (key, time) in timeline(guest))
                    _TimelineRow(
                      label: t.translate(key),
                      value: time == null ? '—' : formatTime(time),
                      done: time != null,
                    ),
                  _TimelineRow(
                    label: t.translate('guest_sheet_companions'),
                    value: '${guest.companions}',
                    done: guest.companions > 0,
                  ),
                ],
              ),
            ),
            if (onResend != null || onRemove != null) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  if (onResend != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.send_rounded),
                        label: Text(t.translate('guest_sheet_resend')),
                        onPressed: () async {
                          final ok = await onResend!();
                          if (ok && context.mounted) Navigator.pop(context);
                        },
                      ),
                    ),
                  if (onResend != null && onRemove != null)
                    const SizedBox(width: AppSpacing.sm),
                  if (onRemove != null)
                    Expanded(
                      child: TextButton.icon(
                        style: TextButton.styleFrom(foregroundColor: AppColors.red500),
                        icon: const Icon(Icons.person_remove_outlined),
                        label: Text(t.translate('guest_sheet_remove')),
                        onPressed: () => _confirmRemove(context, t),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

extension on GuestInvitationSheet {
  Future<void> _confirmRemove(BuildContext context, AppLocalizations t) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(t.translate('guest_sheet_remove')),
        content: Text(t.translate('guest_sheet_remove_confirm').replaceAll('{name}', guest.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: Text(t.translate('common_cancel'))),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.red500),
            onPressed: () => Navigator.pop(d, true),
            child: Text(t.translate('guest_sheet_remove')),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final ok = await onRemove!();
    if (ok && context.mounted) Navigator.pop(context);
  }
}

class _TimelineRow extends StatelessWidget {
  final String label;
  final String value;
  final bool done;

  const _TimelineRow(
      {required this.label, required this.value, required this.done});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
              size: 18,
              color: done ? AppColors.primary : context.iconSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
              child: Text(label,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: context.textPrimary))),
          Text(value,
              textDirection: TextDirection.ltr,
              style: AppTextStyles.bodySmall
                  .copyWith(color: context.textSecondary)),
        ],
      ),
    );
  }
}
