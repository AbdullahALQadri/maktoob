import 'package:flutter/material.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/core.dart';
import '../../domain/entities/guest_group.dart';

/// A group in a list: its name and how many people it holds.
class GuestGroupTile extends StatelessWidget {
  const GuestGroupTile({super.key, required this.group, required this.onTap});

  final GuestGroup group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: Key('group_${group.id}'),
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusMd,
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 10, 10),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          children: [
            Icon(Icons.groups_outlined, color: context.primaryText),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    group.name,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.tr('groups_count', {'count': group.guestsCount}),
                    style: TextStyle(fontSize: 12.5, color: context.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: context.textSecondary),
          ],
        ),
      ),
    );
  }
}
