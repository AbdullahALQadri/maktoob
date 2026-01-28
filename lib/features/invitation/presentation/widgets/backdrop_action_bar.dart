import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/core.dart';

/// Bottom action bar with backdrop blur effect.
class BackdropActionBar extends StatelessWidget {
  final String buttonText;
  final bool isEnabled;
  final VoidCallback? onPressed;

  const BackdropActionBar({
    super.key,
    required this.buttonText,
    required this.isEnabled,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.all(context.dynamicWidth(0.04)),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(
                color: AppColors.gray200.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                text: buttonText,
                onPressed: isEnabled ? onPressed : null,
                isDisabled: !isEnabled,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
