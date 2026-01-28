import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../domain/entities/event_entity.dart';

/// Package details card.
class EventPackageCard extends StatelessWidget {
  final EventEntity event;

  const EventPackageCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return _DetailCard(
      icon: Icons.workspace_premium,
      title: t.translate('event_details_package'),
      gradient: [AppColors.yellow400, AppColors.amber500],
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.yellow400.withValues(alpha: 0.2),
              AppColors.amber500.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.amber500.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.flash_on, color: AppColors.amber600, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.packageName ?? t.translate('event_details_standard_package'),
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${t.translate('event_details_up_to')} ${event.invitations} ${t.translate('event_details_invitations')}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            Text(event.packagePrice ?? '', style: AppTextStyles.headlineSmall),
          ],
        ),
      ),
    );
  }
}

/// Template info card.
class EventTemplateCard extends StatelessWidget {
  final EventEntity event;

  const EventTemplateCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return _DetailCard(
      icon: Icons.palette_outlined,
      title: t.translate('event_details_template'),
      gradient: [AppColors.purple500, AppColors.pink500],
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.amber600, AppColors.amber600],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('\u2728', style: TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.templateName ?? t.translate('event_details_standard_template'),
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t.translate('event_details_premium_template'),
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                t.translate('common_preview'),
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Event settings card.
class EventSettingsCard extends StatelessWidget {
  final EventEntity event;

  const EventSettingsCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return _DetailCard(
      icon: Icons.settings_outlined,
      title: t.translate('event_details_settings'),
      gradient: [AppColors.emerald500, AppColors.cyan500],
      child: Column(
        children: [
          _SettingRow(
            icon: Icons.people_outline,
            label: t.translate('event_details_allow_companions'),
            value: event.allowCompanions ? t.translate('event_details_yes') : t.translate('event_details_no'),
          ),
          const SizedBox(height: 12),
          _SettingRow(
            icon: Icons.person_add_outlined,
            label: t.translate('event_details_max_companions'),
            value: event.maxCompanions.toString(),
          ),
          const SizedBox(height: 12),
          _SettingRow(
            icon: Icons.qr_code,
            label: t.translate('event_details_qr_checkin'),
            value: t.translate('event_details_enabled'),
          ),
          const SizedBox(height: 12),
          _SettingRow(
            icon: Icons.event_available,
            label: t.translate('event_details_rsvp_required'),
            value: t.translate('event_details_yes'),
          ),
        ],
      ),
    );
  }
}

/// Event description card.
class EventDescriptionCard extends StatelessWidget {
  final EventEntity event;

  const EventDescriptionCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return _DetailCard(
      icon: Icons.description_outlined,
      title: t.translate('event_details_description'),
      gradient: [AppColors.blue500, AppColors.indigo500],
      child: Text(
        event.description ?? '',
        style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
      ),
    );
  }
}

// Private shared widgets

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Color> gradient;
  final Widget child;

  const _DetailCard({
    required this.icon,
    required this.title,
    required this.gradient,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: AppTextStyles.titleLarge),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SettingRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.gray600),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(value, style: AppTextStyles.labelMedium),
          ),
        ],
      ),
    );
  }
}
