import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';

/// Header widget for home screen with gradient background.
class HomeHeader extends StatelessWidget {
  final Animation<double> fadeAnimation;

  const HomeHeader({super.key, required this.fadeAnimation});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryColor, AppColors.tertiaryColor],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: Padding(
            padding: EdgeInsets.only(
              left: context.dynamicWidth(0.04),
              right: context.dynamicWidth(0.04),
              top: context.dynamicHeight(0.02),
              bottom: context.dynamicHeight(0.039),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _WelcomeBadge(text: t.translate('home_welcome')),
                SizedBox(height: context.dynamicHeight(0.02)),
                _AnimatedTitle(text: t.translate('home_dashboard')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeBadge extends StatelessWidget {
  final String text;

  const _WelcomeBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.dynamicWidth(0.029),
              vertical: context.dynamicHeight(0.007),
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: AppColors.yellow400,
                  size: context.dynamicWidth(0.04),
                ),
                SizedBox(width: context.dynamicWidth(0.016)),
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.dynamicWidth(0.029),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedTitle extends StatelessWidget {
  final String text;

  const _AnimatedTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: const Offset(0, 20), end: Offset.zero),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, offset, child) {
        return Transform.translate(offset: offset, child: child);
      },
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: context.dynamicWidth(0.069),
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
