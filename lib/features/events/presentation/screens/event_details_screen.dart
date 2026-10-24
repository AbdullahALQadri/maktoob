import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/core.dart';
import '../../../../core/design/window_size.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/event_entity.dart';
import '../cubit/event_details/event_details_cubit.dart';
import '../cubit/event_details/event_details_state.dart';
import '../cubit/event_follow_up/event_follow_up_cubit.dart';
import '../widgets/page/event_details_tab.dart';
import '../widgets/page/event_door_tab.dart';
import '../widgets/page/event_guests_tab.dart';
import '../widgets/page/event_overview_tab.dart';
import '../widgets/page/event_page_actions.dart';
import '../widgets/page/event_page_parts.dart';
import '../widgets/page/event_setup_view.dart';
import '../widgets/page/event_summary_card.dart';

/// One event. A draft or an event awaiting payment shows what is left to do;
/// a live one has Overview · Guests · Door · Details, opening on the door on
/// the event day. Wide windows keep the guest list beside the other tabs.
class EventDetailsScreen extends StatefulWidget {
  const EventDetailsScreen({super.key, required this.eventId, required this.onBack});

  final String eventId;
  final VoidCallback onBack;

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late final EventFollowUpCubit _followUp = sl<EventFollowUpCubit>()..load(widget.eventId);

  @override
  void initState() {
    super.initState();
    context.read<EventDetailsCubit>().loadEventDetails(widget.eventId);
  }

  @override
  void dispose() {
    _followUp.close();
    super.dispose();
  }

  Future<void> _reload() async {
    await context.read<EventDetailsCubit>().refreshEventDetails();
    await _followUp.load(widget.eventId);
  }

  /// Our own messages are translation keys; the server's are already text.
  void _say(String message, {required bool error, int count = 0}) {
    final text = message.startsWith('event_') ? context.tr(message, {'count': count}) : message;
    error ? AppSnackBar.showError(context, message: text) : AppSnackBar.showSuccess(context, message: text);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _followUp,
      child: MultiBlocListener(
        listeners: [
          BlocListener<EventDetailsCubit, EventDetailsState>(
            listenWhen: (a, b) =>
                (b.notice != null && b.notice != a.notice) ||
                (b.errorMessage != null && b.errorMessage != a.errorMessage),
            listener: (_, s) => s.notice != null
                ? _say(s.notice!, error: false, count: s.noticeCount)
                : _say(s.errorMessage!, error: true),
          ),
          BlocListener<EventFollowUpCubit, EventFollowUpState>(
            listenWhen: (a, b) => b.message != null && b != a,
            listener: (_, s) {
              _say(s.message!, error: s.messageIsError, count: s.messageCount);
              if (!s.messageIsError) context.read<EventDetailsCubit>().refreshEventDetails();
            },
          ),
        ],
        child: BlocBuilder<EventDetailsCubit, EventDetailsState>(
          builder: (context, state) => Scaffold(
            backgroundColor: context.scaffoldBg,
            appBar: EventPageTopBar(event: state.hasEvent ? state.event : null, onBack: widget.onBack),
            body: _body(state),
          ),
        ),
      ),
    );
  }

  Widget _body(EventDetailsState state) {
    if (state.isLoading) return const EventDetailsSkeleton();
    if (state.isFailure || !state.hasEvent) {
      return EventLoadError(onRetry: () => context.read<EventDetailsCubit>().loadEventDetails(widget.eventId));
    }
    final event = state.event!;
    if (event.status == EventStatus.draft || event.status == EventStatus.pendingPayment) {
      return BlocBuilder<EventFollowUpCubit, EventFollowUpState>(
        builder: (_, followUp) => EventSetupView(
          event: event,
          progress: followUp.progress,
          paymentUnderReview: state.hasPendingPayment,
          onPaid: _reload,
        ),
      );
    }
    return _LiveEvent(state: state);
  }
}

class _LiveEvent extends StatelessWidget {
  const _LiveEvent({required this.state});

  final EventDetailsState state;

  @override
  Widget build(BuildContext context) {
    final event = state.event!;
    final wide = context.windowSize.atLeastExpanded;
    final eventDay = event.isActive && EventSummaryCard.daysLeft(event) == 0;
    // The tabs stay under the top bar, reachable on any phone at any text
    // size; on phones the summary opens the overview instead of pushing the
    // tabs down.
    final tabs = [
      ('event_tab_overview', EventOverviewTab(state: state, withSummary: !wide)),
      if (!wide) ('event_tab_guests', EventGuestsTab(state: state)),
      ('event_tab_door', EventDoorTab(event: event)),
      ('event_tab_details', EventDetailsTabView(event: event)),
    ];
    final initial = eventDay ? tabs.indexWhere((t) => t.$1 == 'event_tab_door') : 0;
    final gutter = context.pageGutter;

    final tabbed = DefaultTabController(
      length: tabs.length,
      initialIndex: initial,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              for (final tab in tabs)
                Tab(
                  text: tab.$1 == 'event_tab_guests'
                      ? '${context.tr(tab.$1)} ${state.guests.length}'
                      : context.tr(tab.$1),
                ),
            ],
          ),
          Expanded(child: TabBarView(children: [for (final tab in tabs) tab.$2])),
        ],
      ),
    );
    if (!wide) return tabbed;

    // Wide windows: the summary on top, the guest list always in view.
    return Column(
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(gutter, 8, gutter, 8),
          child: Column(
            children: [
              EventSummaryCard(event: event),
              if (event.role != EventRole.owner) ...[const SizedBox(height: 12), EventRoleBanner(role: event.role)],
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: gutter - 24 > 0 ? gutter - 24 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: tabbed),
                VerticalDivider(width: 1, color: context.dividerColor),
                Expanded(flex: 3, child: EventGuestsTab(state: state)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
