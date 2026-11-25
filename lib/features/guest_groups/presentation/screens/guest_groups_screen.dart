import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/core.dart';
import '../../../../core/design/window_size.dart';
import '../../../../core/widgets/loading/mk_spinner.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/guest_group.dart';
import '../cubit/guest_groups_cubit.dart';
import '../cubit/guest_groups_state.dart';
import '../widgets/group_name_dialog.dart';
import '../widgets/guest_group_tile.dart';
import 'guest_group_screen.dart';

/// "Guest groups" (My account): the people the client invites again and
/// again, saved once. The portal's page in the app.
class GuestGroupsScreen extends StatelessWidget {
  const GuestGroupsScreen({super.key});

  /// The screen with its own cubit, already loading.
  static Route<void> route() => MaterialPageRoute(
        settings: const RouteSettings(name: '/r/guest-groups'),
        builder: (_) => BlocProvider(
          create: (_) => di.sl<GuestGroupsCubit>()..load(),
          child: const GuestGroupsScreen(),
        ),
      );

  Future<void> _create(BuildContext context) async {
    final cubit = context.read<GuestGroupsCubit>();
    final name = await showGroupNameDialog(context, title: context.tr('groups_new'), action: context.tr('groups_create'));
    if (name == null) return;
    final group = await cubit.create(name);
    if (group != null && context.mounted) await _open(context, group);
  }

  Future<void> _open(BuildContext context, GuestGroup group) async {
    final cubit = context.read<GuestGroupsCubit>();
    await Navigator.of(context).push(GuestGroupScreen.route(group.id, name: group.name));
    // A new name, new people or a deleted group show without a manual refresh.
    await cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    final gutter = context.pageGutter;
    return BlocConsumer<GuestGroupsCubit, GuestGroupsState>(
      listenWhen: (before, now) => now.message != null && now.message != before.message,
      listener: (context, state) => AppSnackBar.showError(context, message: context.tr(state.message!)),
      builder: (context, state) {
        final overview = state.overview;
        return Scaffold(
          backgroundColor: context.scaffoldBg,
          appBar: AppBar(title: Text(context.tr('groups_title'))),
          floatingActionButton: overview == null || overview.groups.isEmpty
              ? null
              : FloatingActionButton.extended(
                  key: const Key('groups_new'),
                  onPressed: state.busy ? null : () => _create(context),
                  icon: const Icon(Icons.add),
                  label: Text(context.tr('groups_new')),
                ),
          body: state.loading && overview == null
              ? const Center(child: MkSpinner())
              : overview == null
                  ? _Retry(onRetry: context.read<GuestGroupsCubit>().load)
                  : overview.groups.isEmpty
                      ? _Empty(onCreate: state.busy ? null : () => _create(context))
                      : RefreshIndicator(
                          onRefresh: context.read<GuestGroupsCubit>().load,
                          child: ListView.separated(
                            padding: EdgeInsetsDirectional.fromSTEB(gutter, 16, gutter, 96),
                            itemCount: overview.groups.length + 1,
                            separatorBuilder: (_, _) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return Text(
                                  context.tr('groups_total', {'count': overview.totalGuests}),
                                  style: TextStyle(fontSize: 14, color: context.textSecondary),
                                );
                              }
                              final group = overview.groups[index - 1];
                              return GuestGroupTile(group: group, onTap: () => _open(context, group));
                            },
                          ),
                        ),
        );
      },
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onCreate});

  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.groups_outlined, size: 56, color: context.textSecondary),
            const SizedBox(height: 12),
            Text(
              context.tr('groups_empty'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: context.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              context.tr('groups_empty_hint'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.6, color: context.textSecondary),
            ),
            const SizedBox(height: 20),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: PrimaryButton(
                key: const Key('groups_first'),
                text: context.tr('groups_first'),
                icon: Icons.add,
                onPressed: onCreate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Retry extends StatelessWidget {
  const _Retry({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh, size: 18),
        label: Text(context.tr('common_retry')),
      ),
    );
  }
}
