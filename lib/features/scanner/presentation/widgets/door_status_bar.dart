import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../domain/entities/door_entities.dart';
import '../cubit/door_status_cubit.dart';
import 'door_texts.dart';

/// Tells the door staff, at a glance, how this phone is working:
/// connected (the server decides), on the venue hub, or alone from the
/// saved list; how many check-ins wait to upload; when the list was last
/// updated; and any problem that needs them.
class DoorStatusBar extends StatelessWidget {
  final VoidCallback? onGateTap;

  const DoorStatusBar({super.key, this.onGateTap});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return BlocBuilder<DoorStatusCubit, DoorStatus>(
      builder: (context, s) {
        final (color, icon, label) = switch (s.link) {
          DoorLink.online => (AppColors.green600, Icons.cloud_done_outlined, t.translate('door_link_online')),
          DoorLink.hub => (AppColors.primaryDark, Icons.router_outlined, t.translate('door_link_hub')),
          DoorLink.offline => (AppColors.amber700, Icons.cloud_off_outlined, t.translate('door_link_offline')),
        };
        final gate = s.gate;

        return Container(
          key: const Key('door_status_bar'),
          padding: const EdgeInsetsDirectional.all(AppSpacing.smd),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(color: AppColors.gray200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: AppSpacing.iconMd),
                  AppSpacing.horizontalSpace8,
                  Expanded(
                    child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
                  ),
                  if (s.syncing)
                    const SizedBox(
                      width: AppSpacing.iconSm,
                      height: AppSpacing.iconSm,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (s.session?.hasServer ?? false)
                    IconButton(
                      key: const Key('door_sync_now'),
                      tooltip: t.translate('door_menu_sync'),
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.sync, size: AppSpacing.iconMd),
                      onPressed: () => context.read<DoorStatusCubit>().syncNow(),
                    ),
                ],
              ),
              AppSpacing.verticalSpace4,
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.xs,
                children: [
                  _Fact(
                    icon: s.pending > 0 ? Icons.upload_outlined : Icons.check_circle_outline,
                    color: s.pending > 0 ? AppColors.amber700 : AppColors.gray600,
                    text: s.pending > 0
                        ? t.translate('door_pending').replaceAll('{count}', '${s.pending}')
                        : t.translate('door_all_uploaded'),
                  ),
                  _Fact(
                    icon: Icons.list_alt_outlined,
                    text: t.translate('door_list_updated').replaceAll('{time}', DoorTexts.ago(t, s.lastSyncAt ?? s.packDownloadedAt)),
                  ),
                  if (s.hubRunning || s.peers > 0)
                    _Fact(icon: Icons.devices_other_outlined, text: t.translate('door_hub_peers').replaceAll('{count}', '${s.peers}')),
                ],
              ),
              if (s.gates.isNotEmpty || gate != null) ...[
                AppSpacing.verticalSpace8,
                InkWell(
                  key: const Key('door_gate_chip'),
                  onTap: onGateTap,
                  borderRadius: AppSpacing.borderRadiusSm,
                  child: Container(
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.sky50,
                      borderRadius: AppSpacing.borderRadiusSm,
                      border: Border.all(color: AppColors.sky200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.door_front_door_outlined, size: AppSpacing.iconSm, color: AppColors.primaryDark),
                        AppSpacing.horizontalSpace4,
                        Text(
                          gate == null
                              ? t.translate('door_gate_none')
                              : '${t.translate('door_gate')}: ${gate.name}',
                          style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        AppSpacing.horizontalSpace4,
                        const Icon(Icons.expand_more, size: AppSpacing.iconSm, color: AppColors.primaryDark),
                      ],
                    ),
                  ),
                ),
              ],
              if (s.problem != null) ...[
                AppSpacing.verticalSpace8,
                Container(
                  key: const Key('door_problem'),
                  width: double.infinity,
                  padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.red100,
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: Text(
                    DoorTexts.problem(t, s.problem!),
                    style: const TextStyle(color: AppColors.red500, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
              if (!s.hasPack && s.session != null) ...[
                AppSpacing.verticalSpace8,
                Text(t.translate('door_reason_no_pack'), style: const TextStyle(color: AppColors.gray600, fontSize: 13)),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Fact extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _Fact({required this.icon, required this.text, this.color = AppColors.gray600});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSpacing.iconSm, color: color),
          AppSpacing.horizontalSpace4,
          Text(text, style: TextStyle(color: color, fontSize: 12.5)),
        ],
      );
}

class _GateOption extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _GateOption({required this.title, this.subtitle, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
        onTap: onTap,
        leading: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          color: selected ? AppColors.primaryColor : AppColors.gray400,
        ),
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle!),
      );
}

/// Bottom sheet to choose this phone's gate (from the downloaded list).
Future<void> showGatePicker(BuildContext context) async {
  final t = AppLocalizations.of(context)!;
  final cubit = context.read<DoorStatusCubit>();
  final status = cubit.state;
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.md),
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Text(t.translate('door_choose_gate'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          _GateOption(
            title: t.translate('door_gate_none'),
            selected: status.session?.gateId == null,
            onTap: () {
              cubit.setGate(null);
              Navigator.of(sheet).pop();
            },
          ),
          for (final g in status.gates.where((g) => g.isActive))
            _GateOption(
              title: g.name,
              subtitle: DoorTexts.audience(t, g.audience),
              selected: status.session?.gateId == g.id,
              onTap: () {
                cubit.setGate(g.id);
                Navigator.of(sheet).pop();
              },
            ),
        ],
      ),
    ),
  );
}
