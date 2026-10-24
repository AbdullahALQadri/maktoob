import 'package:flutter/material.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/core.dart';
import '../../domain/entities/event_entity.dart';
import 'event_detail_section.dart';

/// The texts guests read (invitation, the reply after accepting or
/// apologising, thank-you…). Texts the host left empty use the default.
class EventMessagesCard extends StatelessWidget {
  final EventEntity event;

  const EventMessagesCard({super.key, required this.event});

  static const _known = {'invitation', 'acceptance', 'refusal', 'ask_reason_prompt', 'ask_reason_question', 'thank_you'};

  @override
  Widget build(BuildContext context) {
    final messages = event.details?.messages ?? const <GuestMessage>[];

    return EventDetailSection(
      icon: Icons.chat_bubble_outline,
      title: context.tr('event_details_messages'),
      children: [
        for (final message in messages)
          EventDetailRow(
            label: _known.contains(message.key) ? context.tr('event_details_message_${message.key}') : message.key,
            value: message.text(context.languageCode),
          ),
        if (messages.isEmpty)
          Text(
            context.tr('event_details_messages_default'),
            style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary),
          ),
      ],
    );
  }
}
