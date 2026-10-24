import 'package:flutter/material.dart';

import '../../../../../config/locale/l10n_context.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../domain/entities/event_entity.dart';
import '../../../domain/entities/guest_entity.dart';
import 'event_page_parts.dart';

/// "182 of 240 replied": attending (with companions), declined, no reply.
class EventRepliesSummary extends StatelessWidget {
  const EventRepliesSummary({super.key, required this.event});

  final EventEntity event;

  @override
  Widget build(BuildContext context) {
    final total = event.invitations;
    final share = total == 0 ? 0.0 : event.responses / total;
    final companions = (event.attendees - event.attending).clamp(0, 1 << 20);
    Widget part(int value, Color color) => Expanded(
      flex: value,
      child: ColoredBox(color: color),
    );
    return EventPageCard(
      title: context.tr('event_page_replies'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${context.tr('event_page_replied_of', {'done': event.responses, 'total': total})} · ${(share * 100).round()}%',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: context.textPrimary),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: SizedBox(
              height: 10,
              child: total == 0
                  ? ColoredBox(color: context.chipBg)
                  : Row(
                      children: [
                        if (event.attending > 0) part(event.attending, AppColors.green600),
                        if (event.declined > 0) part(event.declined, AppColors.gray400),
                        if (total - event.responses > 0) part(total - event.responses, context.chipBg),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 10),
          _Line(
            Icons.check_rounded,
            AppColors.green800,
            companions > 0
                ? context.tr('event_page_attending_with', {'count': companions})
                : context.tr('event_page_attending'),
            event.attending,
          ),
          _Line(Icons.close_rounded, context.textSecondary, context.tr('event_page_declined'), event.declined),
          _Line(
            Icons.schedule_rounded,
            AppColors.amber700,
            context.tr('event_page_no_reply'),
            (total - event.responses).clamp(0, total),
          ),
        ],
      ),
    );
  }
}

/// Sent → opened → replied → at the door, and a one-tap resend of what did
/// not arrive.
class EventJourney extends StatelessWidget {
  const EventJourney({super.key, required this.guests, required this.onResendFailed, this.resending = false});

  final List<GuestEntity> guests;

  /// Null when the host may not resend (read-only roles).
  final VoidCallback? onResendFailed;
  final bool resending;

  @override
  Widget build(BuildContext context) {
    final failed = guests.where((g) => g.invitationStatus == 'failed').length;
    final steps = [
      (
        'event_page_sent',
        guests.where((g) => g.sentAt != null || (g.invitationStatus ?? 'pending') != 'pending').length,
      ),
      ('event_page_opened', guests.where((g) => g.openedAt != null).length),
      ('event_page_replied', guests.where((g) => g.status != GuestStatus.pending).length),
      ('event_page_checked_in', guests.where((g) => g.isCheckedIn).length),
    ];
    return EventPageCard(
      title: context.tr('event_page_journey'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              for (var i = 0; i < steps.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsetsDirectional.symmetric(vertical: 10, horizontal: 4),
                    decoration: BoxDecoration(color: context.scaffoldBg, borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        Text(
                          '${steps[i].$2}',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: context.textPrimary),
                        ),
                        Text(
                          context.tr(steps[i].$1),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: TextStyle(fontSize: 12, color: context.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (failed > 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsetsDirectional.fromSTEB(12, 6, 6, 6),
              decoration: BoxDecoration(color: AppColors.red100, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      context.tr('event_page_not_delivered', {'count': failed}),
                      style: const TextStyle(fontSize: 14, color: AppColors.red500),
                    ),
                  ),
                  if (onResendFailed != null)
                    TextButton(
                      onPressed: resending ? null : onResendFailed,
                      style: TextButton.styleFrom(foregroundColor: AppColors.red500),
                      child: Text(context.tr('event_page_resend_them')),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.icon, this.color, this.label, this.value);

  final IconData icon;
  final Color color;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 14, color: context.textPrimary)),
          ),
          Text(
            '$value',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimary),
          ),
        ],
      ),
    );
  }
}
