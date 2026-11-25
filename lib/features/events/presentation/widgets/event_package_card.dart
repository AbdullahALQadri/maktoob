import 'package:flutter/material.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../payment/presentation/screens/upgrade_screen.dart';
import '../../domain/entities/event_entity.dart';
import 'event_detail_section.dart';

/// The package, the invitations used out of the allowance, and the money
/// (invoice total and what was paid, in ₪).
class EventPackageCard extends StatelessWidget {
  final EventEntity event;

  /// Called after a payment for more invitations was sent.
  final VoidCallback? onUpgraded;

  const EventPackageCard({super.key, required this.event, this.onUpgraded});

  Future<void> _upgrade(BuildContext context) async {
    final sent = await Navigator.of(context).push(UpgradeScreen.route(eventId: event.id, eventTitle: event.name));
    if (sent == true) onUpgraded?.call();
  }

  @override
  Widget build(BuildContext context) {
    final b = event.details?.billing;
    final limit = b?.invitationLimit ?? event.invitationLimit;
    final used = b?.invitationsUsed ?? (limit == null ? null : limit - (event.remainingInvitations ?? limit));
    final total = b?.total ?? event.invoiceTotal;
    final ils = context.tr('currency_ils');
    final package = b?.customPackage == true
        ? context.tr('invitation_custom_package_info_title')
        : (b?.packageName(context.languageCode) ?? event.packageName);

    return EventDetailSection(
      icon: Icons.workspace_premium_outlined,
      title: context.tr('event_details_package'),
      children: [
        EventDetailRow(label: context.tr('event_details_package_name'), value: package),
        EventDetailRow(
          label: context.tr('event_details_invitations_used'),
          value: limit == null
              ? '${used ?? 0} · ${context.tr('invitation_unlimited')}'
              : '${used ?? 0} / $limit',
        ),
        if (b?.invoiceNumber != null)
          EventDetailRow(label: context.tr('invitation_invoice_number'), value: b!.invoiceNumber),
        if (total != null)
          EventDetailRow(label: context.tr('event_details_total'), value: '${total.toStringAsFixed(2)} $ils'),
        if (b != null)
          EventDetailRow(label: context.tr('event_details_paid'), value: '${b.paid.toStringAsFixed(2)} $ils'),
        // An active event with a limit can grow: the owner pays the difference.
        if (event.isActive && event.role.canOwn && limit != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 12),
            child: OutlinedButton.icon(
              key: const Key('event_upgrade'),
              onPressed: () => _upgrade(context),
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: Text(context.tr('upgrade_title')),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            ),
          ),
      ],
    );
  }
}
