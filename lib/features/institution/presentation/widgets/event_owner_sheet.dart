import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../authentication/domain/entities/user_entity.dart';

/// "لمن هذه المناسبة؟" — personal account or one of [choices]
/// (institutions the user owns or manages). Resolves to the picked
/// institution, or null for the personal account (also on dismiss).
Future<EventOwnerChoice?> showEventOwnerSheet(
  BuildContext context,
  List<EventOwnerChoice> choices,
) {
  final t = AppLocalizations.of(context)!;
  return showModalBottomSheet<EventOwnerChoice?>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t.translate('wizard_event_owner_title'),
              style: AppTextStyles.titleMedium.copyWith(color: sheetContext.textPrimary),
            ),
            const SizedBox(height: AppSpacing.md),
            _OwnerOption(
              key: const Key('event_owner_personal'),
              icon: Icons.person_outline_rounded,
              title: t.translate('wizard_event_owner_personal'),
              onTap: () => Navigator.pop(sheetContext),
            ),
            for (final c in choices) ...[
              const SizedBox(height: AppSpacing.sm),
              _OwnerOption(
                key: Key('event_owner_${c.institutionId}'),
                icon: Icons.business_rounded,
                title: c.name,
                onTap: () => Navigator.pop(sheetContext, c),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

class _OwnerOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _OwnerOption({super.key, required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusLg,
      child: Container(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: AppSpacing.borderRadiusLg,
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryColor),
            const SizedBox(width: AppSpacing.smd),
            Expanded(
              child: Text(title, style: AppTextStyles.bodyLarge.copyWith(color: context.textPrimary)),
            ),
          ],
        ),
      ),
    );
  }
}
