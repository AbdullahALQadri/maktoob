import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../widgets/widgets.dart';

/// Splash screen with animated logo.
class SplashScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const SplashScreen({super.key, required this.onFinished});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    Timer(const Duration(milliseconds: 2500), widget.onFinished);
  }

  void _initAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.7, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _SplashBackground(
        child: Stack(
          children: [
            const AuthDecorativePattern(),
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => _AnimatedContent(
                  logoFade: _logoFade,
                  logoScale: _logoScale,
                  textFade: _textFade,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashBackground extends StatelessWidget {
  final Widget child;

  const _SplashBackground({required this.child});

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

class _AnimatedContent extends StatelessWidget {
  final Animation<double> logoFade;
  final Animation<double> logoScale;
  final Animation<double> textFade;

  const _AnimatedContent({
    required this.logoFade,
    required this.logoScale,
    required this.textFade,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FadeTransition(
          opacity: logoFade,
          child: ScaleTransition(
            scale: logoScale,
            child: _SplashLogo(),
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.03)),
        FadeTransition(
          opacity: textFade,
          child: Text(
            AppStrings.appName,
            style: TextStyle(
              fontSize: context.dynamicWidth(0.085),
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 3,
            ),
          ),
        ),
      ],
    );
  }
}

class _SplashLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'app_logo',
      child: Container(
        width: context.dynamicWidth(0.32),
        height: context.dynamicWidth(0.32),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipOval(
          child: Padding(
            padding: EdgeInsets.all(context.dynamicWidth(0.043)),
            child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
