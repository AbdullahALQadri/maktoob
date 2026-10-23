import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/event_role.dart';
import '../../domain/entities/institution_entity.dart';
import '../cubit/institution_cubit.dart';
import '../cubit/institution_state.dart';
import '../widgets/institution_widgets.dart';
import 'package:maktoob/core/widgets/loading/mk_spinner.dart';

/// Owner only: team members, invite by phone, change role, remove.
class InstitutionTeamScreen extends StatelessWidget {
  const InstitutionTeamScreen({super.key});

  static Route<void> route() => MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => di.sl<InstitutionTeamCubit>()..load(),
          child: const InstitutionTeamScreen(),
        ),
      );

  Future<void> _invite(BuildContext context) async {
    final cubit = context.read<InstitutionTeamCubit>();
    final result = await showModalBottomSheet<(String, String)>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _InviteSheet(),
    );
    if (result != null) await cubit.invite(phone: result.$1, role: result.$2);
  }

  Future<void> _changeRole(BuildContext context, InstitutionMemberEntity member) async {
    final t = AppLocalizations.of(context)!;
    final cubit = context.read<InstitutionTeamCubit>();
    final role = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final r in kInstitutionMemberRoles)
              ListTile(
                title: Text(t.translate(EventRole.fromString(r).labelKey)),
                subtitle: Text(t.translate('institution_role_${r}_hint')),
                trailing: r == member.role ? const Icon(Icons.check, color: AppColors.primaryColor) : null,
                onTap: () => Navigator.pop(context, r),
              ),
          ],
        ),
      ),
    );
    if (role != null && role != member.role) await cubit.changeRole(member.id, role);
  }

  Future<void> _remove(BuildContext context, InstitutionMemberEntity member) async {
    final t = AppLocalizations.of(context)!;
    final cubit = context.read<InstitutionTeamCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.translate('institution_member_remove')),
        content: Text(t.translate('institution_member_remove_confirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(t.translate('common_cancel'))),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(t.translate('institution_member_remove'))),
        ],
      ),
    );
    if (ok == true) await cubit.remove(member.id);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return BlocConsumer<InstitutionTeamCubit, InstitutionTeamState>(
      listener: (context, state) {
        if (state is InstitutionTeamLoaded) {
          showInstitutionMessage(context, state.message, isError: state.messageIsError);
        }
      },
      builder: (context, state) {
        final busy = state is InstitutionTeamLoaded && state.isBusy;
        return Scaffold(
          backgroundColor: AppColors.surfaceBg,
          appBar: MaktoobAppBar(title: t.translate('institution_team')),
          floatingActionButton: FloatingActionButton.extended(
            key: const Key('institution_invite_member'),
            backgroundColor: AppColors.primaryColor,
            foregroundColor: AppColors.white,
            onPressed: busy ? null : () => _invite(context),
            icon: const Icon(Icons.person_add_alt_1_outlined),
            label: Text(t.translate('institution_invite_member')),
          ),
          body: SafeArea(
            child: switch (state) {
              InstitutionTeamError(:final message) => Center(child: Text(message)),
              InstitutionTeamLoaded(:final members) when members.isEmpty => Center(
                  child: Text(t.translate('institution_team_empty'),
                      style: AppTextStyles.bodyMedium.copyWith(color: context.textSecondary)),
                ),
              InstitutionTeamLoaded(:final members) => RefreshIndicator(
                  onRefresh: () => context.read<InstitutionTeamCubit>().load(),
                  child: ListView.separated(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xxxxxl + AppSpacing.md),
                    itemCount: members.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, i) {
                      final m = members[i];
                      return OutlinedCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m.name ?? m.phone,
                                    style: AppTextStyles.titleSmall.copyWith(color: context.textPrimary),
                                  ),
                                  Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: Text(m.phone,
                                        style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary)),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    '${t.translate(EventRole.fromString(m.role).labelKey)} · '
                                    '${t.translate(m.isActive ? 'institution_member_active' : 'institution_member_invited')}',
                                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.primaryColor),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              key: Key('member_role_${m.id}'),
                              tooltip: t.translate('institution_member_change_role'),
                              onPressed: busy ? null : () => _changeRole(context, m),
                              icon: const Icon(Icons.manage_accounts_outlined),
                            ),
                            IconButton(
                              key: Key('member_remove_${m.id}'),
                              tooltip: t.translate('institution_member_remove'),
                              onPressed: busy ? null : () => _remove(context, m),
                              icon: const Icon(Icons.person_remove_outlined, color: AppColors.red500),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              _ => const Center(child: MkSpinner()),
            },
          ),
        );
      },
    );
  }
}

class _InviteSheet extends StatefulWidget {
  const _InviteSheet();

  @override
  State<_InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends State<_InviteSheet> {
  final _phone = TextEditingController();
  String _role = 'door_staff';

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: AppSpacing.md,
        end: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(t.translate('institution_invite_member'),
              style: AppTextStyles.titleMedium.copyWith(color: context.textPrimary)),
          const SizedBox(height: AppSpacing.md),
          TextField(
            key: const Key('invite_phone'),
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: t.translate('auth_phone_number'),
              hintText: '059xxxxxxx',
              border: const OutlineInputBorder(borderRadius: AppSpacing.borderRadiusMd),
            ),
          ),
          const SizedBox(height: AppSpacing.smd),
          RadioGroup<String>(
            groupValue: _role,
            onChanged: (v) => setState(() => _role = v ?? _role),
            child: Column(
              children: [
                for (final r in kInstitutionMemberRoles)
                  RadioListTile<String>(
                    value: r,
                    title: Text(t.translate(EventRole.fromString(r).labelKey)),
                    subtitle: Text(t.translate('institution_role_${r}_hint')),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(
            text: t.translate('institution_send_invite'),
            onPressed: () {
              final phone = _phone.text.trim();
              if (phone.length < 9) return;
              Navigator.pop(context, (phone, _role));
            },
          ),
        ],
      ),
    );
  }
}
