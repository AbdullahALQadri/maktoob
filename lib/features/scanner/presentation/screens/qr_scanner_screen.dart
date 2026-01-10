import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/check_in_guest_entity.dart';
import '../cubit/scanner_cubit.dart';
import '../cubit/scanner_state.dart';
import '../widgets/access_denied_dialog.dart';
import '../widgets/guest_list_widget.dart';
import '../widgets/guest_verified_dialog.dart';
import '../widgets/scan_button_widget.dart';

// Event model for header display
class _Event {
  final String name;
  final String venue;
  final String date;
  final String time;
  final String description;

  const _Event({
    required this.name,
    required this.venue,
    required this.date,
    required this.time,
    required this.description,
  });
}

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with SingleTickerProviderStateMixin {
  // Animation controller for scanning effect
  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;

  // UI state for guest list expansion
  bool _showGuestList = false;

  // Mock Event Data
  final _Event _event = const _Event(
    name: 'Tech Summit 2024',
    venue: 'Grand Convention Center',
    date: 'March 15, 2024',
    time: '9:00 AM - 6:00 PM',
    description: 'Annual technology conference featuring industry leaders',
  );

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    // Load guest list on init
    context.read<ScannerCubit>().loadGuestList();
  }

  void _setupAnimations() {
    _scanAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scanAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    super.dispose();
  }

  void _startScanning() {
    _scanAnimationController.repeat();
    context.read<ScannerCubit>().startScanning();
  }

  void _stopScanAnimation() {
    _scanAnimationController.stop();
    _scanAnimationController.reset();
  }

  void _showGuestScannedDialog(CheckInGuestEntity guest) {
    if (guest.checkedIn) {
      // Show access denied dialog for already checked-in guests
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AccessDeniedDialog(
            guest: guest,
            onClose: () {
              Navigator.of(dialogContext).pop();
              context.read<ScannerCubit>().clearScannedGuest();
            },
          );
        },
      );
    } else {
      // Show verified dialog for new guests
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return GuestVerifiedDialog(
            guest: guest,
            onClose: () {
              Navigator.of(dialogContext).pop();
              context.read<ScannerCubit>().clearScannedGuest();
            },
            onCheckIn: () {
              Navigator.of(dialogContext).pop();
              context.read<ScannerCubit>().checkInGuest(guest.id);
            },
          );
        },
      );
    }
  }

  void _showCheckInSuccessSnackBar(CheckInGuestEntity guest) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${guest.name} checked in successfully!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScannerCubit, ScannerState>(
      listener: (context, state) {
        if (state is GuestScanned) {
          _stopScanAnimation();
          _showGuestScannedDialog(state.guest);
        } else if (state is GuestCheckedIn) {
          _showCheckInSuccessSnackBar(state.guest);
        } else if (state is ScannerError) {
          _stopScanAnimation();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else if (state is ScannerInitial) {
          _stopScanAnimation();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: SafeArea(
          child: Column(
            children: [
              // Gradient Header
              _buildGradientHeader(),

              // Main Content
              Expanded(
                child: BlocBuilder<ScannerCubit, ScannerState>(
                  builder: (context, state) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Stats Grid
                          _buildStatsGrid(state),
                          const SizedBox(height: 24),

                          // Scan Button
                          ScanButtonWidget(
                            isScanning: state is Scanning,
                            scanAnimation: _scanAnimation,
                            onTap: _startScanning,
                          ),
                          const SizedBox(height: 24),

                          // Guest List
                          _buildGuestListSection(state),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366F1), // Indigo
            Color(0xFFEC4899), // Pink
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.event,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _event.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _event.description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  _event.venue,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.calendar_today,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_event.date} | ${_event.time}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(ScannerState state) {
    int expectedGuests = 0;
    int checkedInGuests = 0;
    int pendingGuests = 0;

    if (state is ScannerInitial) {
      expectedGuests = state.expectedGuests;
      checkedInGuests = state.checkedInGuests;
      pendingGuests = state.pendingGuests;
    } else if (state is Scanning) {
      expectedGuests = state.expectedGuests;
      checkedInGuests = state.checkedInGuests;
      pendingGuests = state.pendingGuests;
    } else if (state is GuestScanned) {
      expectedGuests = state.expectedGuests;
      checkedInGuests = state.checkedInGuests;
      pendingGuests = state.pendingGuests;
    } else if (state is GuestCheckedIn) {
      expectedGuests = state.expectedGuests;
      checkedInGuests = state.checkedInGuests;
      pendingGuests = state.pendingGuests;
    } else if (state is ScannerError) {
      expectedGuests = state.expectedGuests;
      checkedInGuests = state.checkedInGuests;
      pendingGuests = state.pendingGuests;
    }

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Expected',
            expectedGuests.toString(),
            Icons.people,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Checked In',
            checkedInGuests.toString(),
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Pending',
            pendingGuests.toString(),
            Icons.pending,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestListSection(ScannerState state) {
    List<CheckInGuestEntity> filteredGuests = [];
    String searchQuery = '';

    if (state is ScannerInitial) {
      filteredGuests = state.filteredGuests;
      searchQuery = state.searchQuery;
    } else if (state is Scanning) {
      filteredGuests = state.filteredGuests;
      searchQuery = state.searchQuery;
    } else if (state is GuestScanned) {
      filteredGuests = state.filteredGuests;
      searchQuery = state.searchQuery;
    } else if (state is GuestCheckedIn) {
      filteredGuests = state.filteredGuests;
      searchQuery = state.searchQuery;
    } else if (state is ScannerError) {
      filteredGuests = state.filteredGuests;
      searchQuery = state.searchQuery;
    }

    return GuestListWidget(
      guests: filteredGuests,
      searchQuery: searchQuery,
      isExpanded: _showGuestList,
      onSearchChanged: (query) {
        context.read<ScannerCubit>().updateSearchQuery(query);
      },
      onToggle: () {
        setState(() {
          _showGuestList = !_showGuestList;
        });
      },
      onCheckIn: (guest) {
        context.read<ScannerCubit>().checkInGuest(guest.id);
      },
    );
  }
}
