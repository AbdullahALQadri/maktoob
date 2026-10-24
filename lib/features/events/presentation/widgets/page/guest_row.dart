import 'package:flutter/material.dart';

import '../../../../../config/locale/l10n_context.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../domain/entities/guest_entity.dart';

/// Which list a guest belongs to on the guests tab.
enum GuestFilter { all, attending, pending, declined, failed }

extension GuestFilterOf on GuestEntity {
  bool get notDelivered => invitationStatus == 'failed';

  /// Not sent yet: name and number can still be fixed.
  bool get unsent => sentAt == null && (invitationStatus ?? 'pending') == 'pending';

  bool matches(GuestFilter filter) => switch (filter) {
    GuestFilter.all => true,
    GuestFilter.failed => notDelivered,
    GuestFilter.attending => status == GuestStatus.attending,
    GuestFilter.declined => status == GuestStatus.declined,
    GuestFilter.pending => status == GuestStatus.pending && !notDelivered,
  };
}

/// One guest: initial, name, number, where their invitation stands, and a
/// menu (resend, fix before sending, remove). Tapping opens the timeline.
class GuestRow extends StatelessWidget {
  const GuestRow({super.key, required this.guest, required this.onOpen, this.onResend, this.onFix, this.onRemove});

  final GuestEntity guest;
  final VoidCallback onOpen;
  final VoidCallback? onResend;
  final VoidCallback? onFix;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = guest.notDelivered
        ? (context.tr('event_page_failed'), AppColors.red100, AppColors.red500)
        : switch (guest.status) {
            GuestStatus.attending => (
              guest.companions > 0
                  ? '${context.tr('event_page_attending')} +${guest.companions}'
                  : context.tr('event_page_attending'),
              AppColors.green100,
              AppColors.green800,
            ),
            GuestStatus.declined => (context.tr('event_page_declined'), context.chipBg, context.textTertiary),
            GuestStatus.pending => (
              context.tr(guest.unsent ? 'event_page_not_sent' : 'event_page_no_reply'),
              AppColors.amber100,
              AppColors.amber700,
            ),
          };
    final actions = <(String, VoidCallback)>[
      if (onFix != null && guest.unsent) ('event_page_fix_guest', onFix!),
      if (onResend != null && !guest.unsent) ('event_page_resend', onResend!),
      if (onRemove != null) ('common_delete', onRemove!),
    ];
    return Material(
      color: context.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 4, 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.navy50,
                child: Text(
                  guest.name.isEmpty ? '؟' : guest.name.characters.first,
                  style: const TextStyle(color: AppColors.tertiaryColor, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guest.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary),
                    ),
                    Text(
                      guest.phone,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(fontSize: 12, color: context.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
                child: Text(
                  label,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg),
                ),
              ),
              if (actions.isNotEmpty)
                PopupMenuButton<int>(
                  tooltip: context.tr('event_page_guest_options'),
                  itemBuilder: (_) => [
                    for (var i = 0; i < actions.length; i++)
                      PopupMenuItem(value: i, child: Text(context.tr(actions[i].$1))),
                  ],
                  onSelected: (i) => actions[i].$2(),
                )
              else
                const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}
