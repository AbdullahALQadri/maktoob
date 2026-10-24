import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/core.dart';
import '../../../../core/widgets/inputs/otp_pin_field.dart';
import '../../../../core/widgets/inputs/resend_countdown.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

/// A sign-in on a number that was never confirmed: a code is sent at once
/// and the account opens as soon as it is entered.
class UnverifiedAccountOtpDialog extends StatefulWidget {
  const UnverifiedAccountOtpDialog({super.key, required this.phone, required this.onVerified, required this.onCancel});

  final String phone;
  final VoidCallback onVerified;
  final VoidCallback onCancel;

  @override
  State<UnverifiedAccountOtpDialog> createState() => _UnverifiedAccountOtpDialogState();
}

class _UnverifiedAccountOtpDialogState extends State<UnverifiedAccountOtpDialog> {
  final _pin = TextEditingController();

  void _verify() {
    if (_pin.text.length != 6) return;
    context.read<AuthCubit>().verifyOtp(login: widget.phone, otp: _pin.text, loginAfterVerify: true);
  }

  void _resend() {
    context.read<AuthCubit>().resendOtp(login: widget.phone, purpose: 'registration');
    _pin.clear();
  }

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          widget.onVerified();
        } else if (state is AuthOtpSent) {
          AppSnackBar.showSuccess(context, message: context.tr('auth_new_code_sent'));
        } else if (state is AuthError) {
          AppSnackBar.showError(context, message: state.message);
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        // Symmetric, so the non-directional type Dialog requires is safe in RTL.
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(color: AppColors.amber100, shape: BoxShape.circle),
                  child: const Icon(Icons.warning_amber_rounded, size: 32, color: AppColors.amber700),
                ),
                const SizedBox(height: 16),
                Text(
                  context.tr('auth_account_not_verified'),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleLarge.copyWith(color: context.textPrimary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('auth_verify_to_continue'),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: context.primaryWash, borderRadius: BorderRadius.circular(16)),
                  child: Text(
                    widget.phone,
                    textDirection: TextDirection.ltr,
                    style: AppTextStyles.labelLarge.copyWith(color: context.primaryText, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 20),
                OtpPinField(
                  controller: _pin,
                  autofocus: true,
                  onCompleted: (_) => _verify(),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    final loading = state is AuthLoading;
                    final ready = _pin.text.length == 6 && !loading;
                    return SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        text: context.tr('auth_verify'),
                        onPressed: ready ? _verify : null,
                        isLoading: loading,
                        isDisabled: !ready,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: widget.onCancel,
                    child: Text(context.tr('common_cancel'), style: TextStyle(color: context.textSecondary)),
                  ),
                ),
                ResendCountdown(onResend: _resend),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
