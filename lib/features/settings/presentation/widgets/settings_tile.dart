import 'package:flutter/material.dart';

import '../../../../core/core.dart';

/// Reusable settings tile widget.
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard.elevated(
      onTap: onTap,
      elevation: 2,
      child: Row(
        children: [
          _IconBox(icon: icon),
          SizedBox(width: context.dynamicWidth(0.04)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleSmall),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(color: context.iconSecondary),
                ),
              ],
            ),
          ),
          trailing ??
              Icon(
                Icons.arrow_forward_ios,
                color: context.iconDefault,
                size: context.dynamicWidth(0.04),
              ),
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;

  const _IconBox({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.dynamicWidth(0.12),
      height: context.dynamicWidth(0.12),
      decoration: BoxDecoration(
        color: AppColors.purple50,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
      ),
      child: Icon(
        icon,
        color: AppColors.primaryColor,
        size: context.dynamicWidth(0.061),
      ),
    );
  }
}

/// Section title widget for settings.
class SettingsSectionTitle extends StatelessWidget {
  final String title;

  const SettingsSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTextStyles.titleMedium);
  }
}
