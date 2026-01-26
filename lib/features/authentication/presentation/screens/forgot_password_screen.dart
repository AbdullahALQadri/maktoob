import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/media_query_values.dart';

/// Main Forgot Password Screen - Enter phone number
class ForgotPasswordScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onSuccess;

  const ForgotPasswordScreen({
    super.key,
    this.onBack,
    this.onSuccess,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool get _isArabic {
    return Localizations.localeOf(context).languageCode == 'ar';
  }

  void _handleSendOtp() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          // Navigate to OTP screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ForgotPasswordOtpScreen(
                phone: '+970${_phoneController.text.trim()}',
                onBack: () => Navigator.pop(context),
                onVerified: () {
                  // Navigate to reset password screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResetPasswordScreen(
                        phone: '+970${_phoneController.text.trim()}',
                        onBack: () => Navigator.pop(context),
                        onSuccess: () {
                          // Show success and go back to login
                          Navigator.of(context).popUntil((route) => route.isFirst);
                          widget.onSuccess?.call();
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }
      });
    }
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
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.dynamicWidth(0.06),
                    ),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            SizedBox(height: context.dynamicHeight(0.02)),
                            _buildHeader(),
                            SizedBox(height: context.dynamicHeight(0.06)),
                            _buildIcon(),
                            SizedBox(height: context.dynamicHeight(0.03)),
                            _buildTitle(),
                            SizedBox(height: context.dynamicHeight(0.04)),
                            _buildFormCard(),
                            SizedBox(height: context.dynamicHeight(0.04)),
                          ],
                        ),
                      ),
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
          top: -context.dynamicWidth(0.3),
          right: -context.dynamicWidth(0.2),
          child: Container(
            width: context.dynamicWidth(0.7),
            height: context.dynamicWidth(0.7),
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
          bottom: context.dynamicHeight(0.1),
          left: -context.dynamicWidth(0.25),
          child: Container(
            width: context.dynamicWidth(0.5),
            height: context.dynamicWidth(0.5),
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
          onTap: widget.onBack ?? () => Navigator.pop(context),
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
        SizedBox(width: context.dynamicWidth(0.04)),
        Expanded(
          child: Text(
            _isArabic ? 'نسيت كلمة المرور' : 'Forgot Password',
            style: TextStyle(
              fontSize: context.dynamicWidth(0.055),
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
      width: context.dynamicWidth(0.28),
      height: context.dynamicWidth(0.28),
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
        Icons.lock_reset_rounded,
        size: context.dynamicWidth(0.14),
        color: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          _isArabic ? 'استعادة كلمة المرور' : 'Reset Your Password',
          style: TextStyle(
            fontSize: context.dynamicWidth(0.055),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.015)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.05)),
          child: Text(
            _isArabic
                ? 'أدخل رقم هاتفك المسجل وسنرسل لك رمز التحقق'
                : 'Enter your registered phone number and we\'ll send you a verification code',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.dynamicWidth(0.038),
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.all(context.dynamicWidth(0.06)),
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Phone Field
                _buildPhoneField(),
                SizedBox(height: context.dynamicHeight(0.03)),
                // Send OTP Button
                _buildSendButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isArabic ? 'رقم الهاتف' : 'Phone Number',
          style: TextStyle(
            fontSize: context.dynamicWidth(0.035),
            fontWeight: FontWeight.w600,
            color: AppColors.gray700,
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.008)),
        Row(
          children: [
            // Palestine Code
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.dynamicWidth(0.03),
                vertical: context.dynamicHeight(0.018),
              ),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gray200),
              ),
              child: Row(
                children: [
                  Text('🇵🇸', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 6),
                  Text(
                    '+970',
                    style: TextStyle(
                      fontSize: context.dynamicWidth(0.038),
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: context.dynamicWidth(0.02)),
            // Phone Input
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.04),
                  color: AppColors.gray900,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: _isArabic ? 'أدخل رقم الهاتف' : 'Enter phone number',
                  hintStyle: TextStyle(
                    color: AppColors.gray400,
                    fontSize: context.dynamicWidth(0.035),
                  ),
                  prefixIcon: Container(
                    margin: const EdgeInsetsDirectional.only(start: 14, end: 10),
                    child: Icon(
                      Icons.phone_outlined,
                      color: AppColors.primaryColor,
                      size: 22,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  filled: true,
                  fillColor: AppColors.gray50,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: context.dynamicWidth(0.04),
                    vertical: context.dynamicHeight(0.018),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.gray200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.red500),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return _isArabic
                        ? 'الرجاء إدخال رقم الهاتف'
                        : 'Please enter phone number';
                  }
                  if (value.length < 7) {
                    return _isArabic
                        ? 'رقم الهاتف غير صحيح'
                        : 'Invalid phone number';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSendButton() {
    return Container(
      height: context.dynamicHeight(0.065),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withValues(alpha: 0.85),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSendOtp,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
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
                _isArabic ? 'إرسال رمز التحقق' : 'Send Verification Code',
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.042),
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

/// OTP Verification for Forgot Password
class ForgotPasswordOtpScreen extends StatefulWidget {
  final String phone;
  final VoidCallback onBack;
  final VoidCallback onVerified;

  const ForgotPasswordOtpScreen({
    super.key,
    required this.phone,
    required this.onBack,
    required this.onVerified,
  });

  @override
  State<ForgotPasswordOtpScreen> createState() => _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

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
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
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

  String get _otpCode {
    return _otpControllers.map((c) => c.text).join();
  }

  bool get _isArabic {
    return Localizations.localeOf(context).languageCode == 'ar';
  }

  void _verifyOtp() {
    if (_otpCode.length == 6) {
      setState(() {
        _isVerifying = true;
      });

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isArabic ? 'تم إرسال رمز جديد' : 'New code sent'),
          backgroundColor: AppColors.green600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
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
                    horizontal: context.dynamicWidth(0.06),
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        SizedBox(height: context.dynamicHeight(0.02)),
                        _buildHeader(),
                        SizedBox(height: context.dynamicHeight(0.04)),
                        _buildIcon(),
                        SizedBox(height: context.dynamicHeight(0.03)),
                        _buildTitle(),
                        SizedBox(height: context.dynamicHeight(0.04)),
                        _buildOtpCard(),
                        SizedBox(height: context.dynamicHeight(0.04)),
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
          top: -context.dynamicWidth(0.3),
          right: -context.dynamicWidth(0.2),
          child: Container(
            width: context.dynamicWidth(0.7),
            height: context.dynamicWidth(0.7),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1.5,
              ),
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
        SizedBox(width: context.dynamicWidth(0.04)),
        Expanded(
          child: Text(
            _isArabic ? 'التحقق من الرمز' : 'Verify Code',
            style: TextStyle(
              fontSize: context.dynamicWidth(0.055),
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
      width: context.dynamicWidth(0.28),
      height: context.dynamicWidth(0.28),
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
        Icons.mark_email_read_outlined,
        size: context.dynamicWidth(0.14),
        color: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          _isArabic ? 'أدخل رمز التحقق' : 'Enter Verification Code',
          style: TextStyle(
            fontSize: context.dynamicWidth(0.055),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.015)),
        Text(
          _isArabic
              ? 'تم إرسال رمز التحقق إلى'
              : 'We sent a verification code to',
          style: TextStyle(
            fontSize: context.dynamicWidth(0.038),
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.008)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.phone,
            style: TextStyle(
              fontSize: context.dynamicWidth(0.04),
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
      padding: EdgeInsets.all(context.dynamicWidth(0.06)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) => _buildOtpField(index)),
          ),
          SizedBox(height: context.dynamicHeight(0.03)),
          _buildVerifyButton(),
          SizedBox(height: context.dynamicHeight(0.025)),
          _buildResendSection(),
        ],
      ),
    );
  }

  Widget _buildOtpField(int index) {
    return SizedBox(
      width: context.dynamicWidth(0.12),
      child: TextFormField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(
          fontSize: context.dynamicWidth(0.06),
          fontWeight: FontWeight.bold,
          color: AppColors.gray900,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.gray50,
          contentPadding: EdgeInsets.symmetric(
            vertical: context.dynamicHeight(0.02),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.gray200, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
          ),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          if (_otpCode.length == 6) {
            _verifyOtp();
          }
        },
      ),
    );
  }

  Widget _buildVerifyButton() {
    final bool canVerify = _otpCode.length == 6 && !_isVerifying;

    return Container(
      width: double.infinity,
      height: context.dynamicHeight(0.065),
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
                _isArabic ? 'تحقق' : 'Verify',
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.043),
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _buildResendSection() {
    return Column(
      children: [
        Text(
          _isArabic ? 'لم تستلم الرمز؟' : "Didn't receive the code?",
          style: TextStyle(
            fontSize: context.dynamicWidth(0.035),
            color: AppColors.gray500,
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.01)),
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
                _isArabic ? 'إعادة إرسال الرمز' : 'Resend Code',
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.037),
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
              Icon(Icons.timer_outlined, size: 18, color: AppColors.gray400),
              SizedBox(width: 6),
              Text(
                _isArabic
                    ? 'إعادة الإرسال بعد $_resendSeconds ثانية'
                    : 'Resend in $_resendSeconds seconds',
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.035),
                  color: AppColors.gray400,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// Reset Password Screen - Set new password
class ResetPasswordScreen extends StatefulWidget {
  final String phone;
  final VoidCallback onBack;
  final VoidCallback onSuccess;

  const ResetPasswordScreen({
    super.key,
    required this.phone,
    required this.onBack,
    required this.onSuccess,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _isArabic {
    return Localizations.localeOf(context).languageCode == 'ar';
  }

  void _handleResetPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          // Show success dialog
          _showSuccessDialog();
        }
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 16),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.green100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: 50,
                color: AppColors.green600,
              ),
            ),
            SizedBox(height: 24),
            Text(
              _isArabic ? 'تم بنجاح!' : 'Success!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            SizedBox(height: 12),
            Text(
              _isArabic
                  ? 'تم تغيير كلمة المرور بنجاح.\nيمكنك الآن تسجيل الدخول.'
                  : 'Your password has been changed successfully.\nYou can now login.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.gray600,
                height: 1.4,
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onSuccess();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isArabic ? 'تسجيل الدخول' : 'Login',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.dynamicWidth(0.06),
                    ),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          SizedBox(height: context.dynamicHeight(0.02)),
                          _buildHeader(),
                          SizedBox(height: context.dynamicHeight(0.06)),
                          _buildIcon(),
                          SizedBox(height: context.dynamicHeight(0.03)),
                          _buildTitle(),
                          SizedBox(height: context.dynamicHeight(0.04)),
                          _buildFormCard(),
                          SizedBox(height: context.dynamicHeight(0.04)),
                        ],
                      ),
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
          top: -context.dynamicWidth(0.3),
          left: -context.dynamicWidth(0.2),
          child: Container(
            width: context.dynamicWidth(0.7),
            height: context.dynamicWidth(0.7),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1.5,
              ),
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
        SizedBox(width: context.dynamicWidth(0.04)),
        Expanded(
          child: Text(
            _isArabic ? 'كلمة مرور جديدة' : 'New Password',
            style: TextStyle(
              fontSize: context.dynamicWidth(0.055),
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
      width: context.dynamicWidth(0.28),
      height: context.dynamicWidth(0.28),
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
        Icons.lock_outline_rounded,
        size: context.dynamicWidth(0.14),
        color: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          _isArabic ? 'إنشاء كلمة مرور جديدة' : 'Create New Password',
          style: TextStyle(
            fontSize: context.dynamicWidth(0.055),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.015)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.05)),
          child: Text(
            _isArabic
                ? 'أدخل كلمة مرور جديدة قوية لحسابك'
                : 'Enter a strong new password for your account',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.dynamicWidth(0.038),
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.06)),
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // New Password Field
            _buildPasswordField(
              controller: _passwordController,
              label: _isArabic ? 'كلمة المرور الجديدة' : 'New Password',
              hint: _isArabic ? 'أدخل كلمة المرور الجديدة' : 'Enter new password',
              obscure: _obscurePassword,
              onToggle: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return _isArabic
                      ? 'الرجاء إدخال كلمة المرور'
                      : 'Please enter password';
                }
                if (value.length < 6) {
                  return _isArabic
                      ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'
                      : 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            SizedBox(height: context.dynamicHeight(0.02)),

            // Confirm Password Field
            _buildPasswordField(
              controller: _confirmPasswordController,
              label: _isArabic ? 'تأكيد كلمة المرور' : 'Confirm Password',
              hint: _isArabic ? 'أكد كلمة المرور' : 'Confirm password',
              obscure: _obscureConfirmPassword,
              onToggle: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return _isArabic
                      ? 'الرجاء تأكيد كلمة المرور'
                      : 'Please confirm password';
                }
                if (value != _passwordController.text) {
                  return _isArabic
                      ? 'كلمات المرور غير متطابقة'
                      : 'Passwords do not match';
                }
                return null;
              },
            ),
            SizedBox(height: context.dynamicHeight(0.03)),

            // Reset Button
            _buildResetButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: context.dynamicWidth(0.035),
            fontWeight: FontWeight.w600,
            color: AppColors.gray700,
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.008)),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          style: TextStyle(
            fontSize: context.dynamicWidth(0.04),
            color: AppColors.gray900,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.gray400,
              fontSize: context.dynamicWidth(0.035),
            ),
            prefixIcon: Container(
              margin: const EdgeInsetsDirectional.only(start: 14, end: 10),
              child: Icon(
                Icons.lock_outline_rounded,
                color: AppColors.primaryColor,
                size: 22,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
            suffixIcon: GestureDetector(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 14),
                child: Icon(
                  obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.gray400,
                  size: 22,
                ),
              ),
            ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
            filled: true,
            fillColor: AppColors.gray50,
            contentPadding: EdgeInsets.symmetric(
              horizontal: context.dynamicWidth(0.04),
              vertical: context.dynamicHeight(0.018),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.gray200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.red500),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResetButton() {
    return Container(
      height: context.dynamicHeight(0.065),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withValues(alpha: 0.85),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleResetPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
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
                _isArabic ? 'تغيير كلمة المرور' : 'Reset Password',
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.042),
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
