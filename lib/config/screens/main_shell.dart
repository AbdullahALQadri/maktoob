import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/app_colors.dart';
import '../../core/widgets/bottom_navigation.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/events/presentation/screens/event_details_screen.dart';
import '../../features/scanner/presentation/screens/qr_scanner_screen.dart';
import '../../features/payment/presentation/screens/payment_upload_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/invitation/presentation/cubit/invitation_cubit.dart';
import '../../features/invitation/presentation/screens/invitation_wizard_screen.dart';
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

  void _onEventCreated(String eventId) {
    setState(() {
      _selectedEventId = eventId;
      _showPaymentUpload = true;
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
        return const QRScannerScreen();
      case 2:
        return const SettingsScreen();
      default:
        return HomeScreen(onViewEvent: _onViewEvent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray100,
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildCurrentScreen(),
      ),
      bottomNavigationBar: (_showEventDetails || _showPaymentUpload)
          ? null
          : BottomNavigation(
              currentIndex: _currentIndex,
              onTap: _onNavigationTap,
              onAddTap: _onAddEventTap,
            ),
    );
  }
}
