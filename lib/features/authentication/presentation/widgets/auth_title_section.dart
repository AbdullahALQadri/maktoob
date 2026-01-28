import 'package:flutter/material.dart';

import '../../../../core/core.dart';

/// Title and subtitle section for auth screens.
class AuthTitleSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? extra;

  const AuthTitleSection({
    super.key,
    required this.title,
    this.subtitle,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: AppTextStyles.headlineMedium.white),
        if (subtitle != null) ...[
          SizedBox(height: context.dynamicHeight(0.015)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.051)),
            child: Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),
          ),
        ],
        if (extra != null) ...[
          SizedBox(height: context.dynamicHeight(0.007)),
          extra!,
        ],
      ],
    );
  }
}

/// Phone display badge widget.
class PhoneBadge extends StatelessWidget {
  final String phone;

  const PhoneBadge({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(phone, style: AppTextStyles.titleMedium.white),
    );
  }
}
