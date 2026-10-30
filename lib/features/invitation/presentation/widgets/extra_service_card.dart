import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../data/models/extra_service_model.dart';
import '../cubit/invitation_cubit.dart';

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
      onTap: () => _onTap(context),
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
            _buildContent(context),
            if (isSelected) _buildSelectionIndicator(context),
          ],
        ),
      ),
    );
  }

  /// A service with levels asks which level first; tapping a picked one removes it.
  void _onTap(BuildContext context) {
    final cubit = context.read<InvitationCubit>();
    if (!service.hasLevels || isSelected) {
      cubit.toggleService(service);
      return;
    }
    _pickLevel(context, cubit);
  }

  Future<void> _pickLevel(BuildContext context, InvitationCubit cubit) async {
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
                _LevelTile(
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

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildIcon(context),
          SizedBox(height: context.dynamicHeight(0.015)),
          _buildPrimaryName(context),
          if (_firstInclude != null) ...[
            SizedBox(height: context.dynamicHeight(0.005)),
            _buildInclude(context, _firstInclude!),
          ] else if (service.name != service.nameAr) ...[
            SizedBox(height: context.dynamicHeight(0.005)),
            _buildSecondaryName(context),
          ],
          const Spacer(),
          _buildPrice(context),
        ],
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
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
                errorBuilder: (_, _, _) => _buildDefaultIcon(context),
              ),
            )
          : _buildDefaultIcon(context),
    );
  }

  Widget _buildDefaultIcon(BuildContext context) {
    return Icon(
      Icons.room_service,
      size: context.dynamicWidth(0.069),
      color: isSelected ? AppColors.primary : context.textSecondary,
    );
  }

  Widget _buildPrimaryName(BuildContext context) {
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

  String? get _firstInclude {
    final list = isEnglish ? service.includes : service.includesAr;
    return list.isEmpty ? null : list.first;
  }

  Widget _buildInclude(BuildContext context, String text) {
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

  Widget _buildSecondaryName(BuildContext context) {
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
  String _priceLabel(BuildContext context) {
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

  Widget _buildPrice(BuildContext context) {
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
        _priceLabel(context),
        style: TextStyle(
          fontSize: context.dynamicWidth(0.035),
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : context.textTertiary,
        ),
      ),
    );
  }

  Widget _buildSelectionIndicator(BuildContext context) {
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

class _LevelTile extends StatelessWidget {
  final ExtraServiceOptionModel option;
  final bool isEnglish;
  final VoidCallback onTap;

  const _LevelTile({required this.option, required this.isEnglish, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final includes = isEnglish ? option.includes : option.includesAr;
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusMd,
      child: Container(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEnglish ? option.name : option.nameAr,
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold, color: context.textPrimary),
                  ),
                  for (final item in includes.take(3))
                    Padding(
                      padding: const EdgeInsetsDirectional.only(top: AppSpacing.xxs),
                      child: Text(
                        '✓ $item',
                        style: TextStyle(fontSize: 13, color: context.textSecondary),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.smd),
            Text(
              '${option.price.toStringAsFixed(0)} ₪',
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
