import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/core.dart';
import '../../../../core/widgets/page/page_kit.dart';
import '../../../authentication/presentation/cubit/auth_cubit.dart';
import '../../../authentication/presentation/cubit/auth_state.dart';
import '../../../authentication/presentation/screens/forgot_password_otp_screen.dart';
import '../../../authentication/presentation/screens/reset_password_screen.dart';

/// Changing the password: the current one, the new one, the new one again.
/// "Forgot it?" goes through a code sent to the mobile number.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key, required this.phone, this.forced = false});

  final String phone;

  /// The account was opened by the team with a temporary password: no way
  /// back, and on success the app reads the profile again and opens.
  final bool forced;

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _again = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _again.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthCubit>().changePassword(currentPassword: _current.text, newPassword: _next.text);
  }

  String? _nextError(String? value) {
    if (value == null || value.isEmpty) return context.tr('auth_password_required');
    if (value.length < 6) return context.tr('auth_password_min_length');
    // The new password must differ from the current one.
    return value == _current.text ? context.tr('auth_passwords_mismatch') : null;
  }

  String? _againError(String? value) {
    if (value == null || value.isEmpty) return context.tr('auth_confirm_password_required2');
    return value == _next.text ? null : context.tr('auth_passwords_mismatch');
  }

  void _forgot() {
    final navigator = Navigator.of(context);
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => ForgotPasswordOtpScreen(
          phone: widget.phone,
          onBack: navigator.pop,
          onVerified: (code) => navigator.pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => ResetPasswordScreen(
                phone: widget.phone,
                code: code,
                onBack: navigator.pop,
                onSuccess: () => navigator.popUntil((route) => route.isFirst),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onState(BuildContext context, AuthState state) {
    if (state is AuthError) return AppSnackBar.showError(context, message: state.message);
    if (state is! AuthPasswordChanged) return;
    // Forced: the flag is cleared on the profile and the app opens by itself.
    if (widget.forced) {
      context.read<AuthCubit>().refreshProfile();
      return;
    }
    AppDialog.showSuccess(
      context,
      title: context.tr('auth_success'),
      message: context.tr('auth_password_changed_profile'),
      buttonText: context.tr('common_ok'),
      onPressed: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final forced = widget.forced;
    return BlocConsumer<AuthCubit, AuthState>(
      listener: _onState,
      builder: (context, state) {
        final busy = state is AuthLoading;
        return Scaffold(
          backgroundColor: context.scaffoldBg,
          appBar: AppBar(
            automaticallyImplyLeading: !forced,
            title: Text(context.tr(forced ? 'auth_choose_own_password_title' : 'profile_change_password')),
          ),
          body: Form(
            key: _formKey,
            child: PageBody(
              children: [
                Text(
                  context.tr(forced ? 'auth_choose_own_password_subtitle' : 'auth_change_password_subtitle'),
                  style: TextStyle(fontSize: 14, height: 1.6, color: context.textSecondary),
                ),
                PageCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        key: const Key('password_current'),
                        controller: _current,
                        labelText: context.tr('auth_current_password'),
                        hintText: context.tr('auth_current_password_hint'),
                        isPassword: true,
                        textInputAction: TextInputAction.next,
                        validator: (value) =>
                            (value == null || value.isEmpty) ? context.tr('auth_current_password_required') : null,
                      ),
                      if (!forced)
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: TextButton(
                            key: const Key('password_forgot'),
                            onPressed: _forgot,
                            child: Text(context.tr('auth_forgot_password_link')),
                          ),
                        ),
                      const SizedBox(height: 12),
                      AppTextField(
                        key: const Key('password_new'),
                        controller: _next,
                        labelText: context.tr('auth_new_password'),
                        hintText: context.tr('auth_new_password_hint'),
                        isPassword: true,
                        textInputAction: TextInputAction.next,
                        validator: _nextError,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        key: const Key('password_again'),
                        controller: _again,
                        labelText: context.tr('auth_confirm_password'),
                        hintText: context.tr('auth_confirm_password_hint2'),
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        validator: _againError,
                      ),
                    ],
                  ),
                ),
                PrimaryButton(
                  key: const Key('password_submit'),
                  text: context.tr('auth_change_password_submit'),
                  isLoading: busy,
                  onPressed: busy ? null : _submit,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
