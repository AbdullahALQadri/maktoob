import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/staff_entities.dart';
import '../../domain/usecases/staff_usecases.dart';
import '../cubit/staff_load_cubit.dart';
import '../screens/staff_request_screen.dart';
import 'staff_page.dart';

typedef _Requests = StaffLoadCubit<List<StaffPaymentRequest>>;

/// The payment requests waiting for review, oldest decision first to make.
class StaffRequestsView extends StatelessWidget {
  const StaffRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<_Requests>(
      create: (_) => _Requests((_) => di.sl<GetStaffPaymentRequestsUseCase>()(const NoParams()))..load(),
      child: const StaffRequestsList(),
    );
  }
}

class StaffRequestsList extends StatelessWidget {
  const StaffRequestsList({super.key});

  Future<void> _open(BuildContext context, StaffPaymentRequest request) async {
    final cubit = context.read<_Requests>();
    await Navigator.of(context).push(StaffRequestScreen.route(request.id));
    // A reviewed request leaves the queue.
    await cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    final ils = context.tr('currency_ils');
    return BlocBuilder<_Requests, StaffLoadState<List<StaffPaymentRequest>>>(
      builder: (context, state) => StaffPage<StaffPaymentRequest>(
        state: state,
        onRefresh: context.read<_Requests>().load,
        rows: state.value ?? const [],
        emptyText: context.tr('staff_requests_empty'),
        rowBuilder: (context, request) => StaffRowCard(
          key: Key('staff_request_${request.id}'),
          title: request.clientName ?? '#${request.id}',
          lines: [
            request.eventTitle,
            [
              context.tr(request.isUpgrade ? 'staff_kind_upgrade' : 'staff_kind_payment'),
              if (request.method != null) context.tr('staff_method_${request.method}'),
            ].join(' · '),
          ],
          trailing: Text(
            '${request.amount.toStringAsFixed(2)} $ils',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: context.textPrimary),
          ),
          onTap: () => _open(context, request),
        ),
      ),
    );
  }
}
