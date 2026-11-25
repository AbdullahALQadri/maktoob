import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/design/window_size.dart';
import '../../../../core/utils/app_colors.dart';
import '../../domain/entities/staff_entities.dart';
import '../cubit/staff_session_cubit.dart';
import '../widgets/staff_clients_view.dart';
import '../widgets/staff_events_view.dart';
import '../widgets/staff_requests_view.dart';
import '../widgets/staff_today_view.dart';

/// The staff mode: Today, the payment requests to review, clients, events.
/// A bottom bar on a phone, a rail on wider windows.
class StaffShell extends StatefulWidget {
  const StaffShell({super.key, required this.user});

  final StaffUser user;

  @override
  State<StaffShell> createState() => _StaffShellState();
}

class _StaffShellState extends State<StaffShell> {
  static const _tabs = [
    ('staff_tab_today', Icons.today_outlined),
    ('staff_tab_payments', Icons.receipt_long_outlined),
    ('staff_tab_clients', Icons.people_outline),
    ('staff_tab_events', Icons.event_outlined),
  ];

  int _index = 0;

  /// A tab is built the first time it is opened, then kept.
  final _opened = <int>{0};

  void _go(int index) => setState(() {
        _index = index;
        _opened.add(index);
      });

  Widget _page(int index) => switch (index) {
        0 => StaffTodayView(onOpenPayments: () => _go(1)),
        1 => const StaffRequestsView(),
        2 => const StaffClientsView(),
        _ => const StaffEventsView(),
      };

  @override
  Widget build(BuildContext context) {
    final wide = context.windowSize.atLeastMedium;
    final body = IndexedStack(
      index: _index,
      children: [for (var i = 0; i < _tabs.length; i++) _opened.contains(i) ? _page(i) : const SizedBox.shrink()],
    );
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(context.tr(_tabs[_index].$1)),
        actions: [
          IconButton(
            key: const Key('staff_leave'),
            tooltip: '${context.tr('staff_sign_out')} (${widget.user.name})',
            onPressed: context.read<StaffSessionCubit>().leave,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: wide
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: _go,
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final (key, icon) in _tabs)
                      NavigationRailDestination(icon: Icon(icon), label: Text(context.tr(key))),
                  ],
                ),
                VerticalDivider(width: 1, color: context.borderColor),
                Expanded(child: body),
              ],
            )
          : body,
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: _go,
              destinations: [
                for (final (key, icon) in _tabs) NavigationDestination(icon: Icon(icon), label: context.tr(key)),
              ],
            ),
    );
  }
}
