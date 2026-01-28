import 'package:flutter/material.dart';

import '../../../../core/core.dart';

/// Circular icon display for authentication screens.
class AuthScreenIcon extends StatelessWidget {
  final IconData icon;

  const AuthScreenIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.dynamicWidth(0.28),
      height: context.dynamicWidth(0.28),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: context.dynamicWidth(0.141),
        color: AppColors.primaryColor,
      ),
    );
  }
}
