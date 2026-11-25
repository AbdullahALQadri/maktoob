import 'package:flutter/material.dart';
import '../../../../../core/core.dart';
import '../../cubit/invitation_state.dart';

/// Step A of the type picker: occasion groups in a 2-column grid.
class EventTypeGroupGrid extends StatelessWidget {
  final List<EventTypeGroupModel> groups;
  final bool isEnglish;
  final int? selectedGroupId;
  final ValueChanged<EventTypeGroupModel> onTap;

  const EventTypeGroupGrid({
    super.key,
    required this.groups,
    required this.isEnglish,
    required this.selectedGroupId,
    required this.onTap,
  });

  static IconData iconForGroup(EventTypeGroupModel g) {
    switch (g.slug) {
      case 'weddings':
        return Icons.favorite_rounded;
      case 'births':
        return Icons.child_friendly_rounded;
      case 'graduation':
        return Icons.school_rounded;
      case 'religious-social':
        return Icons.mosque_rounded;
      case 'business':
        return Icons.business_center_rounded;
      default:
        return Icons.more_horiz_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.mdl, AppSpacing.sm, AppSpacing.mdl, AppSpacing.sm),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.smd,
        crossAxisSpacing: AppSpacing.smd,
        childAspectRatio: 1.5,
      ),
      itemCount: groups.length,
      itemBuilder: (_, i) {
        final g = groups[i];
        final selected = g.id == selectedGroupId;
        return InkWell(
          onTap: () => onTap(g),
          borderRadius: AppSpacing.borderRadiusLg,
          child: Container(
            padding: const EdgeInsetsDirectional.all(AppSpacing.smd),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primaryColor.withValues(alpha: 0.08)
                  : AppColors.white,
              borderRadius: AppSpacing.borderRadiusLg,
              border: Border.all(
                color: selected ? AppColors.primaryColor : AppColors.gray200,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(iconForGroup(g), color: AppColors.primaryColor, size: 28),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  isEnglish ? g.nameEn : g.nameAr,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


class EventTypePickerNotice extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String primaryLabel;
  final VoidCallback onPrimaryTap;
  final String secondaryLabel;
  final VoidCallback onSecondaryTap;

  const EventTypePickerNotice({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primaryLabel,
    required this.onPrimaryTap,
    required this.secondaryLabel,
    required this.onSecondaryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: AppColors.gray400),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.gray500,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: onPrimaryTap,
            child: Text(primaryLabel),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onSecondaryTap,
            child: Text(
              secondaryLabel,
              style: TextStyle(color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}


class EventTypePickerRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const EventTypePickerRow({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: context.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_rounded, color: AppColors.primaryColor),
          ],
        ),
      ),
    );
  }
}
