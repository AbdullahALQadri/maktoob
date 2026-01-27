import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';
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
    final t = AppLocalizations.of(context)!;
    AppSnackBar.showSuccess(
      context,
      message: '${guest.name} ${t.translate('scanner_success')}',
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
                      padding: EdgeInsets.all(15.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Stats Grid
                          _buildStatsGrid(state),
                          SizedBox(height: 24.h),

                          // Scan Button
                          ScanButtonWidget(
                            isScanning: state is Scanning,
                            scanAnimation: _scanAnimation,
                            onTap: _startScanning,
                          ),
                          SizedBox(height: 24.h),

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
    final t = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(15.w),
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
            blurRadius: 19.w,
            offset: Offset(0, 10.h),
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
                  width: 38.w,
                  height: 38.w,
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
                    size: 21.w,
                  ),
                ),
              ),
              SizedBox(width: 11.w),
              Text(
                t.translate('scanner_guest_scanner'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Event info row
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(9.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(15.w),
                ),
                child: Icon(
                  Icons.event,
                  color: Colors.white,
                  size: 26.w,
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (widget.event.description != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        widget.event.description!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12.sp,
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
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 11.w,
              vertical: 8.h,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8.w),
            ),
            child: Wrap(
              spacing: 15.w,
              runSpacing: 8.h,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 15.w,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      widget.event.venue,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12.sp,
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
                      size: 15.w,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '${widget.event.date} | ${widget.event.time}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12.sp,
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
    final t = AppLocalizations.of(context)!;
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
            t.translate('scanner_expected'),
            expectedGuests.toString(),
            Icons.people,
            Colors.blue,
          ),
        ),
        SizedBox(width: 11.w),
        Expanded(
          child: _buildStatCard(
            context,
            t.translate('scanner_checked_in'),
            checkedInGuests.toString(),
            Icons.check_circle,
            Colors.green,
          ),
        ),
        SizedBox(width: 11.w),
        Expanded(
          child: _buildStatCard(
            context,
            t.translate('scanner_pending'),
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
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.w),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 9.w,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(9.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 23.w),
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
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
