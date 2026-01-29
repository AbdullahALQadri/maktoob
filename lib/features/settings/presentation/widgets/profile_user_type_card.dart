import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../authentication/domain/entities/user_entity.dart';

/// User type selector card for profile.
class ProfileUserTypeCard extends StatelessWidget {
  final UserEntity user;
  final bool isArabic;
  final void Function(UserType type) onTypeSelected;

  const ProfileUserTypeCard({
    super.key,
    required this.user,
    required this.isArabic,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
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
          _UserTypeOption(
            title: t.translate('auth_individual'),
            subtitle: t.translate('profile_individual_desc'),
            icon: Icons.person,
            isSelected: user.userType == UserType.user,
            onTap: () => onTypeSelected(UserType.user),
          ),
          Divider(
            color: context.overlayBg,
            height: context.dynamicHeight(0.02),
          ),
          _UserTypeOption(
            title: t.translate('auth_institution'),
            subtitle: t.translate('profile_institution_desc'),
            icon: Icons.business,
            isSelected: user.userType == UserType.institution,
            onTap: () => onTypeSelected(UserType.institution),
          ),
        ],
      ),
    );
  }
}

class _UserTypeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _UserTypeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: context.dynamicHeight(0.015),
          horizontal: context.dynamicWidth(0.021),
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.purple50 : Colors.transparent,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
        ),
        child: Row(
          children: [
            _TypeIcon(icon: icon, isSelected: isSelected),
            SizedBox(width: context.dynamicWidth(0.04)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: context.dynamicWidth(0.04),
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.primaryColor
                          : context.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: context.dynamicWidth(0.029),
                      color: context.iconSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) _CheckIcon(),
          ],
        ),
      ),
    );
  }
}

class _TypeIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;

  const _TypeIcon({required this.icon, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.dynamicWidth(0.12),
      height: context.dynamicWidth(0.12),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [AppColors.primaryColor, AppColors.tertiaryColor],
              )
            : null,
        color: isSelected ? null : context.overlayBg,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
      ),
      child: Icon(
        icon,
        color: isSelected ? Colors.white : context.iconDefault,
        size: context.dynamicWidth(0.061),
      ),
    );
  }
}

class _CheckIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.dynamicWidth(0.061),
      height: context.dynamicWidth(0.061),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryColor, AppColors.tertiaryColor],
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check,
        color: Colors.white,
        size: context.dynamicWidth(0.035),
      ),
    );
  }
}
