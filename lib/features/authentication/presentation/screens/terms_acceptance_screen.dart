import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../institution/presentation/widgets/institution_widgets.dart' show OutlinedCard;
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

/// Shown instead of the app when the team published a Terms / Privacy
/// version this client has not accepted (`legal.acceptance_required`).
/// Accepting records it (`POST /auth/legal/accept`) and reloads the profile;
/// declining signs out.
class TermsAcceptanceScreen extends StatefulWidget {
  const TermsAcceptanceScreen({super.key});

  @override
  State<TermsAcceptanceScreen> createState() => _TermsAcceptanceScreenState();
}

class _TermsAcceptanceScreenState extends State<TermsAcceptanceScreen> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode == 'en' ? 'en' : 'ar';

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final busy = state is AuthLoading;
        return Scaffold(
          backgroundColor: AppColors.surfaceBg,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
              children: [
                const SizedBox(height: AppSpacing.xl),
                const Icon(Icons.verified_user_outlined, size: AppSpacing.xxxxxl, color: AppColors.primaryColor),
                const SizedBox(height: AppSpacing.md),
                Text(
                  t.translate('legal_update_title'),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineSmall.copyWith(color: context.textPrimary),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  t.translate('legal_update_body'),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(color: context.textSecondary, height: 1.5),
                ),
                const SizedBox(height: AppSpacing.lg),
                OutlinedCard(
                  child: Column(
                    children: [
                      _DocumentTile(
                        key: const Key('legal_open_terms'),
                        icon: Icons.description_outlined,
                        title: t.translate('legal_terms'),
                        onTap: () => LegalLinks.open(LegalLinks.termsOfService, lang: lang),
                      ),
                      const Divider(height: AppSpacing.md),
                      _DocumentTile(
                        key: const Key('legal_open_privacy'),
                        icon: Icons.lock_outline_rounded,
                        title: t.translate('legal_privacy'),
                        onTap: () => LegalLinks.open(LegalLinks.privacyPolicy, lang: lang),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                CheckboxListTile(
                  key: const Key('legal_agree_checkbox'),
                  value: _agreed,
                  contentPadding: EdgeInsetsDirectional.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: busy ? null : (v) => setState(() => _agreed = v ?? false),
                  title: Text(
                    t.translate('legal_agree_checkbox'),
                    style: AppTextStyles.bodyMedium.copyWith(color: context.textPrimary),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  key: const Key('legal_accept_button'),
                  text: t.translate('legal_agree_continue'),
                  isLoading: busy,
                  onPressed: _agreed && !busy ? () => context.read<AuthCubit>().acceptLegal() : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  key: const Key('legal_decline_logout'),
                  onPressed: busy ? null : () => context.read<AuthCubit>().logout(),
                  child: Text(t.translate('legal_decline_logout')),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DocumentTile({super.key, required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsetsDirectional.zero,
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(title, style: AppTextStyles.titleSmall.copyWith(color: context.textPrimary)),
      trailing: Icon(Icons.open_in_new_rounded, size: AppSpacing.iconSm, color: context.textSecondary),
      onTap: onTap,
    );
  }
}
