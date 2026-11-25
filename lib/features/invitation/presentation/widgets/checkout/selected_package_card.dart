import 'package:flutter/material.dart';
import '../../../../../config/locale/app_localizations.dart';
import '../../../../../core/core.dart';
import '../../cubit/invitation_state.dart';
import '../../widgets/widgets.dart';
import 'package_overview.dart';

class SelectedPackageCard extends StatelessWidget {
  final InvitationState state;
  final bool isEnglish;
  final TextEditingController customLimitController;

  const SelectedPackageCard({
    super.key,
    required this.state,
    required this.isEnglish,
    required this.customLimitController,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingPackages) {
      return const PackageListSkeleton();
    }

    final selected = state.selectedPackage;
    final l = AppLocalizations.of(context);

    if (selected == null) {
      return PackagePicker(state: state, isEnglish: isEnglish);
    }

    // Custom packages price/limit live on the wizard state, not the package row.
    final isCustom = selected.isCustom;
    final price = isCustom
        ? (state.customPackagePrice ?? selected.price)
        : selected.effectivePrice;
    final int? invites = isCustom
        ? state.customPackageLimit
        : selected.invitationLimit;
    final infoText = selected.hasUnlimitedInvitations && !isCustom
        ? (l?.translate('invitation_unlimited') ?? 'دعوات غير محدودة')
        : (invites != null && invites > 0
              ? '$invites ${l?.translate('invitation_invitation_unit') ?? 'دعوة'}'
              : (l?.translate('invitation_package_subtitle') ?? 'خدمة شاملة'));

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primaryColor, AppColors.tertiaryColor],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(1.5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryColor.withValues(alpha: 0.25),
                ),
              ),
              child: Icon(
                isCustom ? Icons.tune_rounded : Icons.workspace_premium_rounded,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          l?.translateOr(
                                isEnglish ? selected.name : selected.nameAr,
                                isEnglish ? selected.name : selected.nameAr,
                              ) ??
                              (isEnglish ? selected.name : selected.nameAr),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: context.textPrimary,
                          ),
                        ),
                      ),
                      if (isCustom) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: context.brandInk.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusFull,
                            ),
                          ),
                          child: Text(
                            l?.translate('invitation_custom') ?? 'مخصصة',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: context.brandInk,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.mail_outline_rounded,
                        size: 14,
                        color: context.textSecondary,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          infoText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  price.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryColor,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '₪',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
