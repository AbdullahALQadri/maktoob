import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/locale/l10n_context.dart';
import '../../../../../core/design/window_size.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/date_words.dart';
import '../../../domain/entities/event_entity.dart';
import '../../../domain/entities/event_follow_up.dart';
import '../../cubit/event_details/event_details_state.dart';
import '../../cubit/event_follow_up/event_follow_up_cubit.dart';
import '../event_add_ons_card.dart';
import 'event_page_actions.dart';
import 'event_page_parts.dart';
import 'event_replies_summary.dart';
import 'event_summary_card.dart';

/// Overview of a live event: who replied, how the invitations went out, the
/// latest activity, extra services, and changing the date or place.
class EventOverviewTab extends StatelessWidget {
  const EventOverviewTab({super.key, required this.state, this.withSummary = false});

  final EventDetailsState state;

  /// Phones open the overview with the event's summary (wide windows show
  /// it above all tabs).
  final bool withSummary;

  @override
  Widget build(BuildContext context) {
    final event = state.event!;
    final followUp = context.watch<EventFollowUpCubit>().state;
    final gutter = context.pageGutter;
    const gap = SizedBox(height: 16);
    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(gutter, 16, gutter, 32),
      children: [
        if (withSummary) ...[
          EventSummaryCard(event: event),
          if (event.role != EventRole.owner) ...[const SizedBox(height: 12), EventRoleBanner(role: event.role)],
          gap,
        ],
        EventRepliesSummary(event: event),
        gap,
        EventJourney(
          guests: state.guests,
          resending: followUp.resending,
          onResendFailed: event.canManageGuests
              ? () => context.read<EventFollowUpCubit>().resendFailed(event.id)
              : null,
        ),
        gap,
        EventPageCard(
          title: context.tr('event_page_activity'),
          child: followUp.activity.isEmpty
              ? Text(
                  context.tr(
                    event.invitationsSentAt == null ? 'event_page_activity_before' : 'event_page_activity_waiting',
                  ),
                  style: TextStyle(fontSize: 14, color: context.textSecondary, height: 1.5),
                )
              : Column(children: [for (final item in followUp.activity) _ActivityRow(item: item)]),
        ),
        if (event.isActive && event.role.canManage) ...[gap, EventAddOnsCard(event: event)],
        if (event.role.canManage && !event.isInactive) ...[
          gap,
          Material(
            color: context.cardBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: context.borderColor),
            ),
            child: ListTile(
              leading: Icon(Icons.edit_calendar_outlined, color: context.iconSecondary),
              title: Text(context.tr('event_page_change')),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => EventPageActions.edit(context, event),
            ),
          ),
        ],
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.item});

  final ActivityItem item;

  @override
  Widget build(BuildContext context) {
    final (icon, color, key) = switch (item.reply) {
      'attending' => (
        Icons.check_rounded,
        AppColors.green800,
        item.companions > 0 ? 'event_activity_attending_with' : 'event_activity_attending',
      ),
      'not_attending' => (Icons.close_rounded, context.textSecondary, 'event_activity_declined'),
      'maybe' => (Icons.help_outline_rounded, AppColors.amber700, 'event_activity_maybe'),
      _ => (Icons.drafts_outlined, context.primaryText, 'event_activity_opened'),
    };
    final at = item.at;
    return Container(
      constraints: const BoxConstraints(minHeight: 46),
      padding: const EdgeInsetsDirectional.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.tr(key, {'name': item.name, 'count': item.companions}),
              style: TextStyle(fontSize: 14, color: context.textPrimary),
            ),
          ),
          if (at != null) Text(context.clockTime(at), style: TextStyle(fontSize: 12, color: context.textSecondary)),
        ],
      ),
    );
  }
}
