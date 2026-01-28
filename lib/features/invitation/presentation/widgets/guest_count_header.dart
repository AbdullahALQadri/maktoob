import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../data/models/invitation_draft_model.dart';
import '../cubit/invitation_state.dart';

/// Header showing total guest count and breakdown by source.
class GuestCountHeader extends StatelessWidget {
  final InvitationState state;

  const GuestCountHeader({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final totalGuests = state.allGuests.length;
    final contactsCount =
        state.allGuests.where((g) => g.source == GuestSource.contacts).length;
    final excelCount =
        state.allGuests.where((g) => g.source == GuestSource.excel).length;
    final manualCount =
        state.allGuests.where((g) => g.source == GuestSource.manual).length;

    final contactsLabel = l?.translate('invitation_contacts') ?? 'Contacts';
    final excelLabel = l?.translate('invitation_excel') ?? 'Excel';
    final manualLabel = l?.translate('invitation_manual') ?? 'Manual';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.04),
        vertical: context.dynamicHeight(0.015),
      ),
      color: AppColors.primary,
      child: Row(
        children: [
          Icon(
            Icons.people,
            color: Colors.white,
            size: context.dynamicWidth(0.069),
          ),
          SizedBox(width: context.dynamicWidth(0.029)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l?.translate('invitation_total_guests') ?? 'Total Guests'}: $totalGuests',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.dynamicWidth(0.045),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (totalGuests > 0)
                  Text(
                    '$contactsLabel: $contactsCount | $excelLabel: $excelCount | $manualLabel: $manualCount',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: context.dynamicWidth(0.029),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
