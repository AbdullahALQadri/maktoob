import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../../injection_container.dart' as di;
import '../../../events/domain/entities/event_entity.dart';
import '../../data/door_engine.dart';
import '../../domain/entities/check_in_guest_entity.dart';
import '../../domain/entities/door_entities.dart';
import '../cubit/door_status_cubit.dart';
import '../cubit/scanner_cubit.dart';
import '../cubit/scanner_state.dart';
import '../widgets/door_status_bar.dart';
import '../widgets/door_texts.dart';
import '../widgets/widgets.dart';
import 'door_admin_screen.dart';
import 'door_hub_screen.dart';
import 'kiosk_scanner_screen.dart';
import 'qr_camera_screen.dart';

/// The door: scans, the guest list and the venue tools, for one event.
/// Works with no internet (the downloaded guest list) and syncs when it can.
class QRScannerScreen extends StatelessWidget {
  final DoorSession session;

  /// The host's event card, when opened from the events list.
  final EventEntity? event;
  final VoidCallback? onBack;

  /// Door-only mode (staff phone): offers "leave door mode" instead of back.
  final VoidCallback? onLeaveStaffMode;

  const QRScannerScreen({super.key, required this.session, this.event, this.onBack, this.onLeaveStaffMode});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DoorStatusCubit(controls: di.sl<DoorEngine>()),
      child: _QRScannerView(session: session, event: event, onBack: onBack, onLeaveStaffMode: onLeaveStaffMode),
    );
  }
}

class _QRScannerView extends StatefulWidget {
  final DoorSession session;
  final EventEntity? event;
  final VoidCallback? onBack;
  final VoidCallback? onLeaveStaffMode;

  const _QRScannerView({required this.session, this.event, this.onBack, this.onLeaveStaffMode});

  @override
  State<_QRScannerView> createState() => _QRScannerViewState();
}

enum _DoorAction { manage, hub, join, leaveHub, sync, leaveStaff }

class _QRScannerViewState extends State<_QRScannerView> with SingleTickerProviderStateMixin {
  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;
  bool _showGuestList = false;

  @override
  void initState() {
    super.initState();
    _scanAnimationController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    _scanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _scanAnimationController, curve: Curves.easeInOut));
    context.read<ScannerCubit>().openSession(widget.session);
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    super.dispose();
  }

  DoorStatus get _door => context.read<DoorStatusCubit>().state;

  void _startScanning() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => QRCameraScreen(onQRCodeScanned: _onQRCodeScanned)));
  }

  void _onQRCodeScanned(String qrCode) {
    _scanAnimationController.repeat();
    context.read<ScannerCubit>().processQRCode(qrCode);
  }

  void _stopScanAnimation() {
    _scanAnimationController.stop();
    _scanAnimationController.reset();
  }

  void _showGuestScannedDialog(CheckInGuestEntity guest, {bool manual = false}) {
    final cubit = context.read<ScannerCubit>();
    // Came in earlier today and the QR is still valid: let back in.
    if (guest.checkedIn && guest.canCheckIn) {
      _showReturning(guest);
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => GuestVerifiedDialog(
        guest: guest,
        gate: _door.gate,
        validOn: _door.event?.validOn,
        onClose: () {
          Navigator.of(dialogContext).pop();
          cubit.clearScannedGuest();
        },
        onCheckIn: (companions) {
          Navigator.of(dialogContext).pop();
          cubit.checkInGuest(guest.id, companions: companions, manual: manual);
        },
      ),
    );
  }

  void _showCheckInSuccessSnackBar(CheckInGuestEntity guest) {
    final t = AppLocalizations.of(context)!;
    AppSnackBar.showSuccess(context, message: '${guest.name} ${t.translate('scanner_success')}');
    if (guest.declinedRsvp) {
      AppSnackBar.showWarning(context, message: guest.warning ?? t.translate('scanner_declined_warning'));
    }
  }

  /// The guest came in earlier today (stepped out, came back): let back in,
  /// with when and where they first came in. Nothing is recorded again.
  void _showReturning(CheckInGuestEntity guest) {
    final cubit = context.read<ScannerCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => ReturningGuestDialog(
        guest: guest,
        onClose: () {
          Navigator.of(dialogContext).pop();
          cubit.clearScannedGuest();
        },
      ),
    );
  }

  Future<void> _onAction(_DoorAction action) async {
    final t = AppLocalizations.of(context)!;
    final status = context.read<DoorStatusCubit>();
    switch (action) {
      case _DoorAction.manage:
        await Navigator.of(context).push(MaterialPageRoute(builder: (_) => DoorAdminScreen(session: widget.session)));
        await status.syncNow();
      case _DoorAction.hub:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(value: status, child: const DoorHubScreen()),
          ),
        );
      case _DoorAction.join:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => QRCameraScreen(
              onQRCodeScanned: (code) async {
                final ok = await status.joinHub(code);
                if (!mounted) return;
                ok
                    ? AppSnackBar.showSuccess(context, message: t.translate('door_join_ok'))
                    : AppSnackBar.showError(context, message: t.translate('door_join_bad'));
              },
            ),
          ),
        );
      case _DoorAction.leaveHub:
        await status.leaveHub();
      case _DoorAction.sync:
        await status.syncNow();
      case _DoorAction.leaveStaff:
        widget.onLeaveStaffMode?.call();
    }
  }

  Widget _menu() {
    final t = AppLocalizations.of(context)!;
    return BlocBuilder<DoorStatusCubit, DoorStatus>(
      builder: (context, s) {
        final joined = s.session?.lanJoin != null;
        return PopupMenuButton<_DoorAction>(
          key: const Key('door_menu'),
          icon: const Icon(Icons.more_vert, color: AppColors.white),
          onSelected: _onAction,
          itemBuilder: (_) => [
            if (widget.session.kind == DoorSessionKind.client)
              PopupMenuItem(value: _DoorAction.manage, child: Text(t.translate('door_menu_manage'))),
            PopupMenuItem(
              value: _DoorAction.hub,
              enabled: s.hasPack,
              child: Text(t.translate(s.hubRunning ? 'door_menu_hub_running' : 'door_menu_hub')),
            ),
            if (widget.session.kind != DoorSessionKind.lan)
              PopupMenuItem(
                value: joined ? _DoorAction.leaveHub : _DoorAction.join,
                child: Text(t.translate(joined ? 'door_menu_leave_hub' : 'door_menu_join')),
              ),
            if (s.session?.hasServer ?? false)
              PopupMenuItem(value: _DoorAction.sync, child: Text(t.translate('door_menu_sync'))),
            if (widget.onLeaveStaffMode != null)
              PopupMenuItem(value: _DoorAction.leaveStaff, child: Text(t.translate('door_staff_leave'))),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    return BlocListener<ScannerCubit, ScannerState>(
      listener: _handleStateChange,
      child: Scaffold(
        backgroundColor: context.overlayBg,
        body: SafeArea(
          child: Column(
            children: [
              BlocBuilder<DoorStatusCubit, DoorStatus>(
                buildWhen: (a, b) => a.event != b.event || a.session?.eventTitle != b.session?.eventTitle,
                builder: (context, s) => event != null
                    ? ScannerHeader.forEvent(event, onBack: widget.onBack, menu: _menu())
                    : ScannerHeader(
                        title: s.event?.title ?? widget.session.eventTitle,
                        venue: s.event?.venueName,
                        when: s.event?.validOn,
                        onBack: widget.onBack,
                        menu: _menu(),
                      ),
              ),
              Expanded(
                child: BlocBuilder<ScannerCubit, ScannerState>(
                  builder: (context, state) {
                    return SingleChildScrollView(
                      padding: EdgeInsetsDirectional.all(context.dynamicWidth(0.04)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DoorStatusBar(onGateTap: () => showGatePicker(context)),
                          SizedBox(height: context.dynamicHeight(0.02)),
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
      padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
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
    final status = context.read<DoorStatusCubit>();
    setState(() => _kioskOn = true);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: cubit),
            BlocProvider.value(value: status),
          ],
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
    final t = AppLocalizations.of(context)!;
    if (state is GuestScanned) {
      _stopScanAnimation();
      _showGuestScannedDialog(state.guest);
    } else if (state is GuestCheckedIn) {
      // Another door had let them in first: they came back.
      state.guest.returning ? _showReturning(state.guest) : _showCheckInSuccessSnackBar(state.guest);
    } else if (state is ScannerError) {
      _stopScanAnimation();
      final text = state.code == null && state.message.isEmpty
          ? t.translate('door_reason_refused')
          : DoorTexts.reason(
              t,
              state.code,
              message: state.message,
              maxCompanions: state.maxCompanions,
              validOn: _door.event?.validOn,
            );
      AppSnackBar.showError(context, message: text);
    } else if (state is ScannerInitial) {
      _stopScanAnimation();
    }
  }

  Widget _buildStatsGrid(ScannerState state) {
    final view = state is GuestListView ? state : null;
    return ScannerStatsGrid(
      expectedGuests: view?.expectedGuests ?? 0,
      checkedInGuests: view?.checkedInGuests ?? 0,
      pendingGuests: view?.pendingGuests ?? 0,
    );
  }

  Widget _buildGuestListSection(ScannerState state) {
    final view = state is GuestListView ? state : null;
    return GuestListWidget(
      guests: view?.filteredGuests ?? const [],
      searchQuery: view?.searchQuery ?? '',
      isExpanded: _showGuestList,
      onSearchChanged: (query) => context.read<ScannerCubit>().updateSearchQuery(query),
      onToggle: () => setState(() => _showGuestList = !_showGuestList),
      // Picked by name (no QR shown): same dialog, recorded as manual.
      onCheckIn: (guest) => _showGuestScannedDialog(guest, manual: true),
    );
  }
}
