import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../domain/entities/check_in_guest_entity.dart';
import 'door_texts.dart';

/// A guest whose QR already came in today (stepped out, came back): they
/// are let back in. The first entry is the attendance; nothing is recorded
/// again, so there is nothing to confirm, only who it is and when they first
/// came in.
class ReturningGuestDialog extends StatelessWidget {
  final CheckInGuestEntity guest;
  final VoidCallback onClose;

  const ReturningGuestDialog({super.key, required this.guest, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final at = guest.checkedInAt;
    final device = guest.checkedInDevice;

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusLg),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(color: AppColors.green100, shape: BoxShape.circle),
              child: const Icon(Icons.login_rounded, color: AppColors.green600, size: 34),
            ),
            AppSpacing.verticalSpace12,
            Text(
              t.translate('door_returning_title'),
              key: const Key('door_returning_title'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.green600),
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSpace16,
            Container(
              width: double.infinity,
              padding: const EdgeInsetsDirectional.all(AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: AppSpacing.borderRadiusMd,
                border: Border.all(color: AppColors.gray200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guest.name,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (at != null) ...[
                    AppSpacing.verticalSpace4,
                    Text(
                      t.translate('door_returning_first').replaceAll('{time}', DoorTexts.hhmm(at)),
                      key: const Key('door_returning_first'),
                      style: const TextStyle(color: AppColors.gray600),
                    ),
                  ],
                  if (device != null && device.isNotEmpty)
                    Text(
                      t.translate('scanner_checked_in_by').replaceAll('{device}', device),
                      style: const TextStyle(color: AppColors.gray600),
                    ),
                  if (guest.companions > 0)
                    Text(
                      t.translate('door_returning_party').replaceAll('{count}', '${guest.companions}'),
                      style: const TextStyle(color: AppColors.gray600),
                    ),
                ],
              ),
            ),
            AppSpacing.verticalSpace12,
            Text(
              t.translate('door_returning_note'),
              style: const TextStyle(color: AppColors.gray600, height: 1.5),
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSpace16,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                key: const Key('door_returning_ok'),
                onPressed: onClose,
                child: Text(t.translate('common_ok')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
