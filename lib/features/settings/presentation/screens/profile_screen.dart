import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/core.dart';
import '../../../../core/widgets/loading/mk_spinner.dart';
import '../../../../core/widgets/page/page_kit.dart';
import '../../../authentication/domain/entities/user_entity.dart';
import '../../../authentication/presentation/cubit/auth_cubit.dart';
import '../../../identity/presentation/screens/identity_verification_screen.dart';
import '../../../identity/presentation/widgets/identity_status_card.dart';
import '../../../institution/presentation/screens/institution_screen.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/account_summary_card.dart';
import '../widgets/profile_dialogs.dart';

/// The profile: who the client is, the kind of account, the identity, and
/// what they can do with the account.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
  }

  void _onState(BuildContext context, ProfileState state) {
    if (state is ProfileUpdated) {
      AppSnackBar.showSuccess(context, message: state.message);
      context.read<ProfileCubit>().resetToLoaded();
    } else if (state is ProfileError && state.user != null) {
      AppSnackBar.showError(context, message: state.message);
      context.read<ProfileCubit>().resetToLoaded();
    }
  }

  /// Opens a page that may change the account, then reads it again.
  Future<void> _openThenRefresh(Route<void> route) async {
    await Navigator.of(context).push(route);
    if (!mounted) return;
    context.read<ProfileCubit>().loadProfile();
    context.read<AuthCubit>().refreshProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(context.tr('profile_title')),
        leading: widget.onBack == null ? null : BackButton(onPressed: widget.onBack),
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: _onState,
        builder: (context, state) {
          final user = switch (state) {
            ProfileLoaded(:final user) => user,
            ProfileUpdating(:final user) => user,
            ProfileUpdated(:final user) => user,
            ProfileAvatarChanged(:final user) => user,
            ProfileError(:final user) => user,
            _ => null,
          };
          if (user == null) {
            return state is ProfileError
                ? _Problem(message: state.message, onRetry: context.read<ProfileCubit>().loadProfile)
                : const Center(child: MkSpinner());
          }
          return Stack(
            children: [
              _content(context, user),
              if (state is ProfileUpdating)
                Positioned.fill(
                  child: ColoredBox(
                    color: AppColors.black.withValues(alpha: 0.2),
                    child: const Center(child: MkSpinner()),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _content(BuildContext context, UserEntity user) {
    final identity = user.identity;
    return PageBody(
      side: [
        if (identity != null)
          IdentityStatusCard(
            identity: identity,
            onTap: () => _openThenRefresh(IdentityVerificationScreen.route()),
          ),
        PageCard.rows(
          title: context.tr('profile_account_actions'),
          rows: [
            PageRow(
              key: const Key('profile_edit'),
              icon: Icons.edit_outlined,
              title: context.tr('profile_edit'),
              onTap: () => ProfileDialogs.showEditProfile(context, user: user),
            ),
            PageRow(
              key: const Key('profile_change_password'),
              icon: Icons.lock_outline,
              title: context.tr('profile_change_password'),
              onTap: () => ProfileDialogs.showChangePassword(context, phone: user.phone ?? ''),
            ),
            PageRow(
              key: const Key('profile_logout'),
              icon: Icons.logout,
              title: context.tr('profile_logout'),
              onTap: () => ProfileDialogs.showLogout(context),
            ),
            PageRow(
              key: const Key('profile_delete'),
              icon: Icons.delete_outline,
              title: context.tr('profile_delete'),
              destructive: true,
              onTap: () => ProfileDialogs.showDeleteAccount(context),
            ),
          ],
        ),
      ],
      children: [
        AccountSummaryCard(user: user),
        PageCard.rows(
          title: context.tr('profile_personal_info'),
          rows: [
            PageRow(icon: Icons.person_outline, title: context.tr('profile_name'), subtitle: user.name),
            if (user.email.isNotEmpty)
              PageRow(
                icon: Icons.email_outlined,
                title: context.tr('profile_email'),
                subtitle: user.email,
                subtitleLtr: true,
              ),
            if ((user.phone ?? '').isNotEmpty)
              PageRow(
                icon: Icons.phone_outlined,
                title: context.tr('profile_phone'),
                subtitle: user.phone,
                subtitleLtr: true,
              ),
            if ((user.companyName ?? '').isNotEmpty)
              PageRow(
                icon: Icons.business_outlined,
                title: context.tr('profile_organization'),
                subtitle: user.companyName,
              ),
          ],
        ),
        PageCard.rows(
          title: context.tr('profile_account_type'),
          rows: [
            PageRow(
              key: const Key('profile_type_individual'),
              icon: Icons.person,
              title: context.tr('auth_individual'),
              subtitle: context.tr('profile_individual_desc'),
              selected: !user.isInstitution,
              // Going back to a personal account is done with the team.
              onTap: user.isInstitution
                  ? () => AppSnackBar.showInfo(context, message: context.tr('profile_type_downgrade_support'))
                  : null,
            ),
            PageRow(
              key: const Key('profile_type_institution'),
              icon: Icons.business,
              title: context.tr('auth_institution'),
              subtitle: context.tr('profile_institution_desc'),
              selected: user.isInstitution,
              // The institution's own page: its file, team and credits. For
              // a person this starts a request the team reviews.
              onTap: () => _openThenRefresh(InstitutionScreen.route()),
            ),
          ],
        ),
      ],
    );
  }
}

class _Problem extends StatelessWidget {
  const _Problem({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, height: 1.6, color: context.textSecondary),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: Text(context.tr('common_retry'))),
          ],
        ),
      ),
    );
  }
}
