import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/locale/l10n_context.dart';
import '../../../../../core/core.dart';
import '../../../../../injection_container.dart';
import '../../../domain/entities/event_entity.dart';
import '../../cubit/edit_event/edit_event_cubit.dart';
import '../../cubit/event_details/event_details_cubit.dart';
import '../../screens/edit_event_screen.dart';

/// What the host may do to the whole event, by role: managers edit (after
/// payment that is a request the team reviews), owners also cancel and delete.
class EventPageActions {
  const EventPageActions._();

  /// A draft is edited directly; after payment the same screen sends an
  /// edit request to the team (EditEventScreen decides).
  static Future<void> edit(BuildContext context, EventEntity event) async {
    final cubit = context.read<EventDetailsCubit>();
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<EditEventCubit>()..initializeWithEvent(event),
          child: const EditEventScreen(),
        ),
      ),
    );
    if (saved == true) await cubit.refreshEventDetails();
  }

  static Future<void> cancel(BuildContext context) async {
    final cubit = context.read<EventDetailsCubit>();
    final confirmed = await _confirm(
      context,
      title: 'event_cancel_action',
      body: context.tr('event_cancel_confirm'),
      keep: 'event_cancel_keep',
    );
    if (confirmed) await cubit.cancelEvent();
  }

  static Future<void> delete(BuildContext context, EventEntity event, VoidCallback onDeleted) async {
    final cubit = context.read<EventDetailsCubit>();
    final body =
        '${context.tr('event_details_delete_confirm')} "${event.name}"? ${context.tr('event_details_delete_warning')}';
    if (!await _confirm(context, title: 'event_details_delete', body: body, keep: 'common_cancel')) return;
    if (await cubit.deleteEvent() && context.mounted) {
      onDeleted();
      AppSnackBar.showSuccess(context, message: context.tr('event_details_deleted'));
    }
  }

  static Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String body,
    required String keep,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(context.tr(title)),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialog, false), child: Text(context.tr(keep))),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.red500),
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(context.tr(title)),
          ),
        ],
      ),
    );
    return result == true;
  }
}

/// Back, the event's name, and its menu.
class EventPageTopBar extends StatelessWidget implements PreferredSizeWidget {
  const EventPageTopBar({super.key, required this.event, required this.onBack});

  final EventEntity? event;
  final VoidCallback onBack;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final e = event;
    final items = <PopupMenuEntry<String>>[
      if (e != null && e.role.canManage && !e.isInactive)
        PopupMenuItem(
          value: 'edit',
          child: Text(context.tr(e.status == EventStatus.draft ? 'common_edit' : 'event_page_change')),
        ),
      if (e != null && e.canCancel && e.role.canOwn)
        PopupMenuItem(value: 'cancel', child: Text(context.tr('event_cancel_action'))),
      if (e != null && e.role.canOwn)
        PopupMenuItem(
          value: 'delete',
          child: Text(context.tr('event_details_delete'), style: const TextStyle(color: AppColors.red500)),
        ),
    ];
    return AppBar(
      backgroundColor: context.scaffoldBg,
      surfaceTintColor: AppColors.transparent,
      leading: IconButton(
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: onBack,
        icon: const BackButtonIcon(),
      ),
      title: Text(
        context.tr('event_page_title'),
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.textPrimary),
      ),
      actions: [
        if (items.isNotEmpty && e != null)
          PopupMenuButton<String>(
            tooltip: context.tr('event_page_more'),
            itemBuilder: (_) => items,
            onSelected: (action) => switch (action) {
              'edit' => EventPageActions.edit(context, e),
              'cancel' => EventPageActions.cancel(context),
              _ => EventPageActions.delete(context, e, onBack),
            },
          ),
      ],
    );
  }
}
