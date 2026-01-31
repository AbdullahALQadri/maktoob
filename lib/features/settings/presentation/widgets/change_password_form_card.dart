import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';

/// Change password form card with 3 password fields and forgot password link.
///
/// Fields: current password, new password, confirm new password.
/// Includes a "Forgot Password?" link that triggers [onForgotPassword].
class ChangePasswordFormCard extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final FocusNode currentPasswordFocusNode;
  final FocusNode newPasswordFocusNode;
  final FocusNode confirmPasswordFocusNode;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;

  const ChangePasswordFormCard({
    super.key,
    required this.formKey,
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.currentPasswordFocusNode,
    required this.newPasswordFocusNode,
    required this.confirmPasswordFocusNode,
    required this.isLoading,
    required this.onSubmit,
    required this.onForgotPassword,
  });

  @override
  State<ChangePasswordFormCard> createState() => _ChangePasswordFormCardState();
}

class _ChangePasswordFormCardState extends State<ChangePasswordFormCard> {
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

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
            // Current Password
            _PasswordField(
              controller: widget.currentPasswordController,
              focusNode: widget.currentPasswordFocusNode,
              label: t.translate('auth_current_password'),
              hint: t.translate('auth_current_password_hint'),
              obscure: _obscureCurrent,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) =>
                  widget.newPasswordFocusNode.requestFocus(),
              onToggle: () =>
                  setState(() => _obscureCurrent = !_obscureCurrent),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return t.translate('auth_current_password_required');
                }
                return null;
              },
            ),

            // Forgot password link
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: EdgeInsets.only(top: context.dynamicHeight(0.008)),
                child: AppTextButton(
                  text: t.translate('auth_forgot_password_link'),
                  size: ButtonSize.small,
                  onPressed: widget.onForgotPassword,
                ),
              ),
            ),

            SizedBox(height: context.dynamicHeight(0.012)),

            // New Password
            _PasswordField(
              controller: widget.newPasswordController,
              focusNode: widget.newPasswordFocusNode,
              label: t.translate('auth_new_password'),
              hint: t.translate('auth_new_password_hint'),
              obscure: _obscureNew,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) =>
                  widget.confirmPasswordFocusNode.requestFocus(),
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return t.translate('auth_password_required');
                }
                if (value.length < 6) {
                  return t.translate('auth_password_min_length');
                }
                if (value == widget.currentPasswordController.text) {
                  return t.translate('auth_passwords_mismatch');
                }
                return null;
              },
            ),

            SizedBox(height: context.dynamicHeight(0.02)),

            // Confirm New Password
            _PasswordField(
              controller: widget.confirmPasswordController,
              focusNode: widget.confirmPasswordFocusNode,
              label: t.translate('auth_confirm_password'),
              hint: t.translate('auth_confirm_password_hint2'),
              obscure: _obscureConfirm,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => widget.onSubmit(),
              onToggle: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return t.translate('auth_confirm_password_required2');
                }
                if (value != widget.newPasswordController.text) {
                  return t.translate('auth_passwords_mismatch');
                }
                return null;
              },
            ),

            SizedBox(height: context.dynamicHeight(0.03)),

            // Submit Button
            PrimaryButton(
              text: t.translate('auth_change_password_submit'),
              onPressed: widget.isLoading ? null : widget.onSubmit,
              isLoading: widget.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable password field with visibility toggle.
class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final String hint;
  final bool obscure;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final VoidCallback onToggle;
  final String? Function(String?) validator;

  const _PasswordField({
    required this.controller,
    this.focusNode,
    required this.label,
    required this.hint,
    required this.obscure,
    this.textInputAction,
    this.onFieldSubmitted,
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
          style: AppTextStyles.labelMedium
              .copyWith(color: context.textTertiary),
        ),
        SizedBox(height: context.dynamicHeight(0.007)),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscure,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          validator: validator,
          style: AppTextStyles.bodyLarge.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium
                .copyWith(color: context.iconDefault),
            prefixIcon: Container(
              margin:
                  const EdgeInsetsDirectional.only(start: 14, end: 10),
              child: Icon(Icons.lock_outline_rounded,
                  color: AppColors.primaryColor, size: 22),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 48, minHeight: 48),
            suffixIcon: GestureDetector(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 14),
                child: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: context.iconDefault,
                  size: 22,
                ),
              ),
            ),
            suffixIconConstraints:
                const BoxConstraints(minWidth: 48, minHeight: 48),
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
              borderSide:
                  BorderSide(color: AppColors.primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.red500),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: AppColors.red500, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
