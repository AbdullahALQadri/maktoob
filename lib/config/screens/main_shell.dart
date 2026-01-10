import 'package:flutter/material.dart';

import '../../core/utils/app_colors.dart';
import '../../core/widgets/bottom_navigation.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/events/presentation/screens/events_screen.dart';
import '../../features/events/presentation/screens/create_event_screen.dart';
import '../../features/events/presentation/screens/event_details_screen.dart';
import '../../features/venues/presentation/screens/venue_screen.dart';
import '../../features/scanner/presentation/screens/qr_scanner_screen.dart';
import '../../features/payment/presentation/screens/payment_upload_screen.dart';

/// Main shell widget that contains all screens with bottom navigation.
/// This acts as the root container for the app's main content.
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

  void _onNavigationTap(int index) {
    setState(() {
      _currentIndex = index;
      _showEventDetails = false;
      _showPaymentUpload = false;
    });
  }

  void _onViewEvent(String eventId) {
    setState(() {
      _selectedEventId = eventId;
      _showEventDetails = true;
    });
  }

  void _onUploadPayment(String eventId) {
    setState(() {
      _selectedEventId = eventId;
      _showPaymentUpload = true;
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
      _currentIndex = 1; // Go back to events
    });
  }

  void _onEventCreated(String eventId) {
    setState(() {
      _selectedEventId = eventId;
      _showPaymentUpload = true;
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
    switch (_currentIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return EventsScreen(
          onViewEvent: _onViewEvent,
          onUploadPayment: _onUploadPayment,
        );
      case 2:
        return CreateEventScreen(
          onComplete: _onEventCreated,
        );
      case 3:
        return const VenueScreen();
      case 4:
        return const QRScannerScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildCurrentScreen(),
      ),
      bottomNavigationBar: (_showEventDetails || _showPaymentUpload)
          ? null
          : BottomNavigation(
              currentIndex: _currentIndex,
              onTap: _onNavigationTap,
            ),
    );
  }
}
