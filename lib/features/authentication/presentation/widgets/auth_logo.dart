import 'package:flutter/material.dart';

import '../../../../core/core.dart';

/// Logo widget for auth screens.
class AuthLogo extends StatelessWidget {
  final String heroTag;
  final double? sizeFactor;

  const AuthLogo({super.key, this.heroTag = 'app_logo', this.sizeFactor});

  @override
  Widget build(BuildContext context) {
    final size = context.dynamicWidth(sizeFactor ?? 0.261);

    return Hero(
      tag: heroTag,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 25,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipOval(
          child: Padding(
            padding: EdgeInsets.all(context.dynamicWidth(0.035)),
            child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
