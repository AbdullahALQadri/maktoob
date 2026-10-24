import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/design/window_size.dart';
import '../../core/utils/app_colors.dart';
import '../../features/events/presentation/screens/my_events_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/scanner/presentation/screens/scanner_events_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import 'shell_bottom_bar.dart';
import 'shell_navigation.dart';
import 'shell_push_handling.dart';
import 'shell_rail.dart';
import 'shell_sidebar.dart';
import 'shell_tab.dart';
import 'tab_navigator.dart';

/// The signed-in app: four tabs, each with its own page stack, framed by a
/// bottom bar (phones), a rail (tablets) or the portal's sidebar (wide
/// windows). Tabs are built on first visit and kept afterwards.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with ShellNavigation, ShellPushHandling {
  var _tab = ShellTab.home;
  final _opened = <ShellTab>{ShellTab.home};
  final _navigators = {for (final tab in ShellTab.values) tab: GlobalKey<NavigatorState>()};

  @override
  void initState() {
    super.initState();
    listenToPushes();
  }

  @override
  void dispose() {
    stopListeningToPushes();
    super.dispose();
  }

  @override
  NavigatorState? tabNavigator(ShellTab tab) => _navigators[tab]!.currentState;

  /// Tapping the tab already shown takes it back to its first page.
  @override
  void select(ShellTab tab) {
    if (tab == _tab) {
      tabNavigator(tab)?.popUntil((route) => route.isFirst);
      return;
    }
    setState(() {
      _tab = tab;
      _opened.add(tab);
    });
  }

  /// Back closes what is open in the tab, then returns to Home, then leaves.
  Future<void> _back() async {
    final navigator = tabNavigator(_tab);
    if (navigator != null && navigator.canPop()) {
      await navigator.maybePop();
    } else if (_tab != ShellTab.home) {
      select(ShellTab.home);
    } else {
      await SystemNavigator.pop();
    }
  }

  Widget _root(ShellTab tab) => switch (tab) {
    ShellTab.home => HomeScreen(
      onViewEvent: openEvent,
      onCreateEvent: createEvent,
      onViewAllEvents: () => select(ShellTab.events),
    ),
    ShellTab.events => MyEventsScreen(onOpenEvent: openEvent),
    ShellTab.door => ScannerEventsScreen(onEventSelected: openDoor),
    ShellTab.account => const SettingsScreen(),
  };

  @override
  Widget build(BuildContext context) {
    final body = IndexedStack(
      index: _tab.index,
      children: [
        for (final tab in ShellTab.values)
          _opened.contains(tab)
              ? TabNavigator(
                  navigatorKey: _navigators[tab]!,
                  name: tab.name,
                  responsive: tab == ShellTab.home || tab == ShellTab.events,
                  root: (_) => _root(tab),
                )
              : const SizedBox.shrink(),
      ],
    );

    final Widget layout = switch (context.windowSize) {
      WindowSize.compact => Scaffold(
        body: body,
        bottomNavigationBar: ShellBottomBar(current: _tab, onSelect: select, onCreate: createEvent),
      ),
      WindowSize.medium => Scaffold(
        body: Row(
          children: [
            ShellRail(current: _tab, onSelect: select, onCreate: createEvent),
            VerticalDivider(width: 1, thickness: 1, color: context.borderColor),
            Expanded(child: body),
          ],
        ),
      ),
      _ => Scaffold(
        body: Row(
          children: [
            ShellSidebar(current: _tab, onSelect: select, onCreate: createEvent),
            Expanded(child: body),
          ],
        ),
      ),
    };

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: layout,
    );
  }
}
