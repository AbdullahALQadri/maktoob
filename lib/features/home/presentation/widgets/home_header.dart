import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';

/// Editorial masthead header for the home screen.
///
/// Reads like the head of a fine printed invitation rather than an app
/// dashboard: a hushed gold eyebrow (greeting), a single thin gold hairline as
/// the lone ornament, an oversized tightly-tracked warm-charcoal title, then a
/// quiet subtitle. No cards, no boxes, no gradients — pure type hierarchy on
/// warm paper. RTL-aware: Arabic is never uppercased or positively tracked.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.fadeAnimation});

  final Animation<double> fadeAnimation;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final bool isEn = t.isEnLocale;

    // Uppercase + positive tracking only read as "editorial" in Latin scripts.
    final double eyebrowTracking = isEn ? 2.4 : 0.4;
    final double titleTracking = isEn ? -1.2 : -0.4;
    // Tajawal w700 at 32 can feel dense in Arabic — ease it a touch.
    final double titleSize = isEn ? 32 : 30;

    return FadeTransition(
      opacity: fadeAnimation,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 18, 20, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Eyebrow — quiet gold greeting (w600 so the title stays dominant).
            Text(
              isEn
                  ? t.translate('home_welcome').toUpperCase()
                  : t.translate('home_welcome'),
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.2,
                letterSpacing: eyebrowTracking,
                color: AppColors.primaryColor,
              ),
            ),

            const SizedBox(height: 10),

            // The single ornament: a thin gold hairline rule.
            Container(
              width: 40,
              height: 2,
              color: AppColors.primaryColor,
            ),

            const SizedBox(height: 18),

            // Oversized warm-charcoal title with tight tracking.
            Text(
              t.translate('home_dashboard'),
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: titleSize,
                fontWeight: FontWeight.w700,
                height: 1.08,
                letterSpacing: titleTracking,
                color: context.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            // Quiet subtitle — full copy always shows (no truncation).
            Text(
              t.translate('home_dashboard_subtitle'),
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.45,
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
