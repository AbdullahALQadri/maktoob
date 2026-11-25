import 'package:flutter/material.dart';
import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import 'package:maktoob/core/widgets/loading/mk_spinner.dart';
import 'package_card.dart';

/// Parts of [PackageCard], kept here so each file stays short.
extension PackageCardSections on PackageCard {
  Widget buildNameSection(BuildContext context, AppLocalizations? l) {
    final primaryName   = isEnglish ? package.name : package.nameAr;
    final secondaryName = isEnglish ? package.nameAr : package.name;
    // The custom package stores its name/features as i18n keys; translate when
    // the value is a known key, otherwise show as-is (standard packages).
    final displayName      = l?.translateOr(primaryName, primaryName) ?? primaryName;
    final displaySecondary = l?.translateOr(secondaryName, secondaryName) ?? secondaryName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                displayName,
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.045),
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.primary : context.textPrimary,
                ),
              ),
            ),
            if (package.isPrivate) ...[
              SizedBox(width: context.dynamicWidth(0.021)),
              Container(
                key: const Key('package_private_badge'),
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Text(
                  l?.translate('package_private_badge') ?? '',
                  style: TextStyle(
                    fontSize: context.dynamicWidth(0.024),
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            if (isCustom) ...[
              SizedBox(width: context.dynamicWidth(0.021)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.dynamicWidth(0.021),
                  vertical: context.dynamicHeight(0.002),
                ),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(context.dynamicWidth(0.021)),
                ),
                child: Text(
                  l?.translate('invitation_custom') ?? 'Custom',
                  style: TextStyle(
                    fontSize: context.dynamicWidth(0.024),
                    color: Colors.purple.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (package.name != package.nameAr)
          Text(
            displaySecondary,
            style: TextStyle(
              fontSize: context.dynamicWidth(0.029),
              color: context.textSecondary,
            ),
          ),
        // Volume pricing: what one invitation costs, and the saving on
        // bigger packages (no tax, prices are final).
        if (!isCustom && package.pricePerInvitation != null) ...[
          SizedBox(height: context.dynamicHeight(0.006)),
          Wrap(
            spacing: context.dynamicWidth(0.016),
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '${package.pricePerInvitation!.toStringAsFixed(2)} ₪ ${l?.translate('package_per_invitation') ?? ''}',
                key: const Key('package_per_invitation'),
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.029),
                  color: context.textSecondary,
                ),
              ),
              if (package.volumeSavingPercent > 0)
                Container(
                  key: const Key('package_volume_saving'),
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.green50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.green100),
                  ),
                  child: Text(
                    (l?.translate('package_volume_saving') ?? '%s%')
                        .replaceAll('%s', '${package.volumeSavingPercent}'),
                    style: TextStyle(
                      fontSize: context.dynamicWidth(0.026),
                      color: AppColors.green600,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget buildPriceSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.04),
        vertical: context.dynamicHeight(0.01),
      ),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : context.overlayBg,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
      ),
      child: Column(
        children: [
          Text(
            isCustom && customPrice != null
                ? '${customPrice!.toStringAsFixed(0)} ₪'
                : '${package.effectivePrice.toStringAsFixed(0)} ₪',
            style: TextStyle(
              fontSize: context.dynamicWidth(0.045),
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : context.textPrimary,
            ),
          ),
          // Institution discount: show the original price struck through.
          if (!isCustom && package.hasDiscount)
            Text(
              '${package.price.toStringAsFixed(0)} ₪',
              key: const Key('package_original_price'),
              style: TextStyle(
                fontSize: context.dynamicWidth(0.029),
                decoration: TextDecoration.lineThrough,
                color: isSelected ? Colors.white70 : context.textSecondary,
              ),
            ),
          if (isLoadingPrice && isCustom && isSelected)
            SizedBox(
              width: context.dynamicWidth(0.04),
              height: context.dynamicWidth(0.04),
              child: const MkSpinner(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}
