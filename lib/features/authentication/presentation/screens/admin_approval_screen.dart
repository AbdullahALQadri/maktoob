import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../../injection_container.dart' as di;
import '../../../institution/domain/entities/institution_entity.dart';
import '../../../institution/presentation/cubit/institution_cubit.dart';
import '../../../institution/presentation/screens/institution_profile_form_screen.dart';
import '../../../institution/presentation/screens/institution_screen.dart';
import '../../../institution/presentation/widgets/institution_verification_widgets.dart';
import '../../../institution/presentation/widgets/institution_widgets.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'package:maktoob/core/widgets/loading/mk_spinner.dart';

/// Shown instead of the app while an institution account is not approved.
///
/// Reads the status from the signed-in user (`GET /auth/profile`); pull to
/// refresh (or the button) re-checks it. Once approved, [AuthCubit] emits
/// the fresh user and the AuthWrapper swaps this screen for the app. A
/// rejected institution sees the reason and can edit & resubmit.
class AdminApprovalWaitingScreen extends StatefulWidget {
  const AdminApprovalWaitingScreen({super.key});

  @override
  State<AdminApprovalWaitingScreen> createState() => _AdminApprovalWaitingScreenState();
}

class _AdminApprovalWaitingScreenState extends State<AdminApprovalWaitingScreen> {
  bool _refreshing = false;

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    await context.read<AuthCubit>().refreshProfile();
    if (mounted) setState(() => _refreshing = false);
  }

  Future<void> _editAndResubmit(InstitutionEntity? institution) async {
    final saved = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => di.sl<InstitutionCubit>(),
        child: InstitutionProfileFormScreen(initial: institution),
      ),
    ));
    if (saved == true && mounted) await _refresh();
  }

  /// Documents, declaration and profile live on the institution screen.
  Future<void> _openVerification() async {
    await Navigator.of(context).push(InstitutionScreen.route());
    if (mounted) await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (_, s) => s is AuthAuthenticated,
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;
        final institution = user?.institution;
        final status =
            user?.institutionStatus ?? institution?.status ?? InstitutionStatus.pending;
        final rejected = status == InstitutionStatus.rejected;
        final suspended = status == InstitutionStatus.suspended;
        final (titleKey, bodyKey, icon, iconColor) = suspended
            ? ('institution_suspended_title', 'institution_suspended_body', Icons.pause_circle_outline_rounded, AppColors.gray700)
            : rejected
                ? ('institution_rejected_title', 'institution_rejected_body', Icons.error_outline_rounded, AppColors.red500)
                : ('auth_pending_approval', 'institution_pending_body', Icons.hourglass_top_rounded, AppColors.primaryColor);

        return Scaffold(
          backgroundColor: AppColors.surfaceBg,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  Icon(icon, size: AppSpacing.xxxxxl, color: iconColor),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    t.translate(titleKey),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineSmall.copyWith(color: context.textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    t.translate(bodyKey),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(color: context.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  OutlinedCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            InstitutionLogo(url: institution?.logoUrl, size: 48),
                            const SizedBox(width: AppSpacing.smd),
                            Expanded(
                              child: Text(
                                institution?.nameAr ?? user?.name ?? '',
                                style: AppTextStyles.titleMedium.copyWith(color: context.textPrimary),
                              ),
                            ),
                            InstitutionStatusBadge(status: status),
                          ],
                        ),
                        if (rejected && (institution?.rejectionReason ?? '').isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            t.translate('institution_rejection_reason'),
                            style: AppTextStyles.labelMedium.copyWith(color: context.textSecondary),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            institution!.rejectionReason!,
                            key: const Key('institution_rejection_reason'),
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.red500),
                          ),
                        ],
                        if (suspended && (institution?.suspensionReason ?? '').isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            t.translate('institution_suspension_reason'),
                            style: AppTextStyles.labelMedium.copyWith(color: context.textSecondary),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            institution!.suspensionReason!,
                            key: const Key('institution_suspension_reason'),
                            style: AppTextStyles.bodyMedium.copyWith(color: context.textPrimary),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (!suspended && institution != null) ...[
                    InstitutionChecklistCard(verification: institution.verification),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  if (!rejected && !suspended)
                    OutlinedCard(
                      child: Row(
                        children: [
                          const Icon(Icons.notifications_active_outlined, color: AppColors.primaryColor),
                          const SizedBox(width: AppSpacing.smd),
                          Expanded(
                            child: Text(
                              t.translate('auth_notification_approval'),
                              style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  if (rejected)
                    PrimaryButton(
                      key: const Key('institution_edit_resubmit'),
                      text: t.translate('institution_edit_and_resubmit'),
                      icon: Icons.edit_outlined,
                      onPressed: () => _editAndResubmit(institution),
                    ),
                  if (!suspended) ...[
                    if (rejected) const SizedBox(height: AppSpacing.sm),
                    (rejected || (institution?.verification.isComplete ?? false))
                        ? OutlinedButton.icon(
                            key: const Key('institution_complete_verification'),
                            onPressed: _openVerification,
                            icon: const Icon(Icons.verified_user_outlined),
                            label: Text(t.translate('institution_manage_verification')),
                          )
                        : PrimaryButton(
                            key: const Key('institution_complete_verification'),
                            text: t.translate('institution_complete_verification_cta'),
                            icon: Icons.verified_user_outlined,
                            onPressed: _openVerification,
                          ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    key: const Key('institution_check_status'),
                    onPressed: _refreshing ? null : _refresh,
                    icon: _refreshing
                        ? const SizedBox(
                            width: AppSpacing.iconSm,
                            height: AppSpacing.iconSm,
                            child: MkSpinner(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh_rounded),
                    label: Text(t.translate('institution_check_status')),
                  ),
                  TextButton(
                    onPressed: () => context.read<AuthCubit>().logout(),
                    child: Text(t.translate('institution_sign_out')),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
