import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';
import 'package_card_sections.dart';
import 'package_card_details.dart';

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
      !package.hasUnlimitedInvitations &&
      package.invitationLimit != null &&
      guestCount > package.invitationLimit!;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () => onTap(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: context.dynamicHeight(0.02)),
        padding: EdgeInsets.all(context.dynamicWidth(0.051)),
        decoration: buildDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeader(context, l),
            SizedBox(height: context.dynamicHeight(0.02)),
            const Divider(),
            SizedBox(height: context.dynamicHeight(0.015)),
            if (package.features.isNotEmpty) buildFeatures(context),
            if (!isCustom && package.invitationLimit != null)
              buildLimitInfo(context, l),
            if (isCustom && isSelected) buildCustomInput(context, l),
          ],
        ),
      ),
    );
  }

  void onTap(BuildContext context) {
    final l = AppLocalizations.of(context);
    context.read<InvitationCubit>().selectPackage(package);
    if (isCustom && customLimitController != null) {
      customLimitController!.text = guestCount.toString();
      context.read<InvitationCubit>().setCustomPackageLimit(guestCount);
      AppSnackBar.showInfo(
        context,
        title: l?.translate('invitation_custom_package_info_title') ??
            'Custom Package',
        message: l?.translate('invitation_custom_package_info_message') ??
            'The number of invitations must be equal to or greater than the number of guests ($guestCount). You can adjust the number below.',
        duration: const Duration(seconds: 5),
      );
    }
  }

  BoxDecoration buildDecoration(BuildContext context) {
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

  Widget buildHeader(BuildContext context, AppLocalizations? l) {
    return Row(
      children: [
        buildSelectionIndicator(context),
        SizedBox(width: context.dynamicWidth(0.029)),
        Expanded(child: buildNameSection(context, l)),
        buildPriceSection(context),
      ],
    );
  }

  Widget buildSelectionIndicator(BuildContext context) {
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

}
