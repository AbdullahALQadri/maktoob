import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../domain/entities/check_in_guest_entity.dart';
import '../../domain/entities/door_entities.dart';
import 'door_texts.dart';

/// Result of a scan.
///
/// When the backend says the guest cannot be checked in (`can_check_in:
/// false`) it shows the blocker message and offers no confirm button. A
/// declined RSVP shows the warning but still allows the check-in. The
/// companions picker is limited to `max_companions`.
class GuestVerifiedDialog extends StatefulWidget {
  final CheckInGuestEntity guest;
  final VoidCallback onClose;

  /// Confirms the check-in with the chosen number of companions.
  final ValueChanged<int> onCheckIn;

  /// This phone's gate (for the "wrong gate" warning) and the event's valid
  /// day (for "valid on ..."), when known.
  final DoorGate? gate;
  final String? validOn;

  const GuestVerifiedDialog({
    super.key,
    required this.guest,
    required this.onClose,
    required this.onCheckIn,
    this.gate,
    this.validOn,
  });

  @override
  State<GuestVerifiedDialog> createState() => _GuestVerifiedDialogState();
}

class _GuestVerifiedDialogState extends State<GuestVerifiedDialog> {
  late int _companions = widget.guest.defaultCompanions;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final guest = widget.guest;
    final gate = widget.gate;
    final validOn = widget.validOn;
    final blocked = !guest.canCheckIn;
    final accent = blocked ? AppColors.red500 : AppColors.green600;

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusXl),
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(blocked ? Icons.block_rounded : Icons.check_circle_outline_rounded, color: accent, size: 56),
            AppSpacing.verticalSpace12,
            Text(
              t.translate(blocked ? 'scanner_cannot_check_in' : 'scanner_verified'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: accent),
            ),
            AppSpacing.verticalSpace16,
            Container(
              padding: const EdgeInsetsDirectional.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: AppSpacing.borderRadiusLg,
                border: Border.all(color: AppColors.gray200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guest.name.isNotEmpty
                        ? guest.name
                        : t.translate('scanner_unlisted_guest').replaceAll('{id}', guest.id),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.gray900),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (guest.phoneTail != null) ...[
                    AppSpacing.verticalSpace4,
                    Text(
                      t.translate('scanner_phone_tail').replaceAll('{digits}', guest.phoneTail!),
                      style: const TextStyle(fontSize: 13, color: AppColors.gray500),
                    ),
                  ],
                  AppSpacing.verticalSpace4,
                  Text(
                    '${t.translate('scanner_expected_companions')}: ${guest.companions}',
                    style: const TextStyle(fontSize: 14, color: AppColors.gray600),
                  ),
                ],
              ),
            ),
            if (blocked) ...[
              AppSpacing.verticalSpace16,
              _Notice(
                key: const Key('scanner_blocker'),
                icon: Icons.block_rounded,
                color: AppColors.red500,
                text:
                    guest.blockerMessage ??
                    (guest.blockerCode == null
                        ? t.translate('scanner_cannot_check_in')
                        : DoorTexts.reason(t, guest.blockerCode, maxCompanions: guest.maxCompanions, validOn: validOn)),
              ),
            ] else ...[
              if (guest.declinedRsvp) ...[
                AppSpacing.verticalSpace16,
                _Notice(
                  key: const Key('scanner_declined_warning'),
                  icon: Icons.warning_amber_rounded,
                  color: AppColors.amber600,
                  text: guest.warning ?? t.translate('scanner_declined_warning'),
                ),
              ],
              for (final w in guest.warnings.where((w) => w != 'declined')) ...[
                AppSpacing.verticalSpace12,
                _Notice(
                  key: Key('scanner_warning_$w'),
                  icon: w == 'unlisted' ? Icons.verified_outlined : Icons.alt_route_rounded,
                  color: AppColors.amber600,
                  text: DoorTexts.warning(t, w, gate: gate),
                ),
              ],
              AppSpacing.verticalSpace16,
              _CompanionsPicker(
                value: _companions,
                max: guest.maxCompanions,
                onChanged: (v) => setState(() => _companions = v),
              ),
            ],
            AppSpacing.verticalSpace24,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: const Key('scanner_dialog_close'),
                    onPressed: widget.onClose,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.gray700,
                      side: const BorderSide(color: AppColors.gray200),
                      padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpacing.smd),
                      shape: const RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusMd),
                    ),
                    child: Text(t.translate('common_close')),
                  ),
                ),
                if (!blocked) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      key: const Key('scanner_confirm_check_in'),
                      onPressed: () => widget.onCheckIn(_companions),
                      icon: const Icon(Icons.login_rounded, size: 20),
                      label: Text(t.translate('scanner_check_in')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green600,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpacing.smd),
                        shape: const RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusMd),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _Notice({super.key, required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.all(AppSpacing.smd),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: color),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w600, color: AppColors.gray900),
            ),
          ),
        ],
      ),
    );
  }
}

/// Companions entering now: 0..[max] (no upper bound when [max] is null).
class _CompanionsPicker extends StatelessWidget {
  final int value;
  final int? max;
  final ValueChanged<int> onChanged;

  const _CompanionsPicker({required this.value, required this.max, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final limit = max;
    final canAdd = limit == null || value < limit;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.smd, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.translate('scanner_companions_entering'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray900),
                ),
                if (limit != null)
                  Text(
                    t.translate('scanner_companions_max').replaceAll('{max}', '$limit'),
                    key: const Key('scanner_companions_max'),
                    style: const TextStyle(fontSize: 12, color: AppColors.gray500),
                  ),
              ],
            ),
          ),
          IconButton(
            key: const Key('scanner_companions_minus'),
            onPressed: value > 0 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_circle_outline),
            color: AppColors.primaryColor,
          ),
          Text(
            '$value',
            key: const Key('scanner_companions_value'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.gray900),
          ),
          IconButton(
            key: const Key('scanner_companions_plus'),
            onPressed: canAdd ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_circle_outline),
            color: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }
}
