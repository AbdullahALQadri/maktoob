import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';

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
        border: Border.all(color: Colors.grey.shade300),
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
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
        _CompanionSwitch(isEnabled: _isEnabled),
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
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.015)),
        Row(
          children: [
            _CompanionButton(
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
            _CompanionCounter(count: state.partnerWithGuests ?? 1),
            _CompanionButton(
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

class _CompanionSwitch extends StatelessWidget {
  final bool isEnabled;

  const _CompanionSwitch({required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isEnabled) {
          context.read<InvitationCubit>().updatePartnerWithGuests(null);
        } else {
          context.read<InvitationCubit>().updatePartnerWithGuests(1);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: context.dynamicWidth(0.141),
        height: context.dynamicWidth(0.08),
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.primary : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: isEnabled ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: context.dynamicWidth(0.061),
            height: context.dynamicWidth(0.061),
            margin:
                EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.011)),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _CompanionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _CompanionButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onPressed != null ? AppColors.primary : Colors.grey.shade300,
      borderRadius: BorderRadius.circular(context.dynamicWidth(0.021)),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.021)),
        child: Container(
          width: context.dynamicWidth(0.12),
          height: context.dynamicWidth(0.12),
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: Colors.white,
            size: context.dynamicWidth(0.061),
          ),
        ),
      ),
    );
  }
}

class _CompanionCounter extends StatelessWidget {
  final int count;

  const _CompanionCounter({required this.count});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.04)),
        padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.015)),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.021)),
        ),
        child: Text(
          '$count',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: context.dynamicWidth(0.051),
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
