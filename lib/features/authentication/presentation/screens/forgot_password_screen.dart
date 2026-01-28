import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../widgets/widgets.dart';
import 'forgot_password_otp_screen.dart';
import 'reset_password_screen.dart';

/// Forgot password screen - enter phone number.
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
  String _selectedCountryCode = '+970';
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

  void _handleSendOtp() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isLoading = false);

          String phoneNumber = _phoneController.text.trim();
          if (phoneNumber.startsWith('0')) {
            phoneNumber = phoneNumber.substring(1);
          }
          final fullPhone = '$_selectedCountryCode$phoneNumber';

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ForgotPasswordOtpScreen(
                phone: fullPhone,
                onBack: () => Navigator.pop(context),
                onVerified: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResetPasswordScreen(
                        phone: fullPhone,
                        onBack: () => Navigator.pop(context),
                        onSuccess: () {
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
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      body: AuthGradientBackground(
        child: Stack(
          children: [
            const AuthDecorativePattern(),
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
                    padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.061)),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            SizedBox(height: context.dynamicHeight(0.02)),
                            AuthBackHeader(
                              title: t.translate('auth_forgot_password_title'),
                              onBack: widget.onBack ?? () => Navigator.pop(context),
                            ),
                            SizedBox(height: context.dynamicHeight(0.06)),
                            const AuthScreenIcon(icon: Icons.lock_reset_rounded),
                            SizedBox(height: context.dynamicHeight(0.03)),
                            AuthTitleSection(
                              title: t.translate('auth_reset_password_title'),
                              subtitle: t.translate('auth_reset_password_subtitle'),
                            ),
                            SizedBox(height: context.dynamicHeight(0.039)),
                            PhoneInputCard(
                              formKey: _formKey,
                              phoneController: _phoneController,
                              selectedCountryCode: _selectedCountryCode,
                              onCountryCodeChanged: (code) {
                                setState(() => _selectedCountryCode = code);
                              },
                              isLoading: _isLoading,
                              onSubmit: _handleSendOtp,
                              submitButtonText: t.translate('auth_send_code'),
                            ),
                            SizedBox(height: context.dynamicHeight(0.039)),
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
}
