import 'package:flutter/material.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/utils/date_words.dart';
import '../../domain/entities/event_entity.dart';
import 'event_detail_section.dart';

/// How guests answer and how the invitations go out, as the host set them.
class EventRepliesCard extends StatelessWidget {
  final EventEntity event;

  const EventRepliesCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final d = event.details;
    final replies = d?.replies ??
        EventReplySettings(
          allowCompanions: event.allowCompanions,
          maxCompanions: event.allowCompanions ? event.maxCompanions : 0,
          responseDeadline: event.rsvpDeadline,
        );
    final deadline = replies.responseDeadline;
    final sentAt = d?.invitationsSentAt ?? event.invitationsSentAt?.toLocal();
    String yesNo(bool value) => context.tr(value ? 'common_yes' : 'common_no');

    return EventDetailSection(
      icon: Icons.how_to_reg_outlined,
      title: context.tr('event_details_replies'),
      children: [
        EventDetailRow(label: context.tr('event_details_rsvp_required'), value: yesNo(replies.requireResponse)),
        EventDetailRow(
          label: context.tr('event_details_rsvp_deadline'),
          value: deadline == null ? null : '${deadline.day} ${context.monthName(deadline)} ${deadline.year}',
        ),
        EventDetailRow(label: context.tr('event_details_companions_rule'), value: _companions(context, replies)),
        if (d != null) EventDetailRow(label: context.tr('event_details_ask_reason'), value: yesNo(replies.askReason)),
        if (d?.deliveryMethod != null)
          EventDetailRow(label: context.tr('event_send_channel'), value: context.tr('channel_${d!.deliveryMethod}')),
        // The first "send to all"; single sends show in the overview's counts.
        if (sentAt != null)
          EventDetailRow(label: context.tr('event_details_sent_at'), value: context.eventDateLine(sentAt)),
      ],
    );
  }

  String _companions(BuildContext context, EventReplySettings replies) {
    final max = replies.maxCompanions;
    if (!replies.allowCompanions || max == 0) return context.tr('event_details_companions_none');
    if (max == null) return context.tr('event_details_companions_no_limit');
    return context.tr('event_details_companions_up_to', {'count': max});
  }
}
