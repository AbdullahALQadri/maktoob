import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spacing.dart';

/// The door management screen's empty / offline / error message, with an
/// optional retry.
class DoorAdminMessage extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onRetry;

  const DoorAdminMessage({super.key, required this.icon, required this.text, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.gray400),
            AppSpacing.verticalSpace12,
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.gray600),
            ),
            if (onRetry != null) ...[
              AppSpacing.verticalSpace12,
              OutlinedButton(onPressed: onRetry, child: Text(t.translate('common_retry'))),
            ],
          ],
        ),
      ),
    );
  }
}
