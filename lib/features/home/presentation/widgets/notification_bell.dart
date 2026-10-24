import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/services/fcm_service.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../injection_container.dart' as di;
import '../../../notifications/presentation/cubit/notifications_cubit.dart';
import '../../../notifications/presentation/cubit/notifications_state.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';

/// The bell with an unread badge. It recounts on every push, so a "your
/// event is active" notification shows up without a manual refresh.
class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key, this.onOpenEvent});

  final ValueChanged<String>? onOpenEvent;

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  final NotificationsCubit _cubit = di.sl<NotificationsCubit>();
  StreamSubscription<Map<String, dynamic>>? _pushes;

  @override
  void initState() {
    super.initState();
    _cubit.load();
    _pushes = di.sl<FcmService>().messageStream.listen((_) => _cubit.load());
  }

  @override
  void dispose() {
    _pushes?.cancel();
    _cubit.close();
    super.dispose();
  }

  Future<void> _open() async {
    await NotificationsScreen.open(context, onOpenEvent: widget.onOpenEvent, cubit: _cubit);
    if (mounted) _cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      bloc: _cubit,
      builder: (context, state) {
        final unread = state is NotificationsLoaded ? state.unreadCount : 0;
        return IconButton(
          tooltip: context.tr('notifications_title'),
          onPressed: _open,
          icon: Badge(
            isLabelVisible: unread > 0,
            label: Text(unread > 99 ? '99+' : '$unread'),
            backgroundColor: AppColors.red500,
            child: Icon(
              unread > 0 ? Icons.notifications_active_outlined : Icons.notifications_outlined,
              color: context.textPrimary,
            ),
          ),
        );
      },
    );
  }
}
