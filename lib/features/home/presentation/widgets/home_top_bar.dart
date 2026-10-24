import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../events/presentation/cubit/events_list/events_list_cubit.dart';
import 'event_search_delegate.dart';
import 'notification_bell.dart';

/// The wordmark, search across the host's events, and notifications.
class HomeTopBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeTopBar({super.key, this.onOpenEvent});

  final ValueChanged<String>? onOpenEvent;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  Future<void> _search(BuildContext context) async {
    final id = await showSearch<String?>(
      context: context,
      delegate: EventSearchDelegate(cubit: context.read<EventsListCubit>(), hint: context.tr('home_search_hint')),
    );
    if (id != null) onOpenEvent?.call(id);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: context.scaffoldBg,
      surfaceTintColor: AppColors.transparent,
      titleSpacing: 20,
      title: Text(
        context.tr('app_name'),
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: context.brandInk),
      ),
      actions: [
        IconButton(
          tooltip: context.tr('home_search_hint'),
          onPressed: () => _search(context),
          icon: Icon(Icons.search, color: context.textPrimary),
        ),
        NotificationBell(onOpenEvent: onOpenEvent),
        const SizedBox(width: 8),
      ],
    );
  }
}
