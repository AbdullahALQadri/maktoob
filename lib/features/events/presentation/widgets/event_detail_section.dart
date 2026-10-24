import 'package:flutter/material.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/core.dart';

/// One section of the event page: a flat card with a 1px outline, a title and
/// its rows (DESIGN.md: no shadows, no card inside a card).
class EventDetailSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const EventDetailSection({
    super.key,
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard.outlined(
      borderRadius: AppSpacing.radiusMd,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: context.brandInk),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(title, style: AppTextStyles.titleMedium.copyWith(color: context.textPrimary)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...children,
        ],
      ),
    );
  }
}

/// A label over its value. A missing value reads "Not set"; [trailing] sits
/// at the row's end (a map button, a badge).
class EventDetailRow extends StatelessWidget {
  final String label;
  final String? value;
  final String? note;
  final Widget? trailing;

  const EventDetailRow({
    super.key,
    required this.label,
    this.value,
    this.note,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final text = (value ?? '').trim();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption.copyWith(color: context.textSecondary)),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  text.isEmpty ? context.tr('common_not_set') : text,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: text.isEmpty ? context.textSecondary : context.textPrimary,
                    height: 1.5,
                  ),
                ),
                if (note != null && note!.trim().isNotEmpty)
                  Text(note!, style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary)),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            trailing!,
          ],
        ],
      ),
    );
  }
}
