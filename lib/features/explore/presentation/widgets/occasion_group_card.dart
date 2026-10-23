import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../domain/entities/occasion_group_entity.dart';

/// Flat, outlined card for one occasion group in the explore grid.
class OccasionGroupCard extends StatelessWidget {
  final OccasionGroupEntity group;
  final bool selected;
  final VoidCallback onTap;

  const OccasionGroupCard({
    super.key,
    required this.group,
    required this.selected,
    required this.onTap,
  });

  static IconData iconFor(String slug) {
    switch (slug) {
      case 'weddings':
        return Icons.favorite_outline;
      case 'births':
        return Icons.child_friendly_outlined;
      case 'graduation':
        return Icons.school_outlined;
      case 'religious-social':
        return Icons.mosque_outlined;
      case 'business':
        return Icons.business_center_outlined;
      default:
        return Icons.celebration_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final accent = selected ? AppColors.primaryColor : context.borderColor;

    return Material(
      color: selected
          ? AppColors.primaryColor.withValues(alpha: 0.08)
          : context.themeSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(color: accent, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(AppSpacing.smd),
          child: Row(
            children: [
              Icon(
                iconFor(group.slug),
                size: 22,
                color: selected ? AppColors.primaryColor : context.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  group.localizedName(lang),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: context.textPrimary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
