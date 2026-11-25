import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/staff_entities.dart';
import '../../domain/usecases/staff_usecases.dart';
import '../cubit/staff_load_cubit.dart';
import 'staff_page.dart';

typedef _Clients = StaffLoadCubit<List<StaffClientRow>>;

/// The clients, to look someone up (view only; changes are made on the web).
class StaffClientsView extends StatelessWidget {
  const StaffClientsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<_Clients>(
      create: (_) => _Clients(di.sl<GetStaffClientsUseCase>().call)..load(),
      child: const StaffClientsList(),
    );
  }
}

class StaffClientsList extends StatelessWidget {
  const StaffClientsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<_Clients, StaffLoadState<List<StaffClientRow>>>(
      builder: (context, state) {
        final cubit = context.read<_Clients>();
        return StaffPage<StaffClientRow>(
          state: state,
          onRefresh: cubit.load,
          rows: state.value ?? const [],
          emptyText: context.tr('staff_clients_empty'),
          header: StaffSearchField(hint: context.tr('staff_clients_search'), onSearch: cubit.load),
          rowBuilder: (context, client) => StaffRowCard(
            key: Key('staff_client_${client.id}'),
            title: client.name,
            lines: [
              client.phone,
              [
                context.tr(client.isInstitution ? 'staff_client_institution' : 'staff_client_individual'),
                context.tr(client.isVerified ? 'staff_client_verified' : 'staff_client_unverified'),
                if (!client.isActive) context.tr('staff_client_inactive'),
                context.tr('staff_client_events', {'count': client.eventsCount}),
              ].join(' · '),
            ],
          ),
        );
      },
    );
  }
}
