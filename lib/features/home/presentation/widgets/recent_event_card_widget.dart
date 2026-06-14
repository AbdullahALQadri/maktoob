import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../domain/entities/recent_event_entity.dart';

/// Recent event card.
///
/// Two variants per the mockup:
///  - index 0: photo-led card with a 128pt cover area + floating category
///    chip overlay. The cover is a stylized placeholder (warm parchment
///    surface) until events ship with real image URLs.
///  - index 1+: text-led card with the category label above the title.
///
/// Both variants share the same content body (location/date + RSVP
/// progress row with a 1pt hairline bar).
class RecentEventCardWidget extends StatelessWidget {
  final RecentEventEntity event;
  final int index;
  final VoidCallback? onTap;

  const RecentEventCardWidget({
    super.key,
    required this.event,
    required this.index,
    this.onTap,
  });

  bool get _photoLed => index == 0;

  @override
  Widget build(BuildContext context) {
    return StaggeredSlideFade(
      index: index,
      baseDelayMs: 400,
      staggerMs: 80,
      slideOffset: 24,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(bottom: 16),
        child: Material(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                border: Border.all(color: AppColors.gray200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_photoLed) _CoverBlock(event: event),
                  _Body(event: event, photoLed: _photoLed),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CoverBlock extends StatelessWidget {
  final RecentEventEntity event;
  const _CoverBlock({required this.event});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 128,
      width: double.infinity,
      child: Stack(
        children: [
          Container(color: AppColors.gray100),
          Positioned.fill(
            child: Center(
              child: Icon(
                Icons.celebration_outlined,
                size: 48,
                color: AppColors.gray300,
              ),
            ),
          ),
          PositionedDirectional(
            bottom: 12,
            start: 16,
            child: _CategoryChip(
              category: _inferCategory(context, event.name),
              onLightSurface: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final RecentEventEntity event;
  final bool photoLed;
  const _Body({required this.event, required this.photoLed});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final t = AppLocalizations.of(context)!;
    final rate = (event.responseRate * 100).round();
    final category = _inferCategory(context, event.name);

    return Padding(
      padding: const EdgeInsetsDirectional.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!photoLed) ...[
                      _SectionEyebrow(label: category),
                      const SizedBox(height: 6),
                    ],
                    Text(
                      event.name,
                      style: text.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.more_vert,
                size: 22,
                color: context.textTertiary,
              ),
            ],
          ),
          const SizedBox(height: 10),
          _MetaRow(
            icon: photoLed ? Icons.location_on_outlined : Icons.calendar_today_outlined,
            text: photoLed ? event.venue : _formatDate(event.date),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.translate('home_event_rsvp_progress'),
                style: text.labelMedium?.copyWith(
                  color: context.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$rate%',
                style: text.labelMedium?.copyWith(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 1,
            child: Stack(
              children: [
                Container(color: AppColors.gray200),
                FractionallySizedBox(
                  widthFactor: event.responseRate,
                  child: Container(color: AppColors.primaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: context.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: t.bodyMedium?.copyWith(color: context.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _SectionEyebrow extends StatelessWidget {
  final String label;
  const _SectionEyebrow({required this.label});

  @override
  Widget build(BuildContext context) {
    final isEn = AppLocalizations.of(context)!.isEnLocale;
    return Text(
      isEn ? label.toUpperCase() : label,
      style: TextStyle(
        fontFamily: 'Tajawal',
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: context.textSecondary,
        letterSpacing: isEn ? 1.5 : 0,
        height: 1.3,
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String category;
  final bool onLightSurface;
  const _CategoryChip({required this.category, required this.onLightSurface});

  @override
  Widget build(BuildContext context) {
    final isEn = AppLocalizations.of(context)!.isEnLocale;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: onLightSurface ? 1.0 : 0.85),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Text(
        isEn ? category.toUpperCase() : category,
        style: TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryColor,
          letterSpacing: isEn ? 1.0 : 0,
          height: 1.2,
        ),
      ),
    );
  }
}

String _inferCategory(BuildContext context, String name) {
  final t = AppLocalizations.of(context)!;
  final lower = name.toLowerCase();
  if (lower.contains('wedding') || lower.contains('زفاف') || lower.contains('düğün')) {
    return t.translate('home_event_category_wedding');
  }
  if (lower.contains('engagement') || lower.contains('خطوبة') || lower.contains('nişan')) {
    return t.translate('home_event_category_engagement');
  }
  if (lower.contains('birthday') || lower.contains('ميلاد') || lower.contains('doğum')) {
    return t.translate('home_event_category_birthday');
  }
  if (lower.contains('conference') ||
      lower.contains('summit') ||
      lower.contains('مؤتمر') ||
      lower.contains('konferans')) {
    return t.translate('home_event_category_conference');
  }
  if (lower.contains('party') || lower.contains('حفلة') || lower.contains('parti')) {
    return t.translate('home_event_category_party');
  }
  return t.translate('home_event_category_event');
}

String _formatDate(String dateString) {
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  final parts = dateString.split('-');
  if (parts.length < 3) return dateString;
  final year = int.tryParse(parts[0]) ?? 0;
  final monthIdx = (int.tryParse(parts[1]) ?? 1) - 1;
  final day = int.tryParse(parts[2]) ?? 1;
  final month = months[monthIdx.clamp(0, 11)];
  return '$month $day, $year';
}
