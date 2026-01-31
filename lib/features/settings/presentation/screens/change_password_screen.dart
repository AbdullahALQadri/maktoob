import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../authentication/presentation/screens/forgot_password_otp_screen.dart';
import '../../../authentication/presentation/screens/reset_password_screen.dart';
import '../../../authentication/presentation/widgets/widgets.dart';
import '../widgets/change_password_form_card.dart';

/// Change password screen — shows current/new/confirm password fields.
///
/// If the user taps "Forgot Password?" it navigates to the OTP verification
/// screen and then to the reset password screen.
class ChangePasswordScreen extends StatefulWidget {
  final String phone;

  const ChangePasswordScreen({super.key, required this.phone});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _currentPasswordFocusNode = FocusNode();
  final _newPasswordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isLoading = false;

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
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _currentPasswordFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      // TODO: Replace with real API call to change password
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isLoading = false);
          _showSuccessDialog();
        }
      });
    }
  }

  void _showSuccessDialog() {
    final t = AppLocalizations.of(context)!;
    AppDialog.showSuccess(
      context,
      title: t.translate('auth_success'),
      message: t.translate('auth_password_changed_profile'),
      buttonText: t.translate('common_ok'),
      onPressed: () => Navigator.pop(context),
    );
  }

  void _handleForgotPassword() {
    final navigator = Navigator.of(context);
    navigator.push(
      MaterialPageRoute(
        builder: (_) => ForgotPasswordOtpScreen(
          phone: widget.phone,
          onBack: () => navigator.pop(),
          onVerified: () {
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
          },
        ),
      ),
    );
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
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        SizedBox(height: context.dynamicHeight(0.02)),
                        AuthBackHeader(
                          title: t.translate('profile_change_password'),
                          onBack: () => Navigator.pop(context),
                        ),
                        SizedBox(height: context.dynamicHeight(0.06)),
                        const AuthScreenIcon(
                            icon: Icons.lock_outline_rounded),
                        SizedBox(height: context.dynamicHeight(0.03)),
                        AuthTitleSection(
                          title: t.translate('profile_change_password'),
                          subtitle:
                              t.translate('auth_change_password_subtitle'),
                        ),
                        SizedBox(height: context.dynamicHeight(0.039)),
                        ChangePasswordFormCard(
                          formKey: _formKey,
                          currentPasswordController:
                              _currentPasswordController,
                          newPasswordController: _newPasswordController,
                          confirmPasswordController:
                              _confirmPasswordController,
                          currentPasswordFocusNode: _currentPasswordFocusNode,
                          newPasswordFocusNode: _newPasswordFocusNode,
                          confirmPasswordFocusNode:
                              _confirmPasswordFocusNode,
                          isLoading: _isLoading,
                          onSubmit: _handleSubmit,
                          onForgotPassword: _handleForgotPassword,
                        ),
                        SizedBox(height: context.dynamicHeight(0.039)),
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
}
