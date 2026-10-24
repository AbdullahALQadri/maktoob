import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../domain/entities/door_entities.dart';
import '../cubit/door_status_cubit.dart';
import '../cubit/scanner_cubit.dart';
import '../cubit/scanner_state.dart';
import '../widgets/door_texts.dart';

/// Self-service door ("وضع الجهاز الذاتي"): a device at the entrance with no
/// staff. Every scan checks the guest in immediately, shows a full-screen
/// green welcome or red refusal, then returns to scanning after ~3 seconds.
/// Leaving requires a long-press on the lock button plus a confirmation.
class KioskScannerScreen extends StatefulWidget {
  const KioskScannerScreen({super.key});

  @override
  State<KioskScannerScreen> createState() => _KioskScannerScreenState();
}

class _KioskScannerScreenState extends State<KioskScannerScreen> {
  static const _resultDuration = Duration(seconds: 3);

  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _busy = false;
  KioskResult? _result;
  Timer? _resetTimer;

  @override
  void initState() {
    super.initState();
    // A door device must never dim or lock while guests are arriving.
    WakelockPlus.enable().catchError((_) {});
  }

  @override
  void dispose() {
    WakelockPlus.disable().catchError((_) {});
    _resetTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_busy) return;
    String? raw;
    for (final b in capture.barcodes) {
      final v = b.rawValue;
      if (v != null && v.isNotEmpty) {
        raw = v;
        break;
      }
    }
    if (raw == null) return;
    setState(() => _busy = true);
    context.read<ScannerCubit>().kioskScan(raw);
  }

  void _onState(BuildContext context, ScannerState state) {
    if (state is! KioskResult) return;
    if (state.admitted) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 200), HapticFeedback.heavyImpact);
    }
    setState(() => _result = state);
    _resetTimer?.cancel();
    _resetTimer = Timer(_resultDuration, () {
      if (!mounted) return;
      setState(() {
        _result = null;
        _busy = false;
      });
    });
  }

  Future<void> _confirmExit() async {
    final t = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.translate('kiosk_exit_title')),
        content: Text(t.translate('kiosk_exit_confirm')),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(t.translate('common_cancel'))),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(t.translate('kiosk_exit_action'))),
        ],
      ),
    );
    if (ok == true && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return PopScope(
      // Guests must not be able to leave kiosk mode with the back button.
      canPop: false,
      child: BlocListener<ScannerCubit, ScannerState>(
        listener: _onState,
        child: Scaffold(
          backgroundColor: AppColors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              MobileScanner(controller: _controller, onDetect: _onDetect),
              if (_result == null) _buildIdle(t),
              if (_result != null) _buildResult(t, _result!),
              _buildExitButton(t),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdle(AppLocalizations t) {
    return Align(
      alignment: AlignmentDirectional.bottomCenter,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.xxxxxl, start: AppSpacing.lg, end: AppSpacing.lg),
        child: Container(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.black.withValues(alpha: 0.6),
            borderRadius: AppSpacing.borderRadiusMd,
          ),
          child: Text(
            _busy ? t.translate('kiosk_checking') : t.translate('kiosk_idle_hint'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  DoorGate? get _gate => _doorStatus?.gate;
  String? get _validOn => _doorStatus?.event?.validOn;

  /// The door status, when the kiosk was opened from the door screen.
  DoorStatus? get _doorStatus {
    try {
      return context.read<DoorStatusCubit>().state;
    } catch (_) {
      return null;
    }
  }

  Widget _buildResult(AppLocalizations t, KioskResult r) {
    final String title;
    final List<String> lines;
    if (r.admitted && r.returning) {
      // Came in earlier today (here, at another door, or through the hub).
      final at = r.checkedInAt;
      title = r.name.isEmpty
          ? t.translate('kiosk_welcome_back_guest')
          : t.translate('kiosk_welcome_back').replaceAll('{name}', r.name);
      lines = [if (at != null) t.translate('door_returning_first').replaceAll('{time}', DoorTexts.hhmm(at))];
    } else if (r.admitted) {
      title = r.name.isEmpty
          ? t.translate('kiosk_welcome_guest')
          : t.translate('kiosk_welcome').replaceAll('{name}', r.name);
      lines = [
        if (r.companions > 0) t.translate('kiosk_companions').replaceAll('{count}', '${r.companions}'),
        // Staff near the door see why to look twice (wrong gate, declined).
        for (final w in r.warnings) DoorTexts.warning(t, w, gate: _gate),
      ];
    } else {
      title = t.translate('scanner_cannot_check_in');
      lines = [if (r.name.isNotEmpty) r.name, DoorTexts.reason(t, r.code, message: r.message, validOn: _validOn)];
    }

    return Container(
      color: r.admitted ? AppColors.green600 : AppColors.red500,
      padding: const EdgeInsetsDirectional.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(r.admitted ? Icons.check_circle_outline : Icons.block, color: AppColors.white, size: 120),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.white, fontSize: 34, fontWeight: FontWeight.bold),
          ),
          for (final line in lines) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              line,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExitButton(AppLocalizations t) {
    return SafeArea(
      child: Align(
        alignment: AlignmentDirectional.topEnd,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(AppSpacing.md),
          child: Tooltip(
            message: t.translate('kiosk_exit_hint'),
            child: GestureDetector(
              // Long-press only: a tap does nothing, so guests can't exit by accident.
              onLongPress: _confirmExit,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: AppColors.black.withValues(alpha: 0.4), shape: BoxShape.circle),
                child: const Icon(Icons.lock_outline, color: AppColors.white, size: 22),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
