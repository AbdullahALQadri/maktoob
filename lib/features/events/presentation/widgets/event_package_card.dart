import 'package:flutter/material.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../domain/entities/event_entity.dart';
import 'event_detail_section.dart';

/// The package, the invitations used out of the allowance, and the money
/// (invoice total and what was paid, in ₪).
class EventPackageCard extends StatelessWidget {
  final EventEntity event;

  const EventPackageCard({super.key, required this.event});

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
      ],
    );
  }
}
