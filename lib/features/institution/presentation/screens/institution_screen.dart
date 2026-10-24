import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../../injection_container.dart' as di;
import '../../../authentication/presentation/cubit/auth_cubit.dart';
import '../../../identity/presentation/screens/identity_verification_screen.dart';
import '../../domain/entities/event_role.dart';
import '../../domain/entities/institution_entity.dart';
import '../cubit/institution_cubit.dart';
import '../cubit/institution_state.dart';
import '../widgets/institution_verification_widgets.dart';
import '../widgets/institution_widgets.dart';
import 'institution_credits_screen.dart';
import 'institution_profile_form_screen.dart';
import 'institution_team_screen.dart';
import 'package:maktoob/core/widgets/loading/mk_spinner.dart';

/// Settings → Institution: org details, status badge, logo, team and credits
/// (owner), plus pending team invites and memberships for everyone.
class InstitutionScreen extends StatelessWidget {
  const InstitutionScreen({super.key});

  static Route<void> route() => MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => di.sl<InstitutionCubit>()..load(),
          child: const InstitutionScreen(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return BlocConsumer<InstitutionCubit, InstitutionState>(
      listener: (context, state) {
        if (state is InstitutionLoaded && state.message != null) {
          showInstitutionMessage(context, state.message, isError: state.messageIsError);
          // Accepting an invite / saving changes what the profile says.
          if (!state.messageIsError) context.read<AuthCubit>().refreshProfile();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.surfaceBg,
          appBar: MaktoobAppBar(title: t.translate('institution_title')),
          body: SafeArea(child: _body(context, state, t, isArabic)),
        );
      },
    );
  }

  Widget _body(BuildContext context, InstitutionState state, AppLocalizations t, bool isArabic) {
    if (state is InstitutionError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.message, textAlign: TextAlign.center),
            TextButton(
              onPressed: () => context.read<InstitutionCubit>().load(),
              child: Text(t.translate('common_retry')),
            ),
          ],
        ),
      );
    }
    if (state is! InstitutionLoaded) {
      return const Center(child: MkSpinner());
    }

    final overview = state.overview;
    final institution = overview.institution;
    final cubit = context.read<InstitutionCubit>();

    return RefreshIndicator(
      onRefresh: () => cubit.load(silent: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        children: [
          if (institution != null) ...[
            InstitutionStatusNotice(institution: institution),
            OutlinedCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InstitutionLogo(url: institution.logoUrl),
                      const SizedBox(width: AppSpacing.smd),
                      Expanded(
                        child: Text(
                          institution.displayName(isArabic),
                          style: AppTextStyles.titleMedium.copyWith(color: context.textPrimary),
                        ),
                      ),
                      InstitutionStatusBadge(status: institution.status),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.smd),
                  InfoRow(
                    label: t.translate('institution_sector'),
                    value: institution.sector == null ? null : t.translate('institution_sector_${institution.sector}'),
                  ),
                  if (institution.displayName(isArabic) != institution.officialName(isArabic))
                    InfoRow(label: t.translate('institution_check_name'), value: institution.officialName(isArabic)),
                  InfoRow(
                    label: t.translate('institution_legal_form'),
                    value: institution.legalForm == null ? null : t.translate('institution_legal_form_${institution.legalForm}'),
                  ),
                  InfoRow(label: t.translate('institution_registration_authority'), value: institution.registrationAuthority),
                  InfoRow(label: t.translate('institution_registration_country'), value: institution.registrationCountry),
                  InfoRow(label: t.translate('institution_registration_date'), value: institution.registrationDate),
                  InfoRow(
                    label: t.translate('institution_representative_role'),
                    value: institution.representativeRole == null
                        ? null
                        : t.translate('institution_representative_role_${institution.representativeRole}'),
                  ),
                  InfoRow(label: t.translate('institution_contact_person'), value: institution.contactPerson),
                  InfoRow(label: t.translate('institution_contact_phone'), value: institution.contactPhone),
                  InfoRow(label: t.translate('institution_registration_number'), value: institution.registrationNumber),
                  InfoRow(label: t.translate('institution_tax_number'), value: institution.taxNumber),
                  InfoRow(label: t.translate('institution_website'), value: institution.website),
                  InfoRow(label: t.translate('institution_official_email'), value: institution.officialEmail),
                  InfoRow(
                    label: t.translate('auth_governorate'),
                    value: institution.governorate == null
                        ? null
                        : (isArabic ? kPalestineGovernorates[institution.governorate] : null) ?? institution.governorate,
                  ),
                  InfoRow(label: t.translate('institution_address'), value: institution.address),
                  if (institution.discountPercent > 0)
                    InfoRow(
                      label: t.translate('institution_discount'),
                      value: '${institution.discountPercent.toStringAsFixed(0)}%',
                    ),
                  if (institution.status == InstitutionStatus.rejected &&
                      (institution.rejectionReason ?? '').isNotEmpty)
                    InfoRow(label: t.translate('institution_rejection_reason'), value: institution.rejectionReason),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    key: const Key('institution_edit_profile'),
                    onPressed: state.isBusy
                        ? null
                        : () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: cubit,
                                child: InstitutionProfileFormScreen(initial: institution),
                              ),
                            )),
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(t.translate('institution_profile_edit')),
                  ),
                ],
              ),
            ),
            if (!institution.isApproved) ...[
              const SizedBox(height: AppSpacing.md),
              InstitutionChecklistCard(
                verification: institution.verification,
                onVerifyIdentity: () async {
                  await Navigator.of(context).push(IdentityVerificationScreen.route());
                  if (context.mounted) {
                    context.read<AuthCubit>().refreshProfile();
                    cubit.load(silent: true);
                  }
                },
                onEditProfile: state.isBusy
                    ? null
                    : () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: cubit,
                            child: InstitutionProfileFormScreen(initial: institution),
                          ),
                        )),
                onUploadAuthorization: institution.representativeRole == 'authorized' && !state.isBusy
                    ? () => pickAndUploadInstitutionDocument(context, cubit, 'authorization_letter')
                    : null,
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            InstitutionDocumentsCard(institution: institution, busy: state.isBusy),
            if (institution.isApproved) ...[
              const SizedBox(height: AppSpacing.md),
              _NavTile(
                key: const Key('institution_team_tile'),
                icon: Icons.groups_outlined,
                title: t.translate('institution_team'),
                onTap: () => Navigator.of(context).push(InstitutionTeamScreen.route()),
              ),
              const SizedBox(height: AppSpacing.sm),
              _NavTile(
                key: const Key('institution_credits_tile'),
                icon: Icons.account_balance_wallet_outlined,
                title: t.translate('institution_credits'),
                trailing: '${institution.invitationCredits}',
                onTap: () => Navigator.of(context).push(InstitutionCreditsScreen.route()),
              ),
            ],
          ],
          if (overview.pendingInvites.isNotEmpty) ...[
            SectionTitle(t.translate('institution_pending_invites')),
            for (final invite in overview.pendingInvites)
              Padding(
                padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
                child: OutlinedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invite.institutionName,
                        style: AppTextStyles.titleSmall.copyWith(color: context.textPrimary),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        t.translate(EventRole.fromString(invite.role).labelKey),
                        style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: PrimaryButton(
                              key: Key('invite_accept_${invite.id}'),
                              text: t.translate('institution_invite_accept'),
                              onPressed: state.isBusy ? null : () => cubit.acceptInvite(invite.id),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: OutlinedButton(
                              key: Key('invite_decline_${invite.id}'),
                              onPressed: state.isBusy ? null : () => cubit.declineInvite(invite.id),
                              child: Text(t.translate('institution_invite_decline')),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
          if (overview.memberships.isNotEmpty) ...[
            SectionTitle(t.translate('institution_my_memberships')),
            for (final m in overview.memberships)
              Padding(
                padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
                child: OutlinedCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.institutionName,
                                style: AppTextStyles.titleSmall.copyWith(color: context.textPrimary)),
                            Text(
                              t.translate(EventRole.fromString(m.role).labelKey),
                              style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: state.isBusy ? null : () => cubit.declineInvite(m.membershipId),
                        child: Text(t.translate('institution_leave')),
                      ),
                    ],
                  ),
                ),
              ),
          ],
          if (institution == null && overview.pendingInvites.isEmpty && overview.memberships.isEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.only(top: AppSpacing.xl),
              child: Text(
                t.translate('institution_none'),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: context.textSecondary),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback onTap;

  const _NavTile({super.key, required this.icon, required this.title, this.trailing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusLg,
      child: OutlinedCard(
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryColor),
            const SizedBox(width: AppSpacing.smd),
            Expanded(child: Text(title, style: AppTextStyles.bodyLarge.copyWith(color: context.textPrimary))),
            if (trailing != null)
              Text(trailing!, style: AppTextStyles.titleSmall.copyWith(color: AppColors.primaryColor)),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
