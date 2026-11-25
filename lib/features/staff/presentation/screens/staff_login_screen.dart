import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/core.dart';
import '../cubit/staff_session_cubit.dart';

/// Sign-in of the Maktoob team (an email and a password, as on the web).
class StaffLoginScreen extends StatefulWidget {
  const StaffLoginScreen({super.key, this.onExit});

  /// Back to the client's sign-in, when this screen is the app's entry.
  final VoidCallback? onExit;

  @override
  State<StaffLoginScreen> createState() => _StaffLoginScreenState();
}

class _StaffLoginScreenState extends State<StaffLoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidden = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _enter() {
    if (_email.text.trim().isEmpty || _password.text.isEmpty) return;
    context.read<StaffSessionCubit>().enter(_email.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(context.tr('staff_title')),
        leading: widget.onExit == null
            ? null
            : IconButton(key: const Key('staff_exit'), onPressed: widget.onExit, icon: const BackButtonIcon()),
      ),
      body: BlocBuilder<StaffSessionCubit, StaffSessionState>(
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        context.tr('staff_sign_in_title'),
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: context.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.tr('staff_sign_in_hint'),
                        style: TextStyle(fontSize: 14, height: 1.6, color: context.textSecondary),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        key: const Key('staff_email'),
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        textDirection: TextDirection.ltr,
                        autofillHints: const [AutofillHints.username],
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(labelText: context.tr('staff_email')),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        key: const Key('staff_password'),
                        controller: _password,
                        obscureText: _hidden,
                        textDirection: TextDirection.ltr,
                        autofillHints: const [AutofillHints.password],
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _enter(),
                        decoration: InputDecoration(
                          labelText: context.tr('staff_password'),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _hidden = !_hidden),
                            icon: Icon(_hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          ),
                        ),
                      ),
                      if (state.error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          state.error!.isEmpty ? context.tr('staff_sign_in_failed') : context.tr(state.error!),
                          key: const Key('staff_error'),
                          style: const TextStyle(fontSize: 13, color: AppColors.red500),
                        ),
                      ],
                      const SizedBox(height: 20),
                      PrimaryButton(
                        key: const Key('staff_enter'),
                        text: context.tr('staff_sign_in'),
                        isLoading: state.busy,
                        onPressed: state.busy ? null : _enter,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
