import 'package:flutter/material.dart';

import '../../../../../config/locale/l10n_context.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../domain/entities/event_entity.dart';

/// "Your role: manager · read only" on an institution's event.
class EventRoleBanner extends StatelessWidget {
  const EventRoleBanner({super.key, required this.role});

  final EventRole role;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('event_role_banner'),
      padding: const EdgeInsetsDirectional.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.badge_outlined, color: AppColors.primaryColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${context.tr('event_your_role')}: ${context.tr(role.labelKey)}'
              '${role.isReadOnly ? ' · ${context.tr('event_read_only')}' : ''}',
              style: TextStyle(fontSize: 13, color: context.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// The event could not be loaded (and no saved copy exists).
class EventLoadError extends StatelessWidget {
  const EventLoadError({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.all(32),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppColors.red500),
            const SizedBox(height: 16),
            Text(
              context.tr('event_details_error'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: context.textTertiary),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text(context.tr('common_retry'))),
          ],
        ),
      ),
    );
  }
}

/// A titled white card, the building block of the event page.
class EventPageCard extends StatelessWidget {
  const EventPageCard({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        border: Border.all(color: context.borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textTertiary),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
