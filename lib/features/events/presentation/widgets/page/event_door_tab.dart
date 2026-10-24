import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/locale/l10n_context.dart';
import '../../../../../core/design/window_size.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../injection_container.dart';
import '../../../../scanner/domain/entities/door_entities.dart';
import '../../../../scanner/presentation/cubit/scanner_cubit.dart';
import '../../../../scanner/presentation/screens/qr_scanner_screen.dart';
import '../../../domain/entities/event_entity.dart';
import 'event_page_parts.dart';

/// The door on the event day: who is in, and the scanner (it works without
/// internet and syncs later).
class EventDoorTab extends StatelessWidget {
  const EventDoorTab({super.key, required this.event});

  final EventEntity event;

  void _open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (page) => BlocProvider(
          create: (_) => sl<ScannerCubit>(),
          child: QRScannerScreen(
            session: DoorSession.client(int.tryParse(event.id) ?? 0, event.name),
            event: event,
            onBack: () => Navigator.of(page).pop(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gutter = context.pageGutter;
    final canScan = event.isActive && event.role.canScan;
    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(gutter, 16, gutter, 32),
      children: [
        EventPageCard(
          title: context.tr('event_door_title'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.tr('event_door_inside', {'in': event.checkedIn, 'expected': event.attendees}),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: context.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                context.tr('event_door_offline_note'),
                style: TextStyle(fontSize: 14, color: context.textSecondary, height: 1.5),
              ),
              if (canScan) ...[
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () => _open(context),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  label: Text(context.tr('event_door_open')),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
