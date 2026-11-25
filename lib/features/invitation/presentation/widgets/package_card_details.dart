import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../cubit/invitation_cubit.dart';
import 'package_card.dart';

/// Parts of [PackageCard], kept here so each file stays short.
extension PackageCardDetails on PackageCard {
  Widget buildFeatures(BuildContext context) {
    final l = AppLocalizations.of(context);
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
                      l?.translateOr(feature, feature) ?? feature,
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

  Widget buildLimitInfo(BuildContext context, AppLocalizations? l) {
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

  Widget buildCustomInput(BuildContext context, AppLocalizations? l) {
    final minRequired = guestCount < 1 ? 1 : guestCount;

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
                '${l?.translate('invitation_minimum') ?? 'Minimum'}: $minRequired (${l?.translate('invitation_current_guest_count') ?? 'current guest count'})',
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l?.translate('invitation_enter_count') ??
                          'Enter the number of invitations';
                    }
                    final limit = int.tryParse(value);
                    if (limit == null || limit < 1) {
                      return l?.translate('invitation_min_one') ??
                          'Minimum 1 invitation';
                    }
                    if (limit < minRequired) {
                      return '${l?.translate('invitation_min_guests_required') ?? 'Minimum'}: $minRequired';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    final limit = int.tryParse(value);
                    context.read<InvitationCubit>().setCustomPackageLimit(limit ?? 0);
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
