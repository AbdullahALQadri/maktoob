import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/utils/date_words.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/staff_entities.dart';
import '../../domain/usecases/staff_usecases.dart';
import '../cubit/staff_load_cubit.dart';
import 'staff_page.dart';

typedef _Events = StaffLoadCubit<List<StaffEventRow>>;

/// The events, newest date first (view only; changes are made on the web).
class StaffEventsView extends StatelessWidget {
  const StaffEventsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<_Events>(
      create: (_) => _Events(di.sl<GetStaffEventsUseCase>().call)..load(),
      child: const StaffEventsList(),
    );
  }
}

class StaffEventsList extends StatelessWidget {
  const StaffEventsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<_Events, StaffLoadState<List<StaffEventRow>>>(
      builder: (context, state) {
        final cubit = context.read<_Events>();
        return StaffPage<StaffEventRow>(
          state: state,
          onRefresh: cubit.load,
          rows: state.value ?? const [],
          emptyText: context.tr('staff_events_empty'),
          header: StaffSearchField(hint: context.tr('staff_events_search'), onSearch: cubit.load),
          rowBuilder: (context, event) => StaffRowCard(
            key: Key('staff_event_${event.id}'),
            title: event.title.isEmpty ? '#${event.id}' : event.title,
            lines: [
              event.clientName,
              [
                context.tr('staff_status_${event.status}'),
                if (event.date != null) context.eventDateLine(event.date!),
                context.tr('upgrade_invitations', {'count': event.invitationsCount}),
              ].join(' · '),
            ],
          ),
        );
      },
    );
  }
}
