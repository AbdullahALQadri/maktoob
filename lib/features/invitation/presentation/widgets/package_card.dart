import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';

/// Package card widget for displaying package options.
class PackageCard extends StatelessWidget {
  final PackageModel package;
  final bool isSelected;
  final int guestCount;
  final double? customPrice;
  final bool isLoadingPrice;
  final int? customLimit;
  final bool isEnglish;
  final TextEditingController? customLimitController;

  const PackageCard({
    super.key,
    required this.package,
    required this.isSelected,
    required this.guestCount,
    this.customPrice,
    this.isLoadingPrice = false,
    this.customLimit,
    required this.isEnglish,
    this.customLimitController,
  });

  bool get isCustom => package.isCustom;
  bool get isOverLimit =>
      !isCustom &&
      package.invitationLimit != null &&
      guestCount > package.invitationLimit!;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () => _onTap(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: context.dynamicHeight(0.02)),
        padding: EdgeInsets.all(context.dynamicWidth(0.051)),
        decoration: _buildDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, l),
            SizedBox(height: context.dynamicHeight(0.02)),
            const Divider(),
            SizedBox(height: context.dynamicHeight(0.015)),
            if (package.features.isNotEmpty) _buildFeatures(context),
            if (!isCustom && package.invitationLimit != null)
              _buildLimitInfo(context, l),
            if (isCustom && isSelected) _buildCustomInput(context, l),
          ],
        ),
      ),
    );
  }

  void _onTap(BuildContext context) {
    context.read<InvitationCubit>().selectPackage(package);
    if (isCustom && customLimitController != null) {
      customLimitController!.text = guestCount.toString();
      context.read<InvitationCubit>().setCustomPackageLimit(guestCount);
    }
  }

  BoxDecoration _buildDecoration(BuildContext context) {
    return BoxDecoration(
      color: isSelected
          ? AppColors.primary.withValues(alpha: 0.1)
          : Colors.white,
      borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
      border: Border.all(
        color: isSelected
            ? AppColors.primary
            : isOverLimit
                ? Colors.red.shade300
                : context.borderColor,
        width: isSelected ? 2 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: context.dynamicWidth(0.024),
          offset: Offset(0, context.dynamicHeight(0.005)),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations? l) {
    return Row(
      children: [
        _buildSelectionIndicator(context),
        SizedBox(width: context.dynamicWidth(0.029)),
        Expanded(child: _buildNameSection(context, l)),
        _buildPriceSection(context),
      ],
    );
  }

  Widget _buildSelectionIndicator(BuildContext context) {
    return Container(
      width: context.dynamicWidth(0.061),
      height: context.dynamicWidth(0.061),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.primary : Colors.transparent,
        border: Border.all(
          color: isSelected ? AppColors.primary : context.iconDefault,
          width: 2,
        ),
      ),
      child: isSelected
          ? Icon(Icons.check, color: Colors.white, size: context.dynamicWidth(0.04))
          : null,
    );
  }

  Widget _buildNameSection(BuildContext context, AppLocalizations? l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                isEnglish ? package.name : package.nameAr,
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.045),
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.primary : context.textPrimary,
                ),
              ),
            ),
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
            isEnglish ? package.nameAr : package.name,
            style: TextStyle(
              fontSize: context.dynamicWidth(0.029),
              color: context.textSecondary,
            ),
          ),
      ],
    );
  }

  Widget _buildPriceSection(BuildContext context) {
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
                : '${package.price.toStringAsFixed(0)} ₪',
            style: TextStyle(
              fontSize: context.dynamicWidth(0.045),
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : context.textPrimary,
            ),
          ),
          if (isLoadingPrice && isCustom && isSelected)
            SizedBox(
              width: context.dynamicWidth(0.04),
              height: context.dynamicWidth(0.04),
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatures(BuildContext context) {
    return Column(
      children: [
        ...package.features.map((feature) => Padding(
              padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.005)),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: context.dynamicWidth(0.045),
                    color: isSelected ? AppColors.primary : Colors.green.shade600,
                  ),
                  SizedBox(width: context.dynamicWidth(0.021)),
                  Expanded(
                    child: Text(
                      feature,
                      style: TextStyle(
                        fontSize: context.dynamicWidth(0.032),
                        color: context.textTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            )),
        SizedBox(height: context.dynamicHeight(0.015)),
      ],
    );
  }

  Widget _buildLimitInfo(BuildContext context, AppLocalizations? l) {
    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.029)),
      decoration: BoxDecoration(
        color: isOverLimit ? Colors.red.shade50 : context.overlayBg,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.021)),
        border: isOverLimit ? Border.all(color: Colors.red.shade300) : null,
      ),
      child: Row(
        children: [
          Icon(
            isOverLimit ? Icons.warning : Icons.mail_outline,
            size: context.dynamicWidth(0.051),
            color: isOverLimit ? Colors.red.shade700 : context.textSecondary,
          ),
          SizedBox(width: context.dynamicWidth(0.021)),
          Expanded(
            child: Text(
              '${l?.translate('invitation_invitation_limit') ?? 'Invitation limit'}: ${package.invitationLimit}',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.032),
                color: isOverLimit ? Colors.red.shade700 : context.textTertiary,
                fontWeight: isOverLimit ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (isOverLimit)
            Text(
              '${l?.translate('invitation_exceeded_by') ?? 'Exceeded by'} ${guestCount - package.invitationLimit!}',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.029),
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomInput(BuildContext context, AppLocalizations? l) {
    return Column(
      children: [
        SizedBox(height: context.dynamicHeight(0.02)),
        Container(
          padding: EdgeInsets.all(context.dynamicWidth(0.04)),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
            border: Border.all(color: Colors.purple.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l?.translate('invitation_specify_invitations') ??
                    'Specify the number of invitations needed',
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.035),
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade800,
                ),
              ),
              SizedBox(height: context.dynamicHeight(0.01)),
              Text(
                '${l?.translate('invitation_minimum') ?? 'Minimum'}: $guestCount (${l?.translate('invitation_current_guest_count') ?? 'current guest count'})',
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.029),
                  color: Colors.purple.shade600,
                ),
              ),
              SizedBox(height: context.dynamicHeight(0.015)),
              if (customLimitController != null)
                AppTextField(
                  controller: customLimitController!,
                  hintText: l?.translate('invitation_number_of_invitations') ??
                      'Number of invitations',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    final limit = int.tryParse(value);
                    if (limit != null && limit >= guestCount) {
                      context.read<InvitationCubit>().setCustomPackageLimit(limit);
                    }
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
