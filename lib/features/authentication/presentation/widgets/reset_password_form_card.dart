import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';

/// Reset password form card with password fields.
class ResetPasswordFormCard extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isLoading;
  final VoidCallback onSubmit;

  const ResetPasswordFormCard({
    super.key,
    required this.formKey,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  State<ResetPasswordFormCard> createState() => _ResetPasswordFormCardState();
}

class _ResetPasswordFormCardState extends State<ResetPasswordFormCard> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PasswordField(
              controller: widget.passwordController,
              label: t.translate('auth_new_password'),
              hint: t.translate('auth_new_password_hint'),
              obscure: _obscurePassword,
              onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
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
            SizedBox(height: context.dynamicHeight(0.02)),
            _PasswordField(
              controller: widget.confirmPasswordController,
              label: t.translate('auth_confirm_password'),
              hint: t.translate('auth_confirm_password_hint2'),
              obscure: _obscureConfirmPassword,
              onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return t.translate('auth_confirm_password_required2');
                }
                if (value != widget.passwordController.text) {
                  return t.translate('auth_passwords_mismatch');
                }
                return null;
              },
            ),
            SizedBox(height: context.dynamicHeight(0.03)),
            PrimaryButton(
              text: t.translate('auth_reset_password'),
              onPressed: widget.isLoading ? null : widget.onSubmit,
              isLoading: widget.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?) validator;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.obscure,
    required this.onToggle,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(color: context.textTertiary),
        ),
        SizedBox(height: context.dynamicHeight(0.007)),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          style: AppTextStyles.bodyLarge.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: context.iconDefault),
            prefixIcon: Container(
              margin: const EdgeInsetsDirectional.only(start: 14, end: 10),
              child: Icon(Icons.lock_outline_rounded, color: AppColors.primaryColor, size: 22),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            suffixIcon: GestureDetector(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 14),
                child: Icon(
                  obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: context.iconDefault,
                  size: 22,
                ),
              ),
            ),
            suffixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            filled: true,
            fillColor: context.themeSurface,
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
              borderSide: BorderSide(color: context.borderColor),
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
}
