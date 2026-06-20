import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../domain/entities/recent_event_entity.dart';

/// Recent event card — premium, image-led.
///
/// Every card leads with the event's real cover/AI image (with a graceful
/// gradient fallback when none exists). The event title and date sit on a
/// dark scrim over the image for an editorial hero feel; the body carries the
/// venue and an RSVP progress hairline. Used on the home screen, which only
/// lists ACTIVE events.
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

  @override
  Widget build(BuildContext context) {
    return StaggeredSlideFade(
      index: index,
      baseDelayMs: 360,
      staggerMs: 80,
      slideOffset: 24,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(bottom: 18),
        child: Material(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.gray200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CoverHero(event: event),
                  _Body(event: event),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Image header with scrim + category chip + overlaid title & date.
class _CoverHero extends StatelessWidget {
  final RecentEventEntity event;
  const _CoverHero({required this.event});

  @override
  Widget build(BuildContext context) {
    final category = _inferCategory(context, event.name);
    final text = Theme.of(context).textTheme;

    return SizedBox(
      height: 172,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Real image, or a branded gradient fallback.
          if (event.hasImage)
            CachedNetworkImage(
              imageUrl: event.imageUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) => _GradientFallback(
                colors: event.gradientColors,
                showIcon: false,
              ),
              errorWidget: (_, __, ___) =>
                  _GradientFallback(colors: event.gradientColors),
            )
          else
            _GradientFallback(colors: event.gradientColors),

          // Bottom scrim for legible overlaid text.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: [0.0, 0.55, 1.0],
                colors: [
                  Color(0xCC000000),
                  Color(0x33000000),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Category chip (top-start).
          PositionedDirectional(
            top: 14,
            start: 14,
            child: _CategoryChip(category: category),
          ),

          // Title + date (bottom overlay).
          PositionedDirectional(
            start: 16,
            end: 16,
            bottom: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  event.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    shadows: const [
                      Shadow(color: Color(0x99000000), blurRadius: 8),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(event.date),
                      style: text.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientFallback extends StatelessWidget {
  final List<Color> colors;
  final bool showIcon;
  const _GradientFallback({required this.colors, this.showIcon = true});

  @override
  Widget build(BuildContext context) {
    final gradient = colors.length >= 2
        ? colors
        : [AppColors.primaryColor, AppColors.tertiaryColor];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
      ),
      child: showIcon
          ? Center(
              child: Icon(
                Icons.celebration_outlined,
                size: 44,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

class _Body extends StatelessWidget {
  final RecentEventEntity event;
  const _Body({required this.event});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final t = AppLocalizations.of(context)!;
    final rate = (event.responseRate.clamp(0.0, 1.0) * 100).round();

    return Padding(
      padding: const EdgeInsetsDirectional.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (event.venue.isNotEmpty)
            _MetaRow(icon: Icons.location_on_outlined, text: event.venue),
          if (event.venue.isNotEmpty) const SizedBox(height: 14),
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
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: SizedBox(
              height: 6,
              child: Stack(
                children: [
                  Container(color: AppColors.gray200),
                  FractionallySizedBox(
                    widthFactor: event.responseRate.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryColor,
                            AppColors.tertiaryColor,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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

class _CategoryChip extends StatelessWidget {
  final String category;
  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    final isEn = AppLocalizations.of(context)!.isEnLocale;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
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
  if (lower.contains('engagement') || lower.contains('خطوبة') || lower.contains('خطوبه') || lower.contains('nişan')) {
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
  if (lower.contains('party') || lower.contains('حفلة') || lower.contains('حفله') || lower.contains('parti')) {
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
