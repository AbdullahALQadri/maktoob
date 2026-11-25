import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';

/// The support contacts in the "Contact us" sheet; tapping one copies it.
class SettingsContactOptions extends StatelessWidget {
  final AppLocalizations t;

  const SettingsContactOptions({super.key, required this.t});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ContactTile(
          icon: Icons.email_rounded,
          title: t.translate('settings_email'),
          value: 'support@maktoob.social',
        ),
        // Phone / WhatsApp tiles removed: they showed a placeholder
        // ("+966 XX XXX XXXX"). Add them back with the real support numbers.
      ],
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ContactTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return AppCard.outlined(
      onTap: () {
        Clipboard.setData(ClipboardData(text: value.replaceAll(' ', '')));
        AppSnackBar.showSuccess(
          context,
          message: t.translate('common_copied'),
          duration: const Duration(seconds: 2),
        );
      },
      child: Row(
        children: [
          AppIconButton.soft(
            icon: icon,
            onPressed: null,
            iconColor: AppColors.primaryColor,
          ),
          SizedBox(width: context.dynamicWidth(0.035)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelMedium),
                Text(value, style: AppTextStyles.caption),
              ],
            ),
          ),
          AppIconButton.soft(
            icon: Icons.copy_rounded,
            onPressed: null,
            iconColor: context.iconSecondary,
            backgroundColor: context.overlayBg,
          ),
        ],
      ),
    );
  }
}
