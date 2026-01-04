import 'package:flutter/material.dart';

BoxShadow shadowXS() => BoxShadow(
      color: const Color(0xFFB3B6BA).withOpacity(0.05),
      blurRadius: 24,
      spreadRadius: -10,
      offset: const Offset(0, 12),
    );

BoxShadow shadowSM() => BoxShadow(
      color: const Color(0xFFA8AFB6).withOpacity(0.15),
      blurRadius: 32,
      spreadRadius: -15,
      offset: const Offset(0, 24),
    );

BoxShadow shadowMD() => BoxShadow(
      color: const Color(0xFF64707A).withOpacity(0.15),
      blurRadius: 48,
      spreadRadius: -20,
      offset: const Offset(0, 32),
    );

BoxShadow shadowLG() => BoxShadow(
      color: const Color(0xFF64707A).withOpacity(0.15),
      blurRadius: 56,
      spreadRadius: -25,
      offset: const Offset(0, 48),
    );
