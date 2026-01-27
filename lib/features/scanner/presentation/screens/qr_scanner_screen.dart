import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/media_query_values.dart';
import '../../../../core/widgets/snackbar/app_snackbar.dart';
import '../../../events/domain/entities/event_entity.dart';
import '../../domain/entities/check_in_guest_entity.dart';
import '../cubit/scanner_cubit.dart';
import '../cubit/scanner_state.dart';
import '../widgets/access_denied_dialog.dart';
import '../widgets/guest_list_widget.dart';
import '../widgets/guest_verified_dialog.dart';
import '../widgets/scan_button_widget.dart';
import 'qr_camera_screen.dart';

class QRScannerScreen extends StatefulWidget {
  final EventEntity event;
  final VoidCallback? onBack;

  const QRScannerScreen({
    super.key,
    required this.event,
    this.onBack,
  });

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
    // Open the QR camera screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QRCameraScreen(
          onQRCodeScanned: (qrCode) {
            // Process the scanned QR code
            _onQRCodeScanned(qrCode);
          },
        ),
      ),
    );
  }

  void _onQRCodeScanned(String qrCode) {
    // Start the animation and process the QR code
    _scanAnimationController.repeat();
    context.read<ScannerCubit>().processQRCode(qrCode);
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
    AppSnackBar.showSuccess(
      context,
      message: '${guest.name} checked in successfully!',
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
          AppSnackBar.showError(
            context,
            message: state.message,
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
                      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Stats Grid
                          _buildStatsGrid(state),
                          SizedBox(height: context.dynamicHeight(0.03)),

                          // Scan Button
                          ScanButtonWidget(
                            isScanning: state is Scanning,
                            scanAnimation: _scanAnimation,
                            onTap: _startScanning,
                          ),
                          SizedBox(height: context.dynamicHeight(0.03)),

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
    final l = AppLocalizations.of(context);
    final isArabic = !(l?.isEnLocale ?? true);

    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            AppColors.tertiaryColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.4),
            blurRadius: context.dynamicWidth(0.05),
            offset: Offset(0, context.dynamicHeight(0.012)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button row
          Row(
            children: [
              GestureDetector(
                onTap: widget.onBack,
                child: Container(
                  width: context.dynamicWidth(0.1),
                  height: context.dynamicWidth(0.1),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: context.dynamicWidth(0.055),
                  ),
                ),
              ),
              SizedBox(width: context.dynamicWidth(0.03)),
              Text(
                isArabic ? 'ماسح الضيوف' : 'Guest Scanner',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.dynamicWidth(0.045),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: context.dynamicHeight(0.02)),
          // Event info row
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.dynamicWidth(0.025)),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
                ),
                child: Icon(
                  Icons.event,
                  color: Colors.white,
                  size: context.dynamicWidth(0.07),
                ),
              ),
              SizedBox(width: context.dynamicWidth(0.04)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.dynamicWidth(0.05),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (widget.event.description != null) ...[
                      SizedBox(height: context.dynamicHeight(0.005)),
                      Text(
                        widget.event.description!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: context.dynamicWidth(0.032),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.dynamicHeight(0.015)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.dynamicWidth(0.03),
              vertical: context.dynamicHeight(0.01),
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(context.dynamicWidth(0.02)),
            ),
            child: Wrap(
              spacing: context.dynamicWidth(0.04),
              runSpacing: context.dynamicHeight(0.01),
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: context.dynamicWidth(0.04),
                    ),
                    SizedBox(width: context.dynamicWidth(0.015)),
                    Text(
                      widget.event.venue,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: context.dynamicWidth(0.033),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: context.dynamicWidth(0.04),
                    ),
                    SizedBox(width: context.dynamicWidth(0.015)),
                    Text(
                      '${widget.event.date} | ${widget.event.time}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: context.dynamicWidth(0.033),
                      ),
                    ),
                  ],
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
            context,
            'Expected',
            expectedGuests.toString(),
            Icons.people,
            Colors.blue,
          ),
        ),
        SizedBox(width: context.dynamicWidth(0.03)),
        Expanded(
          child: _buildStatCard(
            context,
            'Checked In',
            checkedInGuests.toString(),
            Icons.check_circle,
            Colors.green,
          ),
        ),
        SizedBox(width: context.dynamicWidth(0.03)),
        Expanded(
          child: _buildStatCard(
            context,
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
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: context.dynamicWidth(0.025),
            offset: Offset(0, context.dynamicHeight(0.005)),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(context.dynamicWidth(0.025)),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: context.dynamicWidth(0.06)),
          ),
          SizedBox(height: context.dynamicHeight(0.015)),
          Text(
            value,
            style: TextStyle(
              fontSize: context.dynamicWidth(0.07),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: context.dynamicHeight(0.005)),
          Text(
            label,
            style: TextStyle(
              fontSize: context.dynamicWidth(0.03),
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
