import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../widgets/widgets.dart';

/// Reset password screen - set new password.
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

  void _handleResetPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

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
      message: t.translate('auth_password_changed_msg'),
      buttonText: t.translate('auth_login'),
      onPressed: widget.onSuccess,
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
                padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.061)),
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
                          title: t.translate('auth_new_password_title'),
                          onBack: widget.onBack,
                        ),
                        SizedBox(height: context.dynamicHeight(0.06)),
                        const AuthScreenIcon(icon: Icons.lock_outline_rounded),
                        SizedBox(height: context.dynamicHeight(0.03)),
                        AuthTitleSection(
                          title: t.translate('auth_create_new_password'),
                          subtitle: t.translate('auth_new_password_subtitle'),
                        ),
                        SizedBox(height: context.dynamicHeight(0.039)),
                        ResetPasswordFormCard(
                          formKey: _formKey,
                          passwordController: _passwordController,
                          confirmPasswordController: _confirmPasswordController,
                          isLoading: _isLoading,
                          onSubmit: _handleResetPassword,
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
