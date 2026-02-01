import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../screens/forgot_password_screen.dart';
import 'phone_input_card.dart';

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
  final _loginFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _isPhoneMode = false;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    _loginFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _onLoginFieldChanged(String value) {
    if (value.isEmpty) {
      if (_isPhoneMode) setState(() => _isPhoneMode = false);
      return;
    }
    // Detect phone input: starts with +, digit, or looks numeric
    final looksLikePhone = RegExp(r'^[\+0-9]').hasMatch(value);
    if (looksLikePhone != _isPhoneMode) {
      setState(() => _isPhoneMode = looksLikePhone);
    }
  }

  /// Normalizes phone input to local format expected by the API.
  ///
  /// The API expects the local number starting with 0:
  /// - 0567074004       → 0567074004 (unchanged)
  /// - +970567074004    → 0567074004
  /// - +972567074004    → 0567074004
  /// - 970567074004     → 0567074004
  /// - 972567074004     → 0567074004
  /// - 00970567074004   → 0567074004
  /// - 567074004        → 0567074004
  String _normalizePhone(String raw) {
    // Remove spaces, dashes, parentheses
    String phone = raw.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // 00xxx international prefix → +xxx
    if (phone.startsWith('00')) {
      phone = '+${phone.substring(2)}';
    }

    // Strip + prefix if present
    if (phone.startsWith('+')) {
      phone = phone.substring(1);
    }

    // Strip known country code digits from the beginning
    // Sort by code length descending so +970 matches before +97
    final sortedCodes = List<CountryCode>.from(CountryCode.all)
      ..sort((a, b) => b.code.length.compareTo(a.code.length));

    for (final cc in sortedCodes) {
      final codeDigits = cc.code.substring(1); // e.g. "970", "972", "20"
      if (phone.startsWith(codeDigits)) {
        phone = phone.substring(codeDigits.length);
        break;
      }
    }

    // Ensure the local number starts with 0
    if (!phone.startsWith('0')) {
      phone = '0$phone';
    }

    return phone;
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      String loginValue = _loginController.text.trim();

      // Normalize phone numbers before sending to API
      if (_isPhoneMode) {
        loginValue = _normalizePhone(loginValue);
      }

      context.read<AuthCubit>().login(
            login: loginValue,
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
                  focusNode: _loginFocusNode,
                  labelText: t.translate('auth_phone_or_email'),
                  hintText: t.translate('auth_phone_or_email_hint'),
                  prefixIcon: _isPhoneMode
                      ? Icons.phone_outlined
                      : Icons.person_outline_rounded,
                  keyboardType: _isPhoneMode
                      ? TextInputType.phone
                      : TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                  maxLength: _isPhoneMode ? 20 : null,
                  inputFormatters: _isPhoneMode
                      ? [FilteringTextInputFormatter.allow(RegExp(r'[\d\+]'))]
                      : null,
                  onChanged: _onLoginFieldChanged,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return t.translate('auth_phone_or_email_required');
                    }
                    if (_isPhoneMode) {
                      // Count only digits for length validation (exclude +)
                      final digitCount = value.replaceAll(RegExp(r'[^\d]'), '').length;
                      if (digitCount < 7 || digitCount > 15) {
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
                  focusNode: _passwordFocusNode,
                  labelText: t.translate('auth_password'),
                  hintText: t.translate('auth_password_hint'),
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleLogin(),
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
