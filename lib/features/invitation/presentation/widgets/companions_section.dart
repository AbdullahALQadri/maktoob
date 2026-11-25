import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';
import 'companions_controls.dart';

/// Companions section for allowing guests to bring companions.
class CompanionsSection extends StatelessWidget {
  final InvitationState state;

  const CompanionsSection({super.key, required this.state});

  bool get _isEnabled =>
      state.partnerWithGuests != null && state.partnerWithGuests! > 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSwitchRow(context, l),
          if (_isEnabled) ...[
            SizedBox(height: context.dynamicHeight(0.02)),
            _buildCounterSection(context, l),
          ],
        ],
      ),
    );
  }

  Widget _buildSwitchRow(BuildContext context, AppLocalizations? l) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.people_outline,
                color: AppColors.primary,
                size: context.dynamicWidth(0.056),
              ),
              SizedBox(width: context.dynamicWidth(0.029)),
              Flexible(
                child: Text(
                  l?.translate('invitation_allow_companions') ??
                      'Allow Companions',
                  style: TextStyle(
                    fontSize: context.dynamicWidth(0.037),
                    fontWeight: FontWeight.w500,
                    color: context.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        CompanionSwitch(isEnabled: _isEnabled),
      ],
    );
  }

  Widget _buildCounterSection(BuildContext context, AppLocalizations? l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l?.translate('invitation_companions_count') ??
              'Number of companions per guest (1-10)',
          style: TextStyle(
            fontSize: context.dynamicWidth(0.032),
            color: context.textSecondary,
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.015)),
        Row(
          children: [
            CompanionButton(
              icon: Icons.remove,
              onPressed: (state.partnerWithGuests ?? 1) > 1
                  ? () {
                      final newValue = (state.partnerWithGuests ?? 1) - 1;
                      context
                          .read<InvitationCubit>()
                          .updatePartnerWithGuests(newValue);
                    }
                  : null,
            ),
            CompanionCounter(count: state.partnerWithGuests ?? 1),
            CompanionButton(
              icon: Icons.add,
              onPressed: (state.partnerWithGuests ?? 1) < 10
                  ? () {
                      final newValue = (state.partnerWithGuests ?? 1) + 1;
                      context
                          .read<InvitationCubit>()
                          .updatePartnerWithGuests(newValue);
                    }
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}
