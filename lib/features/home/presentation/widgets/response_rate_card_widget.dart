import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';

/// Hero metric card — response rate.
///
/// A deep-emerald "grounding" surface (the brand's tertiary anchor) carrying a
/// gold circular gauge of the response rate, with the percentage at its centre
/// and the responded/total ratio + caption alongside. Solid colour, no
/// gradients/glass — emerald + gold is the brand's anchoring pair on warm paper.
class ResponseRateCardWidget extends StatefulWidget {
  final double responseRate;
  final int totalResponded;
  final int totalGuests;

  const ResponseRateCardWidget({
    super.key,
    required this.responseRate,
    required this.totalResponded,
    required this.totalGuests,
  });

  @override
  State<ResponseRateCardWidget> createState() => _ResponseRateCardWidgetState();
}

class _ResponseRateCardWidgetState extends State<ResponseRateCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    );
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _progressController.forward();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final rate = widget.responseRate.clamp(0.0, 1.0);
    final percent = (rate * 100).round();
    final rawLabel = t.translate('home_response_rate');
    final label = t.isEnLocale ? rawLabel.toUpperCase() : rawLabel;
    const cream = Colors.white;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) => Transform.translate(
        offset: Offset(0, 16 * (1 - value)),
        child: Opacity(opacity: value, child: child),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsetsDirectional.all(22),
          decoration: BoxDecoration(
            color: AppColors.tertiaryColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: [
              BoxShadow(
                color: AppColors.tertiaryColor.withValues(alpha: 0.28),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              // Gold circular gauge with the percentage at its centre.
              SizedBox(
                width: 104,
                height: 104,
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _GaugePainter(
                        progress: rate * _progressAnimation.value,
                        track: cream.withValues(alpha: 0.16),
                        arc: AppColors.primaryColor,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$percent%',
                              style: const TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: cream,
                                height: 1.0,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 20),
              // Label, ratio, caption.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        letterSpacing: t.isEnLocale ? 1.2 : 0,
                        color: cream.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _format(widget.totalResponded),
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryColor,
                            height: 1.0,
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsetsDirectional.symmetric(horizontal: 6),
                          child: Text(
                            '/',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: cream.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        Text(
                          _format(widget.totalGuests),
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: cream.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t.translate('home_response_rate_caption'),
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 12,
                        height: 1.4,
                        color: cream.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _format(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

/// Paints a rounded track ring + a gold progress arc starting at the top.
class _GaugePainter extends CustomPainter {
  final double progress; // 0..1
  final Color track;
  final Color arc;

  _GaugePainter({
    required this.progress,
    required this.track,
    required this.arc,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 9.0;
    final rect = Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);

    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, 2 * math.pi, false, trackPaint);

    final sweep = (2 * math.pi) * progress.clamp(0.0, 1.0);
    if (sweep > 0) {
      final arcPaint = Paint()
        ..color = arc
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;
      // Start at the top (-90°) and sweep clockwise.
      canvas.drawArc(rect, -math.pi / 2, sweep, false, arcPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.progress != progress || old.arc != arc || old.track != track;
}
