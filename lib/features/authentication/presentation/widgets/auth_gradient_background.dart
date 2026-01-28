import 'package:flutter/material.dart';

import '../../../../core/core.dart';

/// Gradient background for authentication screens.
class AuthGradientBackground extends StatelessWidget {
  final Widget child;

  const AuthGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withValues(alpha: 0.85),
            AppColors.tertiaryColor.withValues(alpha: 0.9),
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
      child: child,
    );
  }
}
