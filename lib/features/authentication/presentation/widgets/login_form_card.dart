import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../screens/forgot_password_screen.dart';

/// Login form card with glassmorphism effect.
class LoginFormCard extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginFormCard({super.key, this.onLoginSuccess});

  @override
  State<LoginFormCard> createState() => _LoginFormCardState();
}

class _LoginFormCardState extends State<LoginFormCard> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPhoneMode = false;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginFieldChanged(String value) {
    if (value.isEmpty) {
      if (_isPhoneMode) setState(() => _isPhoneMode = false);
      return;
    }
    final startsWithDigit = RegExp(r'^[0-9]').hasMatch(value);
    if (startsWithDigit != _isPhoneMode) {
      setState(() => _isPhoneMode = startsWithDigit);
    }
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
            login: _loginController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  controller: _loginController,
                  labelText: t.translate('auth_phone_or_email'),
                  hintText: t.translate('auth_phone_or_email_hint'),
                  prefixIcon: _isPhoneMode
                      ? Icons.phone_outlined
                      : Icons.person_outline_rounded,
                  keyboardType: _isPhoneMode
                      ? TextInputType.number
                      : TextInputType.emailAddress,
                  maxLength: _isPhoneMode ? 15 : null,
                  inputFormatters: _isPhoneMode
                      ? [FilteringTextInputFormatter.digitsOnly]
                      : null,
                  onChanged: _onLoginFieldChanged,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return t.translate('auth_phone_or_email_required');
                    }
                    if (_isPhoneMode) {
                      if (value.length < 7 || value.length > 15) {
                        return t.translate('auth_phone_invalid_length');
                      }
                    } else {
                      if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$').hasMatch(value)) {
                        return t.translate('auth_email_invalid');
                      }
                    }
                    return null;
                  },
                ),
                SizedBox(height: context.dynamicHeight(0.02)),
                AppTextField(
                  controller: _passwordController,
                  labelText: t.translate('auth_password'),
                  hintText: t.translate('auth_password_hint'),
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return t.translate('auth_password_required');
                    }
                    if (value.length < 6) {
                      return t.translate('auth_password_min_length');
                    }
                    return null;
                  },
                ),
                SizedBox(height: context.dynamicHeight(0.012)),
                _ForgotPasswordLink(onSuccess: widget.onLoginSuccess),
                SizedBox(height: context.dynamicHeight(0.025)),
                _LoginButton(onPressed: _handleLogin),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ForgotPasswordLink extends StatelessWidget {
  final VoidCallback? onSuccess;

  const _ForgotPasswordLink({this.onSuccess});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: AppTextButton(
        text: t.translate('auth_forgot_password'),
        size: ButtonSize.small,
        onPressed: () => _navigateToForgotPassword(context, t),
      ),
    );
  }

  void _navigateToForgotPassword(BuildContext context, AppLocalizations t) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ForgotPasswordScreen(
          onBack: () => Navigator.pop(context),
          onSuccess: () {
            AppSnackBar.showSuccess(
              context,
              message: t.translate('auth_password_changed'),
            );
          },
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _LoginButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return PrimaryButton(
          text: t.translate('auth_sign_in'),
          onPressed: onPressed,
          isLoading: isLoading,
        );
      },
    );
  }
}
