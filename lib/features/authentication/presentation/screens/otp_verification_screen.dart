import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../domain/entities/user_entity.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/widgets.dart';

/// OTP verification screen.
class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  final UserType userType;
  final VoidCallback onVerified;
  final VoidCallback onBack;
  /// If true, user will be authenticated after OTP verification
  final bool loginAfterVerify;

  const OtpVerificationScreen({
    super.key,
    required this.phone,
    required this.userType,
    required this.onVerified,
    required this.onBack,
    this.loginAfterVerify = false,
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

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _startResendTimer();
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
      context.read<AuthCubit>().verifyOtp(
            login: widget.phone,
            otp: _pinController.text,
            loginAfterVerify: widget.loginAfterVerify,
          );
    }
  }

  void _resendOtp() {
    if (_canResend) {
      context
          .read<AuthCubit>()
          .resendOtp(login: widget.phone, purpose: 'register');
      _startResendTimer();
      _pinController.clear();
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
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpVerified || state is AuthAuthenticated) {
          widget.onVerified();
        } else if (state is AuthOtpSent) {
          AppSnackBar.showSuccess(
            context,
            message: AppLocalizations.of(context)!
                .translate('auth_new_code_sent'),
          );
        } else if (state is AuthError) {
          AppSnackBar.showError(context, message: state.message);
        }
      },
      child: Scaffold(
        body: _OtpBackground(
          child: Stack(
            children: [
              const AuthDecorativePattern(),
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: context.dynamicWidth(0.061),
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        SizedBox(height: context.dynamicHeight(0.02)),
                        _OtpHeader(onBack: widget.onBack),
                        SizedBox(height: context.dynamicHeight(0.039)),
                        _OtpIcon(),
                        SizedBox(height: context.dynamicHeight(0.03)),
                        _OtpTitle(phone: widget.phone),
                        SizedBox(height: context.dynamicHeight(0.039)),
                        BlocBuilder<AuthCubit, AuthState>(
                          builder: (context, state) {
                            return OtpCard(
                              pinController: _pinController,
                              focusNode: _focusNode,
                              isVerifying: state is AuthLoading,
                              canResend: _canResend,
                              resendSeconds: _resendSeconds,
                              onVerify: _verifyOtp,
                              onResend: _resendOtp,
                              onChanged: () => setState(() {}),
                            );
                          },
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
      ),
    );
  }
}

class _OtpBackground extends StatelessWidget {
  final Widget child;

  const _OtpBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: child,
    );
  }
}

class _OtpHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _OtpHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            onBack();
            Navigator.of(context).pop();
          },
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
            child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
          ),
        ),
        SizedBox(width: context.dynamicWidth(0.04)),
        Expanded(
          child: Text(
            t.translate('auth_phone_verification'),
            style: AppTextStyles.headlineSmall.white,
          ),
        ),
      ],
    );
  }
}

class _OtpIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
        Icons.sms_outlined,
        size: context.dynamicWidth(0.141),
        color: AppColors.primaryColor,
      ),
    );
  }
}

class _OtpTitle extends StatelessWidget {
  final String phone;

  const _OtpTitle({required this.phone});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Column(
      children: [
        Text(t.translate('auth_enter_code'), style: AppTextStyles.headlineMedium.white),
        SizedBox(height: context.dynamicHeight(0.015)),
        Text(
          t.translate('auth_code_sent_to'),
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.007)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            phone,
            style: AppTextStyles.titleMedium.white,
          ),
        ),
      ],
    );
  }
}
