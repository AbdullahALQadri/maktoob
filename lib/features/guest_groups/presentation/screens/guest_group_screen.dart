import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/core.dart';
import '../../../../core/design/window_size.dart';
import '../../../../core/widgets/loading/mk_spinner.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/guest_group.dart';
import '../cubit/guest_group_cubit.dart';
import '../cubit/guest_groups_state.dart';
import '../widgets/group_guest_form.dart';
import '../widgets/group_name_dialog.dart';

/// One group: its people, adding someone, a new name, deleting it.
class GuestGroupScreen extends StatelessWidget {
  const GuestGroupScreen({super.key, this.name});

  /// Shown in the bar until the group has loaded.
  final String? name;

  static Route<void> route(int groupId, {String? name}) => MaterialPageRoute(
        settings: const RouteSettings(name: '/r/guest-group'),
        builder: (_) => BlocProvider(
          create: (_) => GuestGroupCubit(
            getGroup: di.sl(),
            changeGroup: di.sl(),
            deleteGroup: di.sl(),
            groupId: groupId,
          )..load(),
          child: GuestGroupScreen(name: name),
        ),
      );

  Future<void> _rename(BuildContext context, GuestGroup group) async {
    final cubit = context.read<GuestGroupCubit>();
    final name = await showGroupNameDialog(
      context,
      title: context.tr('groups_rename'),
      action: context.tr('groups_save'),
      initial: group.name,
    );
    if (name != null && name != group.name) await cubit.rename(name);
  }

  Future<void> _confirm(BuildContext context, String question, String action, VoidCallback onYes) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        content: Text(question, style: const TextStyle(fontSize: 15, height: 1.6)),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialog).pop(false), child: Text(context.tr('common_cancel'))),
          TextButton(
            key: const Key('group_confirm'),
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(action, style: const TextStyle(color: AppColors.red500)),
          ),
        ],
      ),
    );
    if (yes == true) onYes();
  }

  @override
  Widget build(BuildContext context) {
    final gutter = context.pageGutter;
    final cubit = context.read<GuestGroupCubit>();
    return BlocConsumer<GuestGroupCubit, GuestGroupState>(
      listenWhen: (before, now) => now.deleted || (now.message != null && now.message != before.message),
      listener: (context, state) {
        if (state.deleted) return Navigator.of(context).pop();
        AppSnackBar.showError(context, message: context.tr(state.message!));
      },
      builder: (context, state) {
        final group = state.group;
        return Scaffold(
          backgroundColor: context.scaffoldBg,
          appBar: AppBar(
            title: Text(group?.name ?? name ?? context.tr('groups_title')),
            actions: [
              if (group != null) ...[
                IconButton(
                  key: const Key('group_rename'),
                  tooltip: context.tr('groups_rename'),
                  onPressed: state.busy ? null : () => _rename(context, group),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  key: const Key('group_delete'),
                  tooltip: context.tr('groups_delete'),
                  onPressed: state.busy
                      ? null
                      : () => _confirm(
                            context,
                            context.tr('groups_delete_confirm'),
                            context.tr('groups_delete'),
                            cubit.delete,
                          ),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ],
          ),
          body: group == null
              ? Center(
                  child: state.loading
                      ? const MkSpinner()
                      : OutlinedButton(onPressed: cubit.load, child: Text(context.tr('common_retry'))),
                )
              : ListView(
                  padding: EdgeInsetsDirectional.fromSTEB(gutter, 16, gutter, 32),
                  children: [
                    GroupGuestForm(busy: state.busy, onAdd: cubit.addGuest),
                    const SizedBox(height: 20),
                    Text(
                      '${context.tr('groups_guests_in')} (${group.guests.length})',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: context.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    if (group.guests.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          context.tr('groups_no_guests'),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: context.textSecondary),
                        ),
                      ),
                    for (final guest in group.guests)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(guest.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: guest.phone == null
                            ? null
                            : Text(guest.phone!, textDirection: TextDirection.ltr, textAlign: TextAlign.start),
                        trailing: guest.id == null
                            ? null
                            : IconButton(
                                key: Key('group_remove_${guest.id}'),
                                tooltip: context.tr('groups_remove'),
                                onPressed: state.busy
                                    ? null
                                    : () => _confirm(
                                          context,
                                          context.tr('groups_remove_guest'),
                                          context.tr('groups_remove'),
                                          () => cubit.removeGuest(guest.id!),
                                        ),
                                icon: const Icon(Icons.person_remove_outlined),
                              ),
                      ),
                  ],
                ),
        );
      },
    );
  }
}
