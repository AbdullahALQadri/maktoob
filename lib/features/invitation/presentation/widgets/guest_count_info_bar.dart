import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../cubit/invitation_state.dart';

/// Info bar showing guest count and package limit comparison.
class GuestCountInfoBar extends StatelessWidget {
  final InvitationState state;

  const GuestCountInfoBar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final guestCount = state.allGuests.length;
    final packageLimit = state.selectedPackage?.invitationLimit ?? 0;
    final isOverLimit =
        state.selectedPackage != null && guestCount > packageLimit;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.04),
        vertical: context.dynamicHeight(0.015),
      ),
      color: isOverLimit ? Colors.red.shade100 : AppColors.primary,
      child: Row(
        children: [
          Icon(
            isOverLimit ? Icons.warning : Icons.people,
            color: isOverLimit ? Colors.red.shade700 : Colors.white,
            size: context.dynamicWidth(0.061),
          ),
          SizedBox(width: context.dynamicWidth(0.029)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l?.translate('invitation_guest_count') ?? 'Guest count'}: $guestCount',
                  style: TextStyle(
                    color: isOverLimit ? Colors.red.shade900 : Colors.white,
                    fontSize: context.dynamicWidth(0.04),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (state.selectedPackage != null)
                  Text(
                    '${l?.translate('invitation_package_limit') ?? 'Package limit'}: $packageLimit ${l?.translate('invitation_invitations') ?? 'invitations'}',
                    style: TextStyle(
                      color: isOverLimit
                          ? Colors.red.shade700
                          : Colors.white.withValues(alpha: 0.8),
                      fontSize: context.dynamicWidth(0.029),
                    ),
                  ),
              ],
            ),
          ),
          if (isOverLimit)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.dynamicWidth(0.021),
                vertical: context.dynamicHeight(0.005),
              ),
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
              ),
              child: Text(
                l?.translate('invitation_limit_exceeded') ?? 'Limit exceeded!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.dynamicWidth(0.029),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
