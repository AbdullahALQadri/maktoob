import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/snackbar/app_snackbar.dart';
import '../../domain/entities/user_entity.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  final UserType userType;
  final VoidCallback onVerified;
  final VoidCallback onBack;

  const OtpVerificationScreen({
    super.key,
    required this.phone,
    required this.userType,
    required this.onVerified,
    required this.onBack,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with SingleTickerProviderStateMixin {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  Timer? _resendTimer;
  int _resendSeconds = 60;
  bool _canResend = false;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
    _startResendTimer();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _resendTimer?.cancel();
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendSeconds = 60;
    _canResend = false;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendSeconds > 0) {
          _resendSeconds--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  void _verifyOtp() {
    if (_pinController.text.length == 6) {
      setState(() {
        _isVerifying = true;
      });

      // Simulate OTP verification
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isVerifying = false;
          });
          widget.onVerified();
        }
      });
    }
  }

  void _resendOtp() {
    if (_canResend) {
      _startResendTimer();
      _pinController.clear();
      // Show snackbar
      AppSnackBar.showSuccess(
        context,
        message: AppLocalizations.of(context)!.translate('auth_new_code_sent'),
      );
    }
  }

  bool get _isArabic {
    return Localizations.localeOf(context).languageCode == 'ar';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryColor,
              AppColors.primaryColor.withValues(alpha: 0.85),
              AppColors.tertiaryColor.withValues(alpha: 0.9),
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: Stack(
          children: [
            _buildDecorativePattern(),
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 23.w,
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        SizedBox(height: 16.h),
                        _buildHeader(),
                        SizedBox(height: 32.h),
                        _buildIcon(),
                        SizedBox(height: 24.h),
                        _buildTitle(),
                        SizedBox(height: 32.h),
                        _buildOtpCard(),
                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativePattern() {
    return Stack(
      children: [
        Positioned(
          top: -113.w,
          right: -75.w,
          child: Container(
            width: 263.w,
            height: 263.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1.5,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 81.h,
          left: -94.w,
          child: Container(
            width: 188.w,
            height: 188.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: widget.onBack,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
        SizedBox(width: 15.w),
        Expanded(
          child: Text(
            AppLocalizations.of(context)!.translate('auth_phone_verification'),
            style: TextStyle(
              fontSize: 21.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 105.w,
      height: 105.w,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        Icons.sms_outlined,
        size: 53.w,
        color: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildTitle() {
    final t = AppLocalizations.of(context)!;
    return Column(
      children: [
        Text(
          t.translate('auth_enter_code'),
          style: TextStyle(
            fontSize: 21.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          t.translate('auth_code_sent_to'),
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.phone,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpCard() {
    return Container(
      padding: EdgeInsets.all(23.w),
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
          // OTP Pinput
          _buildPinput(),
          SizedBox(height: 24.h),

          // Verify Button
          _buildVerifyButton(),
          SizedBox(height: 20.h),

          // Resend Section
          _buildResendSection(),
        ],
      ),
    );
  }

  Widget _buildPinput() {
    // Calculate responsive sizes
    final pinWidth = 45.w;
    final pinHeight = 57.h;
    final fontSize = 21.w;

    // Default theme for unfocused state
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
        border: Border.all(
          color: AppColors.gray200,
          width: 1.5,
        ),
      ),
    );

    // Focused theme
    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );

    // Submitted (filled) theme
    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryColor,
          width: 1.5,
        ),
      ),
    );

    // Error theme
    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.red500.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.red500,
          width: 1.5,
        ),
      ),
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Pinput(
        length: 6,
        controller: _pinController,
        focusNode: _focusNode,
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: focusedPinTheme,
        submittedPinTheme: submittedPinTheme,
        errorPinTheme: errorPinTheme,
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
        separatorBuilder: (index) => SizedBox(width: 8.w),
        hapticFeedbackType: HapticFeedbackType.lightImpact,
        closeKeyboardWhenCompleted: true,
        keyboardType: TextInputType.number,
        animationCurve: Curves.easeOutCubic,
        animationDuration: const Duration(milliseconds: 200),
        onCompleted: (pin) {
          _verifyOtp();
        },
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildVerifyButton() {
    final bool canVerify = _pinController.text.length == 6 && !_isVerifying;

    return Container(
      width: double.infinity,
      height: 53.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: canVerify
            ? LinearGradient(
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withValues(alpha: 0.85),
                ],
              )
            : null,
        color: canVerify ? null : AppColors.gray300,
        boxShadow: canVerify
            ? [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: canVerify ? _verifyOtp : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: AppColors.gray500,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isVerifying
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              )
            : Text(
                AppLocalizations.of(context)!.translate('auth_verify'),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _buildResendSection() {
    final t = AppLocalizations.of(context)!;
    return Column(
      children: [
        Text(
          t.translate('auth_no_code'),
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColors.gray500,
          ),
        ),
        SizedBox(height: 8.h),
        if (_canResend)
          GestureDetector(
            onTap: _resendOtp,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                t.translate('auth_resend_code'),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timer_outlined,
                size: 18,
                color: AppColors.gray400,
              ),
              SizedBox(width: 6),
              Text(
                _isArabic
                    ? 'إعادة الإرسال بعد $_resendSeconds ثانية'
                    : 'Resend in $_resendSeconds seconds',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.gray400,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
