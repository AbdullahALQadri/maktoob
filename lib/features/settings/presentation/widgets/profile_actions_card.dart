import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';

/// Account actions card for profile.
class ProfileActionsCard extends StatelessWidget {
  final VoidCallback onEditProfile;
  final VoidCallback onChangePassword;
  final VoidCallback onLogout;
  final VoidCallback onDeleteAccount;

  const ProfileActionsCard({
    super.key,
    required this.onEditProfile,
    required this.onChangePassword,
    required this.onLogout,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _ActionItem(
            icon: Icons.edit_outlined,
            title: t.translate('profile_edit'),
            onTap: onEditProfile,
          ),
          const _ActionDivider(),
          _ActionItem(
            icon: Icons.lock_outline,
            title: t.translate('profile_change_password'),
            onTap: onChangePassword,
          ),
          const _ActionDivider(),
          _ActionItem(
            icon: Icons.logout,
            title: t.translate('profile_logout'),
            onTap: onLogout,
          ),
          const _ActionDivider(),
          _ActionItem(
            icon: Icons.delete_outline,
            title: t.translate('profile_delete'),
            isDestructive: true,
            onTap: onDeleteAccount,
          ),
        ],
      ),
    );
  }
}

class _ActionDivider extends StatelessWidget {
  const _ActionDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(color: AppColors.gray100, height: 1);
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.red500 : AppColors.gray600;
    final textColor = isDestructive ? AppColors.red500 : AppColors.gray900;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(context.dynamicWidth(0.04)),
        child: Row(
          children: [
            Icon(icon, color: color, size: context.dynamicWidth(0.056)),
            SizedBox(width: context.dynamicWidth(0.04)),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.04),
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.gray400,
              size: context.dynamicWidth(0.04),
            ),
          ],
        ),
      ),
    );
  }
}
