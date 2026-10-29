import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../injection_container.dart' as di;
import '../../data/datasources/door_store.dart';
import '../../data/door_session_manager.dart';
import '../../domain/entities/door_entities.dart';
import '../cubit/scanner_cubit.dart';
import 'qr_scanner_screen.dart';

/// Door-only mode: a staff phone (door code, scanner account, or joined to
/// the venue hub) that only scans for one event. Survives app restarts; the
/// staff leave it from the door menu.
class DoorStaffShell extends StatelessWidget {
  final DoorSession session;
  final VoidCallback onLeft;

  const DoorStaffShell({super.key, required this.session, required this.onLeft});

  Future<void> _leave(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final pending = await di.sl<DoorStore>().pendingCount(session.eventId);
    if (!context.mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(t.translate('door_staff_leave')),
        content: Text(
          pending > 0
              ? t.translate('door_staff_leave_pending').replaceAll('{count}', '$pending')
              : t.translate('door_staff_leave_confirm'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialog).pop(false), child: Text(t.translate('common_cancel'))),
          TextButton(onPressed: () => Navigator.of(dialog).pop(true), child: Text(t.translate('common_confirm'))),
        ],
      ),
    );
    if (ok != true) return;
    await di.sl<DoorSessionManager>().leaveStaffMode(session);
    onLeft();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ScannerCubit>(),
      child: Builder(
        builder: (context) => QRScannerScreen(session: session, onLeaveStaffMode: () => _leave(context)),
      ),
    );
  }
}
