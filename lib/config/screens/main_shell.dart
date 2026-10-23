import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/fcm_service.dart';

import '../../core/utils/app_colors.dart';
import '../../core/widgets/adaptive_bottom_navigation_bar.dart';
import '../locale/app_localizations.dart';
import '../../features/events/domain/entities/event_entity.dart';
import '../../features/events/presentation/cubit/events_list/events_list_cubit.dart';
import '../../features/events/presentation/screens/event_details_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/utils/refresh_event_lists.dart';
import '../../features/invitation/presentation/cubit/invitation_cubit.dart';
import '../../features/invitation/presentation/screens/invitation_wizard_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/payment/presentation/screens/payment_upload_screen.dart';
import '../../features/scanner/presentation/cubit/scanner_cubit.dart';
import '../../features/scanner/presentation/screens/qr_scanner_screen.dart';
import '../../features/scanner/presentation/screens/scanner_events_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../injection_container.dart' as di;

/// Main shell widget that contains all screens with bottom navigation.
/// This acts as the root container for the app's main content.
/// Navigation: Home (0) -> Scanner (1) -> Settings (2)
/// Add Event opens as a new screen via Navigator.push
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  String? _selectedEventId;
  bool _showEventDetails = false;
  bool _showPaymentUpload = false;

  // Scanner state
  EventEntity? _selectedScannerEvent;
  bool _showScannerScreen = false;

  StreamSubscription<Map<String, dynamic>>? _pushSub;
  StreamSubscription<Map<String, dynamic>>? _tapSub;

  @override
  void initState() {
    super.initState();
    final fcm = di.sl<FcmService>();
    _pushSub = fcm.messageStream.listen(_onPush);
    _tapSub = fcm.tapStream.listen(_onPushTap);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final launch = fcm.takeLaunchTap();
      if (launch != null) _onPushTap(launch);
    });
  }

  @override
  void dispose() {
    _pushSub?.cancel();
    _tapSub?.cancel();
    super.dispose();
  }

  /// An event changed on the server (activated by the team, payment
  /// confirmed/rejected...): refresh the lists so its status is current.
  void _onPush(Map<String, dynamic> data) {
    final type = data['type']?.toString() ?? '';
    if (!mounted) return;
    if (type.startsWith('event.') || type.startsWith('payment')) {
      refreshEventLists(context);
    }
  }

  /// The user tapped a notification: open the event it is about, otherwise
  /// the notifications inbox.
  void _onPushTap(Map<String, dynamic> data) {
    if (!mounted) return;
    final type = data['type']?.toString() ?? '';
    final eventId = data['event_id']?.toString() ?? '';
    if (type.startsWith('image.') || type.startsWith('prompt.')) return;
    if (type.startsWith('event.') && eventId.isNotEmpty) {
      _onViewEvent(eventId);
      return;
    }
    NotificationsScreen.open(context, onOpenEvent: _onViewEvent);
  }

  void _onNavigationTap(int index) {
    setState(() {
      _currentIndex = index;
      _showEventDetails = false;
      _showPaymentUpload = false;
      // Reset scanner state when navigating away
      if (index != 1) {
        _selectedScannerEvent = null;
        _showScannerScreen = false;
      }
    });
  }

  void _onViewEvent(String eventId) {
    // Door staff of an institution may only scan: open the scanner instead of
    // the details screen (which the backend would refuse with 403).
    EventEntity? known;
    try {
      for (final e in context.read<EventsListCubit>().state.events) {
        if (e.id == eventId) known = e;
      }
    } catch (_) {}
    if (known != null && known.role.isScannerOnly) {
      setState(() {
        _currentIndex = 1;
        _selectedScannerEvent = known;
        _showScannerScreen = true;
      });
      return;
    }
    setState(() {
      _selectedEventId = eventId;
      _showEventDetails = true;
    });
  }

  void _onBackFromDetails() {
    setState(() {
      _showEventDetails = false;
      _selectedEventId = null;
    });
  }

  void _onPaymentComplete() {
    setState(() {
      _showPaymentUpload = false;
      _selectedEventId = null;
      _currentIndex = 0; // Go back to home
    });
    refreshEventLists(context);
  }

  void _onAddEventTap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (_) => di.sl<InvitationCubit>(),
          child: InvitationWizardScreen(
            onComplete: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    ).then((_) {
      // New event (draft or active) must show on home without manual refresh.
      if (mounted) refreshEventLists(context);
    });
  }

  void _onScannerEventSelected(EventEntity event) {
    setState(() {
      _selectedScannerEvent = event;
      _showScannerScreen = true;
    });
  }

  void _onBackFromScanner() {
    setState(() {
      _selectedScannerEvent = null;
      _showScannerScreen = false;
    });
  }

  Widget _buildCurrentScreen() {
    // Handle sub-screens first
    if (_showEventDetails && _selectedEventId != null) {
      return EventDetailsScreen(
        eventId: _selectedEventId!,
        onBack: _onBackFromDetails,
      );
    }

    if (_showPaymentUpload) {
      return PaymentUploadScreen(
        eventId: _selectedEventId,
        onComplete: _onPaymentComplete,
      );
    }

    // Main navigation screens
    // 0: Home, 1: Scanner, 2: Settings
    switch (_currentIndex) {
      case 0:
        return HomeScreen(onViewEvent: _onViewEvent);
      case 1:
        // Scanner flow: show events list first, then scanner when event is selected
        if (_showScannerScreen && _selectedScannerEvent != null) {
          return BlocProvider(
            create: (_) => di.sl<ScannerCubit>(),
            child: QRScannerScreen(
              event: _selectedScannerEvent!,
              onBack: _onBackFromScanner,
            ),
          );
        }
        return ScannerEventsScreen(
          onEventSelected: _onScannerEventSelected,
        );
      case 2:
        return const SettingsScreen();
      default:
        return HomeScreen(onViewEvent: _onViewEvent);
    }
  }

  List<AdaptiveNavItem> _buildNavItems(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return [
      AdaptiveNavItem(
        label: t.translate('nav_home'),
        icon: Icons.grid_view_outlined,
        activeIcon: Icons.grid_view_rounded,
      ),
      AdaptiveNavItem(
        label: t.translate('nav_scanner'),
        icon: Icons.crop_free_outlined,
        activeIcon: Icons.crop_free_rounded,
      ),
      AdaptiveNavItem(
        label: t.translate('nav_settings'),
        icon: Icons.bookmark_border_outlined,
        activeIcon: Icons.bookmark,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.overlayBg,
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildCurrentScreen(),
      ),
      bottomNavigationBar: (_showEventDetails || _showPaymentUpload || _showScannerScreen)
          ? null
          : AdaptiveBottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onNavigationTap,
              items: _buildNavItems(context),
              onAddTap: _onAddEventTap,
              showAddButton: true,
            ),
    );
  }
}
