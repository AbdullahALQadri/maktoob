import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/design/window_size.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/loading/mk_spinner.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/staff_entities.dart';
import '../../domain/usecases/staff_usecases.dart';
import '../cubit/staff_load_cubit.dart';
import '../screens/staff_identity_screens.dart';
import '../screens/staff_institution_screens.dart';
import 'staff_page.dart';

/// "Today": what is waiting for this member, queue by queue.
class StaffTodayView extends StatelessWidget {
  const StaffTodayView({super.key, required this.onOpenPayments, this.cubit});

  final VoidCallback onOpenPayments;

  /// Given in tests; otherwise the view makes and loads its own.
  final StaffLoadCubit<StaffToday>? cubit;

  @override
  Widget build(BuildContext context) {
    final given = cubit;
    return given != null
        ? BlocProvider.value(value: given, child: _Today(onOpenPayments: onOpenPayments))
        : BlocProvider(
            create: (_) => StaffLoadCubit<StaffToday>((_) => di.sl<GetStaffTodayUseCase>()(const NoParams()))..load(),
            child: _Today(onOpenPayments: onOpenPayments),
          );
  }
}

class _Today extends StatelessWidget {
  const _Today({required this.onOpenPayments});

  final VoidCallback onOpenPayments;

  /// Opens a queue and counts again when staff come back from it.
  Future<void> _open(BuildContext context, Route<void> route) async {
    final cubit = context.read<StaffLoadCubit<StaffToday>>();
    await Navigator.of(context).push(route);
    await cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    final gutter = context.pageGutter;
    return BlocBuilder<StaffLoadCubit<StaffToday>, StaffLoadState<StaffToday>>(
      builder: (context, state) {
        final cubit = context.read<StaffLoadCubit<StaffToday>>();
        final today = state.value;
        if (today == null) {
          return state.loading
              ? const Center(child: MkSpinner())
              : StaffNotice(text: state.error ?? '', onRetry: cubit.load);
        }
        // A queue this member may not review is not shown at all.
        final tiles = [
          if (today.paymentRequestsPending != null)
            _Tile('staff_today_payments', today.paymentRequestsPending!, Icons.receipt_long_outlined, onOpenPayments),
          if (today.identitiesPending != null)
            _Tile(
              'staff_today_identities',
              today.identitiesPending!,
              Icons.badge_outlined,
              () => _open(context, StaffIdentitiesScreen.route()),
            ),
          if (today.institutionsPending != null)
            _Tile(
              'staff_today_institutions',
              today.institutionsPending!,
              Icons.business_outlined,
              () => _open(context, StaffInstitutionsScreen.route()),
            ),
          if (today.eventsToday != null) _Tile('staff_today_events', today.eventsToday!, Icons.celebration_outlined, null),
          if (today.eventsAwaitingPayment != null)
            _Tile('staff_today_unpaid', today.eventsAwaitingPayment!, Icons.hourglass_top_outlined, null),
        ];
        return RefreshIndicator(
          onRefresh: cubit.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsetsDirectional.fromSTEB(gutter, 16, gutter, 32),
            children: [
              if (tiles.isEmpty) StaffNotice(text: context.tr('staff_today_nothing')),
              Wrap(spacing: 10, runSpacing: 10, children: tiles),
            ],
          ),
        );
      },
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.labelKey, this.count, this.icon, this.onTap);

  final String labelKey;
  final int count;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final waiting = count > 0;
    return InkWell(
      key: Key(labelKey),
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: context.windowSize.isCompact ? double.infinity : 260,
        constraints: const BoxConstraints(minHeight: 72),
        padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: waiting ? AppColors.primaryColor : context.borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: waiting ? context.primaryText : context.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.tr(labelKey),
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: context.textPrimary),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: waiting ? context.primaryText : context.textSecondary,
              ),
            ),
            if (onTap != null) Icon(Icons.chevron_right, color: context.textSecondary),
          ],
        ),
      ),
    );
  }
}
