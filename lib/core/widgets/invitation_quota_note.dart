import 'package:flutter/material.dart';

import '../../config/locale/app_localizations.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';

/// One-line note showing how many invitations are still available under the
/// event's package ("12 of 50 invitations remaining"). Callers pass the live
/// numbers so it updates as guests are added, imported or removed.
/// Renders nothing when there is no limit.
class InvitationQuotaNote extends StatelessWidget {
  final int? limit;
  final int remaining;

  const InvitationQuotaNote({
    super.key,
    required this.limit,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    final cap = limit;
    if (cap == null || cap <= 0) return const SizedBox.shrink();
    final t = AppLocalizations.of(context);
    final left = remaining.clamp(0, cap);
    final full = left == 0;
    final color = full ? AppColors.red500 : (left < 10 ? AppColors.amber600 : context.textSecondary);
    final text = full
        ? (t?.translate('guests_limit_reached') ?? '').replaceAll('{limit}', '$cap')
        : (t?.translate('guests_remaining_of_limit') ?? '')
            .replaceAll('{remaining}', '$left')
            .replaceAll('{limit}', '$cap');

    return Padding(
      key: const Key('invitation_quota_note'),
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            full ? Icons.block_rounded : Icons.confirmation_number_outlined,
            size: AppSpacing.iconSm,
            color: color,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(text, style: AppTextStyles.bodySmall.copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}
