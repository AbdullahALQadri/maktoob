import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../domain/entities/door_entities.dart';
import '../cubit/door_status_cubit.dart';

/// "الجهاز الرئيسي للقاعة": this phone serves the other doors over the
/// venue's local network (its own hotspot, or the hall's Wi-Fi), so doors
/// with no internet still see each other's check-ins within a second or two
/// and a shared QR is refused at the second door. The other doors join by
/// scanning the QR shown here.
class DoorHubScreen extends StatefulWidget {
  const DoorHubScreen({super.key});

  @override
  State<DoorHubScreen> createState() => _DoorHubScreenState();
}

class _DoorHubScreenState extends State<DoorHubScreen> {
  String? _joinCode;
  bool _starting = true;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    // The hub must stay awake while the doors are open.
    WakelockPlus.enable().catchError((_) {});
    _start();
    // Joined phones come and go: keep the count fresh.
    _tick = Timer.periodic(const Duration(seconds: 4), (_) => context.read<DoorStatusCubit>().refresh());
  }

  Future<void> _start() async {
    final t = AppLocalizations.of(context)!;
    final code = await context.read<DoorStatusCubit>().startHub(
      notificationTitle: t.translate('door_hub_notification_title'),
      notificationText: t.translate('door_hub_notification_text'),
    );
    if (!mounted) return;
    setState(() {
      _joinCode = code;
      _starting = false;
    });
  }

  Future<void> _stop() async {
    await context.read<DoorStatusCubit>().stopHub();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _tick?.cancel();
    WakelockPlus.disable().catchError((_) {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.translate('door_hub_title'))),
      body: BlocBuilder<DoorStatusCubit, DoorStatus>(
        builder: (context, s) {
          if (_starting) return const Center(child: CircularProgressIndicator());
          final code = _joinCode;
          if (code == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                child: Text(t.translate('door_hub_failed'), textAlign: TextAlign.center),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
            children: [
              Text(t.translate('door_hub_desc'), style: const TextStyle(color: AppColors.gray700, height: 1.5)),
              AppSpacing.verticalSpace16,
              Center(
                child: Container(
                  padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: AppSpacing.borderRadiusLg,
                    border: Border.all(color: AppColors.gray200),
                  ),
                  child: QrImageView(
                    key: const Key('door_hub_qr'),
                    data: code,
                    size: 240,
                    errorCorrectionLevel: QrErrorCorrectLevel.M,
                  ),
                ),
              ),
              AppSpacing.verticalSpace16,
              _Line(
                icon: Icons.devices_other_outlined,
                text: t.translate('door_hub_peers').replaceAll('{count}', '${s.peers}'),
                strong: true,
              ),
              if (s.hubAddresses.isEmpty)
                _Line(icon: Icons.wifi_off, text: t.translate('door_hub_no_network'), color: AppColors.amber700)
              else
                _Line(icon: Icons.lan_outlined, text: s.hubAddresses.join('  ·  '), ltr: true),
              AppSpacing.verticalSpace12,
              for (final tip in [
                'door_hub_tip_hotspot',
                // Android keeps it running in the background; iOS cannot.
                Platform.isIOS ? 'door_hub_tip_ios' : 'door_hub_tip_background',
                'door_hub_tip_open',
                'door_hub_tip_internet',
              ])
                _Line(icon: Icons.info_outline, text: t.translate(tip)),
              AppSpacing.verticalSpace24,
              OutlinedButton.icon(
                key: const Key('door_hub_stop'),
                onPressed: _stop,
                icon: const Icon(Icons.stop_circle_outlined),
                label: Text(t.translate('door_hub_stop')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.red500,
                  side: const BorderSide(color: AppColors.red500),
                  padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpacing.smd),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final bool strong;
  final bool ltr;

  const _Line({
    required this.icon,
    required this.text,
    this.color = AppColors.gray700,
    this.strong = false,
    this.ltr = false,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: AppSpacing.iconMd, color: color),
        AppSpacing.horizontalSpace8,
        Expanded(
          child: Text(
            text,
            textDirection: ltr ? TextDirection.ltr : null,
            style: TextStyle(color: color, fontWeight: strong ? FontWeight.w700 : FontWeight.w400, height: 1.4),
          ),
        ),
      ],
    ),
  );
}
