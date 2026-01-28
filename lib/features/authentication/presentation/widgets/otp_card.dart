import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';

/// OTP input card with verification button and resend.
class OtpCard extends StatelessWidget {
  final TextEditingController pinController;
  final FocusNode focusNode;
  final bool isVerifying;
  final bool canResend;
  final int resendSeconds;
  final VoidCallback onVerify;
  final VoidCallback onResend;
  final VoidCallback onChanged;

  const OtpCard({
    super.key,
    required this.pinController,
    required this.focusNode,
    required this.isVerifying,
    required this.canResend,
    required this.resendSeconds,
    required this.onVerify,
    required this.onResend,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.061)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _OtpPinput(
            controller: pinController,
            focusNode: focusNode,
            onCompleted: onVerify,
            onChanged: onChanged,
          ),
          SizedBox(height: context.dynamicHeight(0.03)),
          _VerifyButton(
            canVerify: pinController.text.length == 6 && !isVerifying,
            isVerifying: isVerifying,
            onPressed: onVerify,
          ),
          SizedBox(height: context.dynamicHeight(0.025)),
          _ResendSection(
            canResend: canResend,
            resendSeconds: resendSeconds,
            onResend: onResend,
            t: t,
          ),
        ],
      ),
    );
  }
}

class _OtpPinput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onCompleted;
  final VoidCallback onChanged;

  const _OtpPinput({
    required this.controller,
    required this.focusNode,
    required this.onCompleted,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final pinWidth = context.dynamicWidth(0.12);
    final pinHeight = context.dynamicHeight(0.07);
    final fontSize = context.dynamicWidth(0.056);

    final defaultPinTheme = PinTheme(
      width: pinWidth,
      height: pinHeight,
      textStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: AppColors.gray900,
      ),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200, width: 1.5),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor, width: 1.5),
      ),
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Pinput(
        length: 6,
        controller: controller,
        focusNode: focusNode,
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: focusedPinTheme,
        submittedPinTheme: submittedPinTheme,
        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
        showCursor: true,
        cursor: Container(
          width: 2,
          height: fontSize,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        separatorBuilder: (index) => SizedBox(width: context.dynamicWidth(0.021)),
        hapticFeedbackType: HapticFeedbackType.lightImpact,
        closeKeyboardWhenCompleted: true,
        keyboardType: TextInputType.number,
        onCompleted: (_) => onCompleted(),
        onChanged: (_) => onChanged(),
      ),
    );
  }
}

class _VerifyButton extends StatelessWidget {
  final bool canVerify;
  final bool isVerifying;
  final VoidCallback onPressed;

  const _VerifyButton({
    required this.canVerify,
    required this.isVerifying,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return PrimaryButton(
      text: t.translate('auth_verify'),
      onPressed: canVerify ? onPressed : null,
      isLoading: isVerifying,
      isDisabled: !canVerify,
    );
  }
}

class _ResendSection extends StatelessWidget {
  final bool canResend;
  final int resendSeconds;
  final VoidCallback onResend;
  final AppLocalizations t;

  const _ResendSection({
    required this.canResend,
    required this.resendSeconds,
    required this.onResend,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Column(
      children: [
        Text(
          t.translate('auth_no_code'),
          style: AppTextStyles.bodySmall,
        ),
        SizedBox(height: context.dynamicHeight(0.01)),
        if (canResend)
          AppTextButton(
            text: t.translate('auth_resend_code'),
            onPressed: onResend,
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer_outlined, size: 18, color: AppColors.gray400),
              const SizedBox(width: 6),
              Text(
                isArabic
                    ? 'إعادة الإرسال بعد $resendSeconds ثانية'
                    : 'Resend in $resendSeconds seconds',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
      ],
    );
  }
}
