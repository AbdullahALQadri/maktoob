import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

import '../../utils/app_colors.dart';

/// The six boxes of a verification code. The boxes shrink to the space they
/// get, so the code fits a 320-wide phone with large text, and digits are
/// always laid out left to right.
class OtpPinField extends StatelessWidget {
  const OtpPinField({
    super.key,
    required this.controller,
    this.focusNode,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  static const _gap = 8.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = ((constraints.maxWidth - _gap * (length - 1)) / length).clamp(32.0, 48.0);
        PinTheme theme(Color fill, Color border, double borderWidth) => PinTheme(
          width: width,
          height: width * 1.18,
          textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: context.textPrimary),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border, width: borderWidth),
          ),
        );

        return Directionality(
          textDirection: TextDirection.ltr,
          child: Pinput(
            length: length,
            controller: controller,
            focusNode: focusNode,
            autofocus: autofocus,
            separatorBuilder: (_) => const SizedBox(width: _gap),
            defaultPinTheme: theme(context.themeSurface, context.borderColor, 1.5),
            focusedPinTheme: theme(context.themeSurface, AppColors.primaryColor, 2),
            submittedPinTheme: theme(context.primaryWash, AppColors.primaryColor, 1.5),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            hapticFeedbackType: HapticFeedbackType.lightImpact,
            closeKeyboardWhenCompleted: true,
            showCursor: true,
            onCompleted: onCompleted,
            onChanged: onChanged,
          ),
        );
      },
    );
  }
}
