import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../core/services/fcm_service.dart';
import '../../features/home/presentation/utils/refresh_event_lists.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/payment/presentation/screens/my_payments_screen.dart';
import '../../injection_container.dart' as di;
import 'app_shell.dart';
import 'shell_tab.dart';

/// Push notifications while the shell is open. The app re-fetches over HTTP
/// and never trusts the push body.
mixin ShellPushHandling on State<AppShell> {
  StreamSubscription<Map<String, dynamic>>? _pushes;
  StreamSubscription<Map<String, dynamic>>? _taps;

  void openEvent(String id);

  Future<T?> openIn<T>(ShellTab tab, WidgetBuilder page);

  /// "My payments" (receipts, what is due), inside the account tab.
  void openMyPayments() => openIn<void>(ShellTab.account, (_) => MyPaymentsScreen.provided());

  void listenToPushes() {
    final fcm = di.sl<FcmService>();
    _pushes = fcm.messageStream.listen(_onPush);
    _taps = fcm.tapStream.listen(_onTap);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final launch = fcm.takeLaunchTap();
      if (launch != null) _onTap(launch);
    });
  }

  void stopListeningToPushes() {
    _pushes?.cancel();
    _taps?.cancel();
  }

  /// An event changed on the server (activated by the team, payment
  /// confirmed or rejected): refresh the lists so its status is current.
  void _onPush(Map<String, dynamic> data) {
    final type = data['type']?.toString() ?? '';
    if (mounted && (type.startsWith('event.') || type.startsWith('payment'))) refreshEventLists(context);
  }

  /// A tapped notification opens its event, otherwise the inbox. Design
  /// notifications belong to the wizard, which listens itself.
  void _onTap(Map<String, dynamic> data) {
    if (!mounted) return;
    final type = data['type']?.toString() ?? '';
    final eventId = data['event_id']?.toString() ?? '';
    if (type.startsWith('image.') || type.startsWith('prompt.')) return;
    if (type.startsWith('event.') && eventId.isNotEmpty) return openEvent(eventId);
    // A confirmed payment opens its receipt list; a payment due, its event.
    if (type == 'payment.received') return openMyPayments();
    if (type == 'payment.due' && eventId.isNotEmpty) return openEvent(eventId);
    NotificationsScreen.open(context, onOpenEvent: openEvent);
  }
}
