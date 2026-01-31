import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../authentication/presentation/screens/reset_password_screen.dart';
import '../../../authentication/presentation/widgets/widgets.dart';

/// Change password screen — sends OTP to the logged-in user's phone,
/// verifies, then navigates to the new-password form.
class ChangePasswordScreen extends StatefulWidget {
  final String phone;

  const ChangePasswordScreen({super.key, required this.phone});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with SingleTickerProviderStateMixin {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  Timer? _resendTimer;
  int _resendSeconds = 60;
  bool _canResend = false;
  bool _isVerifying = false;
  bool _isSendingOtp = true;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _sendInitialOtp();
  }

  void _initAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  void _sendInitialOtp() {
    // Simulate sending OTP to the user's phone
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isSendingOtp = false);
        _startResendTimer();
      }
    });
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
      setState(() => _isVerifying = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isVerifying = false);
          _navigateToNewPassword();
        }
      });
    }
  }

  void _navigateToNewPassword() {
    final navigator = Navigator.of(context);
    navigator.pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResetPasswordScreen(
          phone: widget.phone,
          onBack: () => navigator.pop(),
          onSuccess: () {
            navigator.popUntil((route) => route.isFirst);
          },
        ),
      ),
    );
  }

  void _resendOtp() {
    if (_canResend) {
      _startResendTimer();
      _pinController.clear();
      AppSnackBar.showSuccess(
        context,
        message: AppLocalizations.of(context)!.translate('auth_new_code_sent'),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _resendTimer?.cancel();
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      body: AuthGradientBackground(
        child: Stack(
          children: [
            const AuthDecorativePattern(),
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                    horizontal: context.dynamicWidth(0.061)),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      SizedBox(height: context.dynamicHeight(0.02)),
                      AuthBackHeader(
                        title: t.translate('profile_change_password'),
                        onBack: () => Navigator.pop(context),
                      ),
                      SizedBox(height: context.dynamicHeight(0.039)),
                      const AuthScreenIcon(
                          icon: Icons.mark_email_read_outlined),
                      SizedBox(height: context.dynamicHeight(0.03)),
                      AuthTitleSection(
                        title: t.translate('auth_enter_code'),
                        subtitle: t.translate('auth_code_sent_to'),
                        extra: PhoneBadge(phone: widget.phone),
                      ),
                      SizedBox(height: context.dynamicHeight(0.039)),
                      if (_isSendingOtp)
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: context.dynamicHeight(0.05)),
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                        )
                      else
                        OtpCard(
                          pinController: _pinController,
                          focusNode: _focusNode,
                          isVerifying: _isVerifying,
                          canResend: _canResend,
                          resendSeconds: _resendSeconds,
                          onVerify: _verifyOtp,
                          onResend: _resendOtp,
                          onChanged: () => setState(() {}),
                        ),
                      SizedBox(height: context.dynamicHeight(0.039)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
