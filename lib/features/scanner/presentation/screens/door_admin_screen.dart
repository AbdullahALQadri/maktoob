import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../injection_container.dart' as di;
import '../../data/models/door_models.dart';
import '../../domain/entities/door_entities.dart';
import '../../domain/repositories/door_admin_repository.dart';
import '../cubit/door_admin_cubit.dart';
import '../widgets/door_texts.dart';

/// The host's doors (needs a connection): who came in through which gate,
/// the gates, door codes for staff phones, the phones, double admissions.
class DoorAdminScreen extends StatelessWidget {
  final DoorSession session;

  const DoorAdminScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DoorAdminCubit(repository: di.sl<DoorAdminRepository>(), session: session)..load(),
      child: const _DoorAdminView(),
    );
  }
}

class _DoorAdminView extends StatelessWidget {
  const _DoorAdminView();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.translate('door_admin_title')),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: t.translate('door_admin_report')),
              Tab(text: t.translate('door_admin_gates')),
              Tab(text: t.translate('door_admin_staff')),
            ],
          ),
        ),
        body: BlocConsumer<DoorAdminCubit, DoorAdminState>(
          listenWhen: (a, b) => b.created != null && a.created != b.created,
          listener: (context, s) => _showCreatedCode(context, s.created!),
          builder: (context, s) {
            if (s.summary == null) {
              if (s.loading) return const Center(child: CircularProgressIndicator());
              return _Message(
                icon: s.offline ? Icons.cloud_off_outlined : Icons.error_outline,
                text: s.offline ? t.translate('door_admin_offline') : (s.error ?? t.translate('door_reason_refused')),
                onRetry: () => context.read<DoorAdminCubit>().load(),
              );
            }
            return Column(
              children: [
                if (s.loading) const LinearProgressIndicator(minHeight: 2),
                if (s.offline || s.error != null)
                  Container(
                    width: double.infinity,
                    color: AppColors.amber50,
                    padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
                    child: Text(
                      s.offline ? t.translate('door_admin_offline') : s.error!,
                      style: const TextStyle(color: AppColors.amber700),
                    ),
                  ),
                const Expanded(child: TabBarView(children: [_ReportTab(), _GatesTab(), _StaffTab()])),
              ],
            );
          },
        ),
      ),
    );
  }

  static Future<void> _showCreatedCode(BuildContext context, DoorCodeCreated created) async {
    final t = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(t.translate('door_code_created_title')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(t.translate('door_code_created_desc'), style: const TextStyle(color: AppColors.gray600)),
            AppSpacing.verticalSpace16,
            QrImageView(data: created.code, size: 160),
            AppSpacing.verticalSpace8,
            SelectableText(
              created.code,
              key: const Key('door_code_plain'),
              textDirection: TextDirection.ltr,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: 2),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Clipboard.setData(ClipboardData(text: created.code)),
            child: Text(t.translate('door_code_copy')),
          ),
          TextButton(
            onPressed: () => Share.share(created.shareText.isNotEmpty ? created.shareText : created.code),
            child: Text(t.translate('door_code_share')),
          ),
          TextButton(onPressed: () => Navigator.of(dialog).pop(), child: Text(t.translate('common_close'))),
        ],
      ),
    );
    if (context.mounted) context.read<DoorAdminCubit>().dismissCreated();
  }
}

class _ReportTab extends StatelessWidget {
  const _ReportTab();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final s = context.watch<DoorAdminCubit>().state.summary!;
    return RefreshIndicator(
      onRefresh: () => context.read<DoorAdminCubit>().load(),
      child: ListView(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _Stat(label: t.translate('door_stat_invitations'), value: s.invitations),
              _Stat(label: t.translate('door_stat_checked_in'), value: s.checkedIn),
              _Stat(label: t.translate('door_stat_companions'), value: s.companions),
              _Stat(label: t.translate('door_stat_people'), value: s.people),
              if (s.flagged > 0) _Stat(label: t.translate('door_stat_flagged'), value: s.flagged, alert: true),
            ],
          ),
          AppSpacing.verticalSpace24,
          Text(t.translate('door_report_by_gate'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          AppSpacing.verticalSpace8,
          for (final g in s.gates)
            _Row(
              title: g.gate!.name,
              subtitle: DoorTexts.audience(t, g.gate!.audience),
              trailing: t
                  .translate('door_report_gate_count')
                  .replaceAll('{guests}', '${g.guests}')
                  .replaceAll('{companions}', '${g.companions}'),
            ),
          if (s.noGate.guests > 0 || s.gates.isEmpty)
            _Row(
              title: t.translate('door_gate_none'),
              trailing: t
                  .translate('door_report_gate_count')
                  .replaceAll('{guests}', '${s.noGate.guests}')
                  .replaceAll('{companions}', '${s.noGate.companions}'),
            ),
        ],
      ),
    );
  }
}

class _GatesTab extends StatelessWidget {
  const _GatesTab();

  Future<void> _edit(BuildContext context, {DoorGate? gate}) async {
    final t = AppLocalizations.of(context)!;
    final cubit = context.read<DoorAdminCubit>();
    final name = TextEditingController(text: gate?.name ?? '');
    var audience = gate?.audience ?? 'all';
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialog) => StatefulBuilder(
        builder: (dialog, setState) => AlertDialog(
          title: Text(t.translate(gate == null ? 'door_gate_add' : 'door_gate_edit')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const Key('door_gate_name'),
                controller: name,
                maxLength: 60,
                decoration: InputDecoration(
                  labelText: t.translate('door_gate_name'),
                  hintText: t.translate('door_gate_name_hint'),
                ),
              ),
              DropdownButtonFormField<String>(
                initialValue: audience,
                decoration: InputDecoration(labelText: t.translate('door_gate_audience')),
                items: [
                  for (final a in const ['all', 'men', 'women'])
                    DropdownMenuItem(value: a, child: Text(DoorTexts.audience(t, a))),
                ],
                onChanged: (v) => setState(() => audience = v ?? 'all'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialog).pop(false), child: Text(t.translate('common_cancel'))),
            TextButton(onPressed: () => Navigator.of(dialog).pop(true), child: Text(t.translate('common_save'))),
          ],
        ),
      ),
    );
    if (saved != true || name.text.trim().isEmpty) return;
    gate == null
        ? await cubit.addGate(name.text.trim(), audience)
        : await cubit.renameGate(gate.id, name.text.trim(), audience);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final s = context.watch<DoorAdminCubit>().state;
    return Scaffold(
      floatingActionButton: s.canManage
          ? FloatingActionButton.extended(
              key: const Key('door_gate_add'),
              onPressed: () => _edit(context),
              icon: const Icon(Icons.add),
              label: Text(t.translate('door_gate_add')),
            )
          : null,
      body: s.gates.isEmpty
          ? _Message(icon: Icons.door_front_door_outlined, text: t.translate('door_gates_empty'))
          : ListView(
              padding: const EdgeInsetsDirectional.all(AppSpacing.md),
              children: [
                for (final g in s.gates)
                  _Row(
                    title: g.name,
                    subtitle: DoorTexts.audience(t, g.audience),
                    actions: s.canManage
                        ? [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _edit(context, gate: g),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.red500),
                              onPressed: () async {
                                if (await _confirm(context, t.translate('door_gate_delete_confirm'))) {
                                  if (context.mounted) await context.read<DoorAdminCubit>().deleteGate(g.id);
                                }
                              },
                            ),
                          ]
                        : const [],
                  ),
              ],
            ),
    );
  }
}

class _StaffTab extends StatelessWidget {
  const _StaffTab();

  Future<void> _newCode(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final cubit = context.read<DoorAdminCubit>();
    final label = TextEditingController();
    int? gateId;
    var devices = 5;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialog) => StatefulBuilder(
        builder: (dialog, setState) => AlertDialog(
          title: Text(t.translate('door_code_new')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t.translate('door_code_new_desc'), style: const TextStyle(color: AppColors.gray600)),
              TextField(
                controller: label,
                maxLength: 80,
                decoration: InputDecoration(
                  labelText: t.translate('door_code_label'),
                  hintText: t.translate('door_code_label_hint'),
                ),
              ),
              DropdownButtonFormField<int?>(
                initialValue: gateId,
                decoration: InputDecoration(labelText: t.translate('door_gate')),
                items: [
                  DropdownMenuItem<int?>(value: null, child: Text(t.translate('door_gate_none'))),
                  for (final g in cubit.state.gates) DropdownMenuItem<int?>(value: g.id, child: Text(g.name)),
                ],
                onChanged: (v) => setState(() => gateId = v),
              ),
              Row(
                children: [
                  Expanded(child: Text(t.translate('door_code_devices').replaceAll('{count}', '$devices'))),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: devices > 1 ? () => setState(() => devices--) : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: devices < 50 ? () => setState(() => devices++) : null,
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialog).pop(false), child: Text(t.translate('common_cancel'))),
            TextButton(onPressed: () => Navigator.of(dialog).pop(true), child: Text(t.translate('door_code_create'))),
          ],
        ),
      ),
    );
    if (ok == true) await cubit.createCode(label: label.text.trim(), gateId: gateId, maxDevices: devices);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final s = context.watch<DoorAdminCubit>().state;
    final gates = {for (final g in s.gates) g.id: g.name};
    final devices = s.summary?.devices ?? const <DoorDeviceModel>[];
    return Scaffold(
      floatingActionButton: s.canManage
          ? FloatingActionButton.extended(
              key: const Key('door_code_new'),
              onPressed: () => _newCode(context),
              icon: const Icon(Icons.key_outlined),
              label: Text(t.translate('door_code_new')),
            )
          : null,
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 96),
        children: [
          Text(t.translate('door_staff_intro'), style: const TextStyle(color: AppColors.gray600, height: 1.5)),
          AppSpacing.verticalSpace16,
          Text(t.translate('door_codes_title'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          AppSpacing.verticalSpace8,
          if (s.codes.isEmpty) Text(t.translate('door_codes_empty'), style: const TextStyle(color: AppColors.gray500)),
          for (final c in s.codes)
            _Row(
              title: c.label ?? t.translate('door_code_unnamed'),
              subtitle: [
                '…${c.hint}',
                if (c.gateId != null) gates[c.gateId] ?? '',
                t
                    .translate('door_code_used')
                    .replaceAll('{used}', '${c.usedCount}')
                    .replaceAll('{max}', '${c.maxDevices}'),
                if (c.revoked) t.translate('door_code_cancelled') else if (!c.usable) t.translate('door_code_unusable'),
              ].where((p) => p.isNotEmpty).join(' · '),
              actions: s.canManage && !c.revoked
                  ? [
                      IconButton(
                        icon: const Icon(Icons.block, color: AppColors.red500),
                        tooltip: t.translate('door_code_cancel'),
                        onPressed: () async {
                          if (await _confirm(context, t.translate('door_code_cancel_confirm'))) {
                            if (context.mounted) await context.read<DoorAdminCubit>().cancelCode(c.id);
                          }
                        },
                      ),
                    ]
                  : const [],
            ),
          AppSpacing.verticalSpace24,
          Text(t.translate('door_devices_title'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          AppSpacing.verticalSpace8,
          if (devices.isEmpty)
            Text(t.translate('door_devices_empty'), style: const TextStyle(color: AppColors.gray500)),
          for (final d in devices)
            _Row(
              title: d.name,
              subtitle: [
                t.translate('door_device_kind_${d.kind}'),
                if (d.gateId != null) gates[d.gateId] ?? '',
                t.translate('door_device_seen').replaceAll('{time}', DoorTexts.ago(t, d.lastSeenAt)),
                if (d.pending > 0) t.translate('door_pending').replaceAll('{count}', '${d.pending}'),
                t.translate('door_device_check_ins').replaceAll('{count}', '${d.checkIns}'),
                if (d.revoked) t.translate('door_device_removed'),
              ].where((p) => p.isNotEmpty).join(' · '),
              actions: s.canManage && d.kind == 'paired' && !d.revoked
                  ? [
                      IconButton(
                        icon: const Icon(Icons.phonelink_erase_outlined, color: AppColors.red500),
                        tooltip: t.translate('door_device_remove'),
                        onPressed: () async {
                          if (await _confirm(context, t.translate('door_device_remove_confirm'))) {
                            if (context.mounted) await context.read<DoorAdminCubit>().removeDevice(d.id);
                          }
                        },
                      ),
                    ]
                  : const [],
            ),
        ],
      ),
    );
  }
}

Future<bool> _confirm(BuildContext context, String text) async {
  final t = AppLocalizations.of(context)!;
  return await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
          content: Text(text),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialog).pop(false), child: Text(t.translate('common_cancel'))),
            TextButton(onPressed: () => Navigator.of(dialog).pop(true), child: Text(t.translate('common_confirm'))),
          ],
        ),
      ) ??
      false;
}

class _Stat extends StatelessWidget {
  final String label;
  final int value;
  final bool alert;

  const _Stat({required this.label, required this.value, this.alert = false});

  @override
  Widget build(BuildContext context) => Container(
    width: 150,
    padding: const EdgeInsetsDirectional.all(AppSpacing.smd),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: AppSpacing.borderRadiusMd,
      border: Border.all(color: alert ? AppColors.amber200 : AppColors.gray200),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: alert ? AppColors.amber700 : AppColors.gray900,
          ),
        ),
        Text(label, style: const TextStyle(color: AppColors.gray600, fontSize: 12.5)),
      ],
    ),
  );
}

class _Row extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? trailing;
  final List<Widget> actions;

  const _Row({required this.title, this.subtitle, this.trailing, this.actions = const []});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
    padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.smd, vertical: AppSpacing.sm),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: AppSpacing.borderRadiusMd,
      border: Border.all(color: AppColors.gray200),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              if (subtitle != null && subtitle!.isNotEmpty)
                Text(subtitle!, style: const TextStyle(color: AppColors.gray600, fontSize: 12.5)),
            ],
          ),
        ),
        if (trailing != null) Text(trailing!, style: const TextStyle(color: AppColors.gray700)),
        ...actions,
      ],
    ),
  );
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onRetry;

  const _Message({required this.icon, required this.text, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.gray400),
            AppSpacing.verticalSpace12,
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.gray600),
            ),
            if (onRetry != null) ...[
              AppSpacing.verticalSpace12,
              OutlinedButton(onPressed: onRetry, child: Text(t.translate('common_retry'))),
            ],
          ],
        ),
      ),
    );
  }
}
