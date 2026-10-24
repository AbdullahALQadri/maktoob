import 'package:flutter/material.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/core.dart';
import '../../domain/entities/event_entity.dart';
import 'event_detail_section.dart';

/// What the occasion is about: the host's answers to its questions (groom,
/// bride, family…) and the description.
class EventOccasionCard extends StatelessWidget {
  final EventEntity event;

  const EventOccasionCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final answers = event.details?.occasionAnswers ?? const <OccasionAnswer>[];
    final description = (event.details?.description ?? event.description ?? '').trim();

    return EventDetailSection(
      icon: Icons.celebration_outlined,
      title: context.tr('event_details_occasion'),
      children: [
        for (final answer in answers)
          EventDetailRow(
            label: answer.label(context.languageCode),
            value: answer.value,
            trailing: answer.onInvitation ? const _OnInvitationTag() : null,
          ),
        if (description.isNotEmpty)
          EventDetailRow(label: context.tr('event_details_description'), value: description),
        if (answers.isEmpty && description.isEmpty)
          Text(
            context.tr('event_details_occasion_empty'),
            style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary),
          ),
      ],
    );
  }
}

/// "On the invitation": the answer is printed on the guests' invitation page too.
class _OnInvitationTag extends StatelessWidget {
  const _OnInvitationTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(color: context.primaryWash, borderRadius: AppSpacing.borderRadiusSm),
      child: Text(
        context.tr('event_details_on_invitation'),
        style: AppTextStyles.labelSmall.copyWith(color: context.primaryText),
      ),
    );
  }
}
