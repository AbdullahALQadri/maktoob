import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// The banner's faint dot texture (18px grid), as on the web.
class MoodDotsPainter extends CustomPainter {
  const MoodDotsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final dot = Paint()..color = const Color.fromRGBO(255, 255, 255, .07);
    for (var y = 9.0; y < size.height; y += 18) {
      for (var x = 9.0; x < size.width; x += 18) {
        canvas.drawCircle(Offset(x, y), 1, dot);
      }
    }
  }

  @override
  bool shouldRepaint(MoodDotsPainter oldDelegate) => false;
}

/// The eight-pointed star (two squares and two rings) drawn in the mood's
/// accent in the banner's corner.
class MoodStarPainter extends CustomPainter {
  const MoodStarPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.shortestSide / 100;
    final center = size.center(Offset.zero);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6 * unit
      ..color = color.withValues(alpha: .16);
    final square = Rect.fromCenter(center: center, width: 62 * unit, height: 62 * unit);

    canvas.drawRect(square, stroke);
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(math.pi / 4)
      ..translate(-center.dx, -center.dy)
      ..drawRect(square, stroke)
      ..restore();
    canvas.drawCircle(center, 17 * unit, stroke);
    canvas.drawCircle(center, 44 * unit, stroke);
  }

  @override
  bool shouldRepaint(MoodStarPainter oldDelegate) => oldDelegate.color != color;
}
