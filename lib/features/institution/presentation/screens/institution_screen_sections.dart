part of 'institution_screen.dart';

/// Invitations to join someone's institution, and the institutions this
/// account already belongs to.
extension _InstitutionScreenSections on InstitutionScreen {
  List<Widget> _inviteCards(BuildContext context, InstitutionLoaded state, AppLocalizations t) {
    final overview = state.overview;
    final cubit = context.read<InstitutionCubit>();
    if (overview.pendingInvites.isEmpty) return const [];
    return [
      SectionTitle(t.translate('institution_pending_invites')),
      for (final invite in overview.pendingInvites)
        Padding(
          padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
          child: OutlinedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(invite.institutionName, style: AppTextStyles.titleSmall.copyWith(color: context.textPrimary)),
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
    ];
  }

  List<Widget> _membershipCards(BuildContext context, InstitutionLoaded state, AppLocalizations t) {
    final overview = state.overview;
    final cubit = context.read<InstitutionCubit>();
    if (overview.memberships.isEmpty) return const [];
    return [
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
                      Text(m.institutionName, style: AppTextStyles.titleSmall.copyWith(color: context.textPrimary)),
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
    ];
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
