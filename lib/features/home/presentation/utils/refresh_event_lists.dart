import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../events/presentation/cubit/events_list/events_list_cubit.dart';
import '../../../events/presentation/cubit/my_events/my_events_cubit.dart';
import '../cubit/home_cubit.dart';

/// Reload the home dashboard and the "my events" list. Call it when the user
/// returns from the event wizard or finishes payment, so a newly created /
/// activated event appears without a manual pull-to-refresh.
///
/// Both cubits are app-level providers; a missing one (tests, isolated
/// screens) is ignored.
void refreshEventLists(BuildContext context) {
  if (!context.mounted) return;
  try {
    context.read<HomeCubit>().load();
  } catch (_) {}
  try {
    context.read<EventsListCubit>().refreshEvents();
  } catch (_) {}
  try {
    context.read<MyEventsCubit>().refresh();
  } catch (_) {}
}
