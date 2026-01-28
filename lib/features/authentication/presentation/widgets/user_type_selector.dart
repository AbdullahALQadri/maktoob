import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../domain/entities/user_entity.dart';

/// User type selector (Individual / Institution).
class UserTypeSelector extends StatelessWidget {
  final UserType selectedType;
  final ValueChanged<UserType> onChanged;

  const UserTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.translate('auth_account_type'),
          style: AppTextStyles.labelMedium.copyWith(color: AppColors.gray700),
        ),
        SizedBox(height: context.dynamicHeight(0.01)),
        Container(
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(
                child: _UserTypeOption(
                  type: UserType.user,
                  isSelected: selectedType == UserType.user,
                  icon: Icons.person_rounded,
                  label: t.translate('auth_individual'),
                  onTap: () => onChanged(UserType.user),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _UserTypeOption(
                  type: UserType.institution,
                  isSelected: selectedType == UserType.institution,
                  icon: Icons.business_rounded,
                  label: t.translate('auth_institution'),
                  onTap: () => onChanged(UserType.institution),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UserTypeOption extends StatelessWidget {
  final UserType type;
  final bool isSelected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _UserTypeOption({
    required this.type,
    required this.isSelected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.015)),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.gray500,
              size: context.dynamicWidth(0.051),
            ),
            SizedBox(width: context.dynamicWidth(0.021)),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
