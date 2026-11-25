import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/core.dart';
import '../cubit/invitation_cubit.dart';

class CompanionSwitch extends StatelessWidget {
  final bool isEnabled;

  const CompanionSwitch({super.key, required this.isEnabled});

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
          color: isEnabled ? AppColors.primary : context.borderColor,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: isEnabled
              ? AlignmentDirectional.centerEnd
              : AlignmentDirectional.centerStart,
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


class CompanionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const CompanionButton({super.key, required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onPressed != null ? AppColors.primary : context.borderColor,
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


class CompanionCounter extends StatelessWidget {
  final int count;

  const CompanionCounter({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.04)),
        padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.015)),
        decoration: BoxDecoration(
          color: context.overlayBg,
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
