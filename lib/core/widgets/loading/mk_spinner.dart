import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

/// Maktoob's waiting mark: three QR corner squares and a fourth corner whose
/// cells light up one after another. Same language as the web `mk-spin`.
///
/// Drop-in for [CircularProgressIndicator] (indeterminate only): it accepts
/// the same `color` / `valueColor` / `strokeWidth` arguments so existing call
/// sites keep compiling; `strokeWidth`, `value` and `backgroundColor` are
/// ignored.
class MkSpinner extends StatefulWidget {
  const MkSpinner({
    super.key,
    this.color,
    this.valueColor,
    this.strokeWidth,
    this.value,
    this.backgroundColor,
    this.semanticsLabel,
  });

  final Color? color;
  final Animation<Color?>? valueColor;
  final double? strokeWidth;
  final double? value;
  final Color? backgroundColor;
  final String? semanticsLabel;

  @override
  State<MkSpinner> createState() => _MkSpinnerState();
}

class _MkSpinnerState extends State<MkSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (still) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.valueColor?.value ??
        widget.color ??
        ProgressIndicatorTheme.of(context).color ??
        AppColors.primaryColor;
    return Semantics(
      label: widget.semanticsLabel,
      child: RepaintBoundary(
        child: AspectRatio(
          aspectRatio: 1,
          child: CustomPaint(painter: _MarkPainter(_c, color)),
        ),
      ),
    );
  }
}

class _MarkPainter extends CustomPainter {
  _MarkPainter(this.t, this.color) : super(repaint: t);

  final Animation<double> t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final u = s / 7; // 7-unit grid: finder = 3, gap = 1
    final ring = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = u * 0.62;
    final solid = Paint()..color = color;
    final r = Radius.circular(u * 0.45);

    void finder(double x, double y) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + u * 0.31, y + u * 0.31, u * 2.38, u * 2.38),
          r,
        ),
        ring,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + u * 1.05, y + u * 1.05, u * 0.9, u * 0.9),
          Radius.circular(u * 0.2),
        ),
        solid,
      );
    }

    finder(0, 0);
    finder(u * 4, 0);
    finder(0, u * 4);

    // The fourth corner: four cells that light in sequence.
    final cells = [
      Offset(u * 4.1, u * 4.1),
      Offset(u * 5.4, u * 4.1),
      Offset(u * 4.1, u * 5.4),
      Offset(u * 5.4, u * 5.4),
    ];
    final still = !t.isAnimating;
    for (var i = 0; i < cells.length; i++) {
      final phase = (t.value - i * 0.16) % 1.0;
      final a = still
          ? 1.0
          : (phase < 0.5
              ? 0.25 + 0.75 * (phase / 0.5)
              : 1.0 - 0.75 * ((phase - 0.5) / 0.5));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(cells[i].dx, cells[i].dy, u, u),
          Radius.circular(u * 0.22),
        ),
        Paint()..color = color.withValues(alpha: a.clamp(0.0, 1.0)),
      );
    }
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.color != color;
}
