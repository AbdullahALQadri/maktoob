import 'dart:async';

import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

/// The blocking wait: a QR pass a scanning beam sweeps over, then a tick when
/// [done] flips to true. Same scene as the web `MkLoader.show()` overlay.
///
/// [lines] rotate every [every] so a long wait reads as progress; they must
/// never name the technology behind the work (see PRODUCT.md).
class MkPass extends StatefulWidget {
  const MkPass({
    super.key,
    this.lines = const [],
    this.every = const Duration(seconds: 9),
    this.done = false,
    this.textColor = Colors.white,
  });

  final List<String> lines;
  final Duration every;
  final bool done;
  final Color textColor;

  @override
  State<MkPass> createState() => _MkPassState();
}

class _MkPassState extends State<MkPass> with SingleTickerProviderStateMixin {
  late final AnimationController _beam = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );
  Timer? _timer;
  int _i = 0;

  @override
  void initState() {
    super.initState();
    if (widget.lines.length > 1) {
      _timer = Timer.periodic(widget.every, (_) {
        if (mounted && _i < widget.lines.length - 1) setState(() => _i++);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (still) {
      _beam.stop();
    } else if (!_beam.isAnimating) {
      _beam.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _beam.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final line = widget.lines.isEmpty ? null : widget.lines[_i];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            color: widget.done ? AppColors.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(widget.done ? 52 : 22),
          ),
          clipBehavior: Clip.antiAlias,
          child: widget.done
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 56)
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: CustomPaint(
                          painter: _QrPainter(AppColors.tertiaryColor)),
                    ),
                    AnimatedBuilder(
                      animation: _beam,
                      builder: (_, _) => Align(
                        alignment: Alignment(0, -1 + 2 * _beam.value),
                        child: Container(
                          height: 3,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
        if (line != null) ...[
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              line,
              key: ValueKey(line),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: widget.textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _QrPainter extends CustomPainter {
  _QrPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const n = 21;
    final u = size.shortestSide / n;
    final p = Paint()..color = color;
    bool finder(int x, int y) =>
        (x < 8 && y < 8) || (x > 12 && y < 8) || (x < 8 && y > 12);
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        if (finder(x, y)) continue;
        if (((x * 7 + y * 13 + x * y) % 5) < 2) {
          canvas.drawRect(Rect.fromLTWH(x * u, y * u, u, u), p);
        }
      }
    }
    for (final o in const [
      [0, 0],
      [14, 0],
      [0, 14]
    ]) {
      final x = o[0] * u, y = o[1] * u;
      canvas.drawPath(
        Path()
          ..fillType = PathFillType.evenOdd
          ..addRect(Rect.fromLTWH(x, y, 7 * u, 7 * u))
          ..addRect(Rect.fromLTWH(x + u, y + u, 5 * u, 5 * u)),
        p,
      );
      canvas.drawRect(Rect.fromLTWH(x + 2 * u, y + 2 * u, 3 * u, 3 * u), p);
    }
  }

  @override
  bool shouldRepaint(_QrPainter old) => old.color != color;
}
