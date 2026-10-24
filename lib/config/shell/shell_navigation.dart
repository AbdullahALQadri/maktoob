import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/design/window_size.dart';
import '../../features/events/domain/entities/event_entity.dart';
import '../../features/events/presentation/cubit/events_list/events_list_cubit.dart';
import '../../features/events/presentation/screens/event_details_screen.dart';
import '../../features/home/presentation/utils/refresh_event_lists.dart';
import '../../features/invitation/presentation/cubit/invitation_cubit.dart';
import '../../features/invitation/presentation/screens/invitation_wizard_screen.dart';
import '../../features/scanner/domain/entities/door_entities.dart';
import '../../features/scanner/presentation/cubit/scanner_cubit.dart';
import '../../features/scanner/presentation/screens/qr_scanner_screen.dart';
import '../../injection_container.dart' as di;
import 'app_shell.dart';
import 'shell_tab.dart';

/// Where things open: phones show a page full screen; tablets and desktops
/// open it inside its tab, next to the menu.
mixin ShellNavigation on State<AppShell> {
  NavigatorState? tabNavigator(ShellTab tab);

  void select(ShellTab tab);

  Future<T?> openIn<T>(ShellTab tab, WidgetBuilder page) {
    final route = MaterialPageRoute<T>(builder: page);
    if (context.windowSize.isCompact) return Navigator.of(context, rootNavigator: true).push(route);

    select(tab);
    final navigator = tabNavigator(tab);
    if (navigator != null) return navigator.push(route);
    // The tab is shown for the first time: its navigator exists next frame.
    final done = Completer<T?>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final opened = tabNavigator(tab)?.push(route);
      opened == null ? done.complete(null) : done.complete(opened);
    });
    return done.future;
  }

  /// An event from anywhere (home, a notification). Door staff of an
  /// institution may only scan it: their door opens instead.
  void openEvent(String id) {
    final known = _knownEvent(id);
    if (known != null && known.role.isScannerOnly) return openDoor(known);
    openIn<void>(ShellTab.events, (page) => EventDetailsScreen(eventId: id, onBack: () => Navigator.of(page).pop()));
  }

  /// The host's (or an institution member's) own door for one event; the
  /// engine restores the phone's name, gate and venue hub.
  void openDoor(EventEntity event) {
    openIn<void>(
      ShellTab.door,
      (page) => BlocProvider(
        create: (_) => di.sl<ScannerCubit>(),
        child: QRScannerScreen(
          session: DoorSession.client(int.tryParse(event.id) ?? 0, event.name),
          event: event,
          onBack: () => Navigator.of(page).pop(),
        ),
      ),
    );
  }

  /// The event wizard, over everything, with its own state.
  void createEvent() {
    Navigator.of(context, rootNavigator: true)
        .push(
          MaterialPageRoute<void>(
            builder: (page) => BlocProvider(
              create: (_) => di.sl<InvitationCubit>(),
              child: InvitationWizardScreen(onComplete: () => Navigator.of(page).pop()),
            ),
          ),
        )
        // A new event (draft or active) shows without a manual refresh.
        .then((_) => mounted ? refreshEventLists(context) : null);
  }

  EventEntity? _knownEvent(String id) {
    try {
      for (final event in context.read<EventsListCubit>().state.events) {
        if (event.id == id) return event;
      }
    } catch (_) {}
    return null;
  }
}
