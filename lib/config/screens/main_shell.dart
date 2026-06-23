import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/fcm_service.dart';
import '../../core/utils/app_colors.dart';
import '../../core/widgets/adaptive_bottom_navigation_bar.dart';
import '../locale/app_localizations.dart';
import '../../features/events/domain/entities/event_entity.dart';
import '../../features/events/presentation/screens/event_details_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/invitation/presentation/cubit/invitation_cubit.dart';
import '../../features/invitation/presentation/screens/invitation_wizard_screen.dart';
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

  // Owner notifications (e.g. a guest replied via WhatsApp) arrive on the
  // shared FCM message stream; we surface them as an in-app snackbar.
  StreamSubscription<Map<String, dynamic>>? _fcmSub;

  @override
  void initState() {
    super.initState();
    if (di.sl.isRegistered<FcmService>()) {
      _fcmSub = di.sl<FcmService>().messageStream.listen(_onFcmMessage);
    }
  }

  @override
  void dispose() {
    _fcmSub?.cancel();
    super.dispose();
  }

  void _onFcmMessage(Map<String, dynamic> data) {
    if (!mounted) return;
    if (data['type']?.toString() != 'guest.responded') return;

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final name = (data['guest_name'] ?? '').toString();
    final statusText = _rsvpText(data['response_status']?.toString(), isArabic);
    final msg = isArabic
        ? 'رد جديد: $name${statusText.isNotEmpty ? ' — $statusText' : ''}'
        : 'New RSVP: $name${statusText.isNotEmpty ? ' — $statusText' : ''}';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  String _rsvpText(String? status, bool isArabic) {
    switch (status) {
      case 'attending':
        return isArabic ? 'سيحضر' : 'Attending';
      case 'not_attending':
        return isArabic ? 'لن يحضر' : 'Not attending';
      case 'maybe':
        return isArabic ? 'ربما' : 'Maybe';
      default:
        return '';
    }
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
    );
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
