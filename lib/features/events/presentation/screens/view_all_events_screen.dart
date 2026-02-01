import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/event_entity.dart';
import '../cubit/events_list/events_list_cubit.dart';
import '../cubit/events_list/events_list_state.dart';
import '../widgets/widgets.dart';
import 'event_details_screen.dart';

/// Screen to view all events with tabs for different statuses
class ViewAllEventsScreen extends StatelessWidget {
  const ViewAllEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<EventsListCubit>()..loadEvents(),
      child: const _ViewAllEventsContent(),
    );
  }
}

class _ViewAllEventsContent extends StatefulWidget {
  const _ViewAllEventsContent();

  @override
  State<_ViewAllEventsContent> createState() => _ViewAllEventsContentState();
}

class _ViewAllEventsContentState extends State<_ViewAllEventsContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.overlayBg,
      body: Column(
        children: [
          BlocBuilder<EventsListCubit, EventsListState>(
            buildWhen: (prev, curr) =>
                prev.activeEvents != curr.activeEvents ||
                prev.completedEvents != curr.completedEvents ||
                prev.draftEvents != curr.draftEvents,
            builder: (context, state) {
              return AllEventsHeader(
                title: t.translate('events_all_events'),
                tabController: _tabController,
                tabs: [
                  EventTabData(
                    label: t.translate('events_ongoing'),
                    count: state.activeEvents,
                    badgeColor: AppColors.green600,
                  ),
                  EventTabData(
                    label: t.translate('events_completed'),
                    count: state.completedEvents,
                    badgeColor: AppColors.blue500,
                  ),
                  EventTabData(
                    label: t.translate('events_draft'),
                    count: state.draftEvents,
                    badgeColor: AppColors.amber500,
                  ),
                ],
              );
            },
          ),
          Expanded(
            child: BlocBuilder<EventsListCubit, EventsListState>(
              buildWhen: (prev, curr) =>
                  prev.status != curr.status ||
                  prev.events != curr.events ||
                  prev.filteredEvents != curr.filteredEvents,
              builder: (context, state) {
                if (state.isLoading) {
                  return const _LoadingContent();
                }

                if (state.isFailure) {
                  return EventsErrorState(
                    message: state.errorMessage ?? '',
                    onRetry: () => context.read<EventsListCubit>().refreshEvents(),
                  );
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _EventsList(
                      events: state.events
                          .where((e) => e.status == EventStatus.active)
                          .toList(),
                      status: EventStatus.active,
                    ),
                    _EventsList(
                      events: state.events
                          .where((e) => e.status == EventStatus.completed)
                          .toList(),
                      status: EventStatus.completed,
                    ),
                    _EventsList(
                      events: state.events
                          .where((e) => e.status == EventStatus.draft)
                          .toList(),
                      status: EventStatus.draft,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EventsList extends StatelessWidget {
  final List<EventEntity> events;
  final EventStatus status;

  const _EventsList({required this.events, required this.status});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return EventsEmptyState(status: status);
    }

    return RefreshIndicator(
      onRefresh: () => context.read<EventsListCubit>().refreshEvents(),
      color: AppColors.primaryColor,
      child: ListView.builder(
        padding: EdgeInsets.all(context.dynamicWidth(0.04)),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return AllEventsCardWidget(
            event: event,
            index: index,
            onTap: () => _navigateToDetails(context, event),
          );
        },
      ),
    );
  }

  void _navigateToDetails(BuildContext context, EventEntity event) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EventDetailsScreen(
          eventId: event.id,
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}

class _LoadingContent extends StatelessWidget {
  const _LoadingContent();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      itemCount: 5,
      itemBuilder: (context, index) => const RecentEventCardSkeleton(),
    );
  }
}
