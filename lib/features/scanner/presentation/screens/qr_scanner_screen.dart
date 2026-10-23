import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../events/domain/entities/event_entity.dart';
import '../../domain/entities/check_in_guest_entity.dart';
import '../cubit/scanner_cubit.dart';
import '../cubit/scanner_state.dart';
import '../widgets/widgets.dart';
import 'kiosk_scanner_screen.dart';
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
  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;
  bool _showGuestList = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    context.read<ScannerCubit>()
      ..setEvent(int.tryParse(widget.event.id))
      ..loadGuestList();
  }

  void _setupAnimations() {
    _scanAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    super.dispose();
  }

  void _startScanning() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QRCameraScreen(onQRCodeScanned: _onQRCodeScanned),
      ),
    );
  }

  void _onQRCodeScanned(String qrCode) {
    _scanAnimationController.repeat();
    context.read<ScannerCubit>().processQRCode(qrCode);
  }

  void _stopScanAnimation() {
    _scanAnimationController.stop();
    _scanAnimationController.reset();
  }

  void _showGuestScannedDialog(CheckInGuestEntity guest) {
    if (guest.checkedIn) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AccessDeniedDialog(
          guest: guest,
          onClose: () {
            Navigator.of(dialogContext).pop();
            context.read<ScannerCubit>().clearScannedGuest();
          },
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => GuestVerifiedDialog(
          guest: guest,
          onClose: () {
            Navigator.of(dialogContext).pop();
            context.read<ScannerCubit>().clearScannedGuest();
          },
          onCheckIn: (companions) {
            Navigator.of(dialogContext).pop();
            context.read<ScannerCubit>().checkInGuest(guest.id, companions: companions);
          },
        ),
      );
    }
  }

  void _showCheckInSuccessSnackBar(CheckInGuestEntity guest) {
    final t = AppLocalizations.of(context)!;
    AppSnackBar.showSuccess(context, message: '${guest.name} ${t.translate('scanner_success')}');
    // Declined RSVP: checked in anyway, but tell the host.
    final warning = guest.warning;
    if (guest.declinedRsvp && warning != null) {
      AppSnackBar.showWarning(context, message: warning);
    }
  }

  /// 409: the guest already came in ("دخل مسبقاً"), with the time if known.
  void _showAlreadyCheckedIn(CheckInGuestEntity guest) {
    showDialog(
      context: context,
      builder: (dialogContext) => AccessDeniedDialog(
        guest: guest,
        onClose: () {
          Navigator.of(dialogContext).pop();
          context.read<ScannerCubit>().clearScannedGuest();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScannerCubit, ScannerState>(
      listener: _handleStateChange,
      child: Scaffold(
        backgroundColor: context.overlayBg,
        body: SafeArea(
          child: Column(
            children: [
              ScannerHeader(event: widget.event, onBack: widget.onBack),
              Expanded(
                child: BlocBuilder<ScannerCubit, ScannerState>(
                  builder: (context, state) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildStatsGrid(state),
                          SizedBox(height: context.dynamicHeight(0.03)),
                          ScanButtonWidget(
                            isScanning: state is Scanning,
                            scanAnimation: _scanAnimation,
                            onTap: _startScanning,
                          ),
                          SizedBox(height: context.dynamicHeight(0.02)),
                          _buildKioskToggle(),
                          SizedBox(height: context.dynamicHeight(0.03)),
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

  bool _kioskOn = false;

  /// "وضع الجهاز الذاتي": opens the unattended door screen. The switch stays
  /// on while it is open and turns off when staff exit it (long-press + confirm).
  Widget _buildKioskToggle() {
    final t = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.gray200, width: 1),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsetsDirectional.zero,
        value: _kioskOn,
        activeTrackColor: AppColors.primaryColor,
        title: Text(t.translate('kiosk_mode')),
        subtitle: Text(t.translate('kiosk_mode_desc')),
        onChanged: (on) => on ? _openKiosk() : null,
      ),
    );
  }

  Future<void> _openKiosk() async {
    final cubit = context.read<ScannerCubit>();
    setState(() => _kioskOn = true);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: const KioskScannerScreen(),
        ),
      ),
    );
    if (!mounted) return;
    setState(() => _kioskOn = false);
    cubit.clearScannedGuest();
    cubit.loadGuestList();
  }

  void _handleStateChange(BuildContext context, ScannerState state) {
    if (state is GuestScanned) {
      _stopScanAnimation();
      _showGuestScannedDialog(state.guest);
    } else if (state is GuestCheckedIn) {
      _showCheckInSuccessSnackBar(state.guest);
    } else if (state is GuestAlreadyCheckedIn) {
      _stopScanAnimation();
      _showAlreadyCheckedIn(state.guest);
    } else if (state is ScannerError) {
      _stopScanAnimation();
      AppSnackBar.showError(context, message: state.message);
    } else if (state is ScannerInitial) {
      _stopScanAnimation();
    }
  }

  Widget _buildStatsGrid(ScannerState state) {
    final (expected, checkedIn, pending) = _extractStats(state);
    return ScannerStatsGrid(
      expectedGuests: expected,
      checkedInGuests: checkedIn,
      pendingGuests: pending,
    );
  }

  (int, int, int) _extractStats(ScannerState state) {
    return switch (state) {
      ScannerInitial(:final expectedGuests, :final checkedInGuests, :final pendingGuests) =>
        (expectedGuests, checkedInGuests, pendingGuests),
      Scanning(:final expectedGuests, :final checkedInGuests, :final pendingGuests) =>
        (expectedGuests, checkedInGuests, pendingGuests),
      GuestScanned(:final expectedGuests, :final checkedInGuests, :final pendingGuests) =>
        (expectedGuests, checkedInGuests, pendingGuests),
      GuestCheckedIn(:final expectedGuests, :final checkedInGuests, :final pendingGuests) =>
        (expectedGuests, checkedInGuests, pendingGuests),
      ScannerError(:final expectedGuests, :final checkedInGuests, :final pendingGuests) =>
        (expectedGuests, checkedInGuests, pendingGuests),
      _ => (0, 0, 0),
    };
  }

  Widget _buildGuestListSection(ScannerState state) {
    final (guests, searchQuery) = _extractGuestData(state);
    return GuestListWidget(
      guests: guests,
      searchQuery: searchQuery,
      isExpanded: _showGuestList,
      onSearchChanged: (query) => context.read<ScannerCubit>().updateSearchQuery(query),
      onToggle: () => setState(() => _showGuestList = !_showGuestList),
      onCheckIn: (guest) => context.read<ScannerCubit>().checkInGuest(guest.id),
    );
  }

  (List<CheckInGuestEntity>, String) _extractGuestData(ScannerState state) {
    return switch (state) {
      ScannerInitial(:final filteredGuests, :final searchQuery) => (filteredGuests, searchQuery),
      Scanning(:final filteredGuests, :final searchQuery) => (filteredGuests, searchQuery),
      GuestScanned(:final filteredGuests, :final searchQuery) => (filteredGuests, searchQuery),
      GuestCheckedIn(:final filteredGuests, :final searchQuery) => (filteredGuests, searchQuery),
      ScannerError(:final filteredGuests, :final searchQuery) => (filteredGuests, searchQuery),
      _ => (<CheckInGuestEntity>[], ''),
    };
  }
}
