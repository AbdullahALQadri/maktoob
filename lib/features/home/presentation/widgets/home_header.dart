import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';

/// Editorial dashboard heading.
///
/// Large title first, soft welcome subtitle below — matches the mockup's
/// editorial layout. No badge, no sparkle, no gradient.
class HomeHeader extends StatelessWidget {
  final Animation<double> fadeAnimation;

  const HomeHeader({super.key, required this.fadeAnimation});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final text = Theme.of(context).textTheme;

    return FadeTransition(
      opacity: fadeAnimation,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t.translate('home_dashboard'),
              style: text.headlineLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
                height: 1.15,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              t.translate('home_dashboard_subtitle'),
              style: text.bodyMedium?.copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
