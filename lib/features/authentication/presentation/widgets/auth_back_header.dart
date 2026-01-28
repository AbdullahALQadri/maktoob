import 'package:flutter/material.dart';

import '../../../../core/core.dart';

/// Header with back button and title for auth screens.
class AuthBackHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const AuthBackHeader({
    super.key,
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
        SizedBox(width: context.dynamicWidth(0.04)),
        Expanded(
          child: Text(title, style: AppTextStyles.headlineSmall.white),
        ),
      ],
    );
  }
}
