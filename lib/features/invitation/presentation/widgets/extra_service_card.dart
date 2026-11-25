import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../data/models/extra_service_model.dart';
import '../cubit/invitation_cubit.dart';
import 'service_level_tile.dart';
import 'extra_service_card_parts.dart';

/// Card widget for displaying an extra service option.
class ExtraServiceCard extends StatelessWidget {
  final ExtraServiceModel service;
  final bool isSelected;
  final bool isEnglish;

  const ExtraServiceCard({
    super.key,
    required this.service,
    required this.isSelected,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
          border: Border.all(
            color: isSelected ? AppColors.primary : context.borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: context.dynamicWidth(0.024),
              offset: Offset(0, context.dynamicHeight(0.005)),
            ),
          ],
        ),
        child: Stack(
          children: [
            buildContent(context),
            if (isSelected) buildSelectionIndicator(context),
          ],
        ),
      ),
    );
  }

  /// A service with levels asks which level first; tapping a picked one removes it.
  void onTap(BuildContext context) {
    final cubit = context.read<InvitationCubit>();
    if (!service.hasLevels || isSelected) {
      cubit.toggleService(service);
      return;
    }
    pickLevel(context, cubit);
  }

  Future<void> pickLevel(BuildContext context, InvitationCubit cubit) async {
    final l = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.cardBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.mdl, AppSpacing.md, AppSpacing.mdl, AppSpacing.mdl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEnglish ? service.name : service.nameAr,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: context.textPrimary),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l?.translate('service_choose_level') ?? '',
                style: TextStyle(fontSize: 14, color: context.textSecondary),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final option in service.options) ...[
                ServiceLevelTile(
                  option: option,
                  isEnglish: isEnglish,
                  onTap: () {
                    cubit.toggleService(service, optionId: option.id);
                    Navigator.of(sheetCtx).pop();
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildIcon(context),
          SizedBox(height: context.dynamicHeight(0.015)),
          buildPrimaryName(context),
          if (firstInclude != null) ...[
            SizedBox(height: context.dynamicHeight(0.005)),
            buildInclude(context, firstInclude!),
          ] else if (service.name != service.nameAr) ...[
            SizedBox(height: context.dynamicHeight(0.005)),
            buildSecondaryName(context),
          ],
          const Spacer(),
          buildPrice(context),
        ],
      ),
    );
  }

}
