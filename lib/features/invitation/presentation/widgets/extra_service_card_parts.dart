import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../data/models/extra_service_model.dart';
import '../cubit/invitation_cubit.dart';
import 'extra_service_card.dart';

/// Parts of [ExtraServiceCard], kept here so each file stays short.
extension ExtraServiceCardParts on ExtraServiceCard {
  Widget buildIcon(BuildContext context) {
    return Container(
      width: context.dynamicWidth(0.141),
      height: context.dynamicWidth(0.141),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.2)
            : context.overlayBg,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
      ),
      child: service.iconUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
              child: Image.network(
                service.iconUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => buildDefaultIcon(context),
              ),
            )
          : buildDefaultIcon(context),
    );
  }

  Widget buildDefaultIcon(BuildContext context) {
    return Icon(
      Icons.room_service,
      size: context.dynamicWidth(0.069),
      color: isSelected ? AppColors.primary : context.textSecondary,
    );
  }

  Widget buildPrimaryName(BuildContext context) {
    return Text(
      isEnglish ? service.name : service.nameAr,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: context.dynamicWidth(0.035),
        fontWeight: FontWeight.bold,
        color: isSelected ? AppColors.primary : context.textPrimary,
      ),
    );
  }

  String? get firstInclude {
    final list = isEnglish ? service.includes : service.includesAr;
    return list.isEmpty ? null : list.first;
  }

  Widget buildInclude(BuildContext context, String text) {
    return Text(
      '✓ $text',
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: context.dynamicWidth(0.029),
        color: context.textSecondary,
      ),
    );
  }

  Widget buildSecondaryName(BuildContext context) {
    return Text(
      isEnglish ? service.nameAr : service.name,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: context.dynamicWidth(0.029),
        color: context.iconSecondary,
      ),
    );
  }

  /// The picked level's price, or "from" the cheapest when the service has levels.
  String priceLabel(BuildContext context) {
    final picked = context.select<InvitationCubit, ExtraServiceModel?>(
      (c) {
        for (final s in c.state.selectedServices) {
          if (s.id == service.id) return s;
        }
        return null;
      },
    );
    final amount = '${(picked?.effectivePrice ?? service.price).toStringAsFixed(0)} ₪';
    if (picked == null && service.hasLevels) {
      return '${AppLocalizations.of(context)?.translate('service_from') ?? ''} $amount'.trim();
    }
    return amount;
  }

  Widget buildPrice(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.029),
        vertical: context.dynamicHeight(0.007),
      ),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : context.overlayBg,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.051)),
      ),
      child: Text(
        priceLabel(context),
        style: TextStyle(
          fontSize: context.dynamicWidth(0.035),
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : context.textTertiary,
        ),
      ),
    );
  }

  Widget buildSelectionIndicator(BuildContext context) {
    return Positioned(
      top: context.dynamicWidth(0.021),
      right: context.dynamicWidth(0.021),
      child: Container(
        width: context.dynamicWidth(0.061),
        height: context.dynamicWidth(0.061),
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check,
          color: Colors.white,
          size: context.dynamicWidth(0.04),
        ),
      ),
    );
  }
}
