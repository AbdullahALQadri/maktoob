import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';

/// Opening scene — the same story as the web home page:
///
///  1. an entry pass builds itself out of a QR      ("an invitation for every guest")
///  2. a beam scans it                               ("a code that is only theirs")
///  3. it becomes a confirmation tick                ("attendance confirmed")
///  4. the tick turns into the Maktoob mark + name   (from invitation to the door)
///
/// One controller drives everything; times below are seconds on a 5.6 s
/// baseline that is played back in [_total]. Tap anywhere or "Skip" to leave.
/// With animations disabled by the system it shows the final frame briefly.
///
/// The whole story plays once per install; later launches play only its
/// closing beat (confirmation → mark + name, ~1.5 s).
class SplashScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const SplashScreen({super.key, required this.onFinished});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _total = Duration(milliseconds: 4600);
  static const _baseline = 5.6;
  static const _seenKey = 'splash_story_seen';

  /// Where the short version starts (baseline seconds): the coin is formed and
  /// the tick is drawing.
  static const _shortFrom = 3.8;
  double _from = 0;

  late final AnimationController _c =
      AnimationController(vsync: this, duration: _total);
  bool _finished = false;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed) _finish();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _begin();
  }

  Future<void> _begin() async {
    var seen = false;
    try {
      seen = (await SharedPreferences.getInstance()).getBool(_seenKey) ?? false;
    } catch (_) {}
    if (!mounted) return;
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      _c.value = 0.8; // settled frame: mark + name
      Future.delayed(const Duration(milliseconds: 900), _finish);
    } else {
      _from = seen ? _shortFrom / _baseline : 0;
      _c.forward(from: _from);
    }
  }

  void _finish() {
    if (_finished || !mounted) return;
    _finished = true;
    SharedPreferences.getInstance()
        .then((p) => p.setBool(_seenKey, true))
        .catchError((_) => false);
    widget.onFinished();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// 0..1 progress of the window [a, b] (baseline seconds), eased.
  double _seg(double a, double b, [Curve curve = Curves.easeOut]) {
    final t = _c.value * _baseline;
    return curve.transform(((t - a) / (b - a)).clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    String tr(String key, String fallback) =>
        loc?.translate(key) ?? fallback;

    final width = MediaQuery.sizeOf(context).width;
    final s = math.min(216.0, width * 0.56); // pass edge

    return Scaffold(
      backgroundColor: AppColors.tertiaryColor,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _finish,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, 0.1),
              radius: 1.25,
              colors: [Color(0xFF0A3C78), AppColors.tertiaryColor, AppColors.darkBg],
              stops: [0.0, 0.45, 1.0],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedBuilder(
                animation: _c,
                builder: (context, _) => _scene(context, s, tr),
              ),
              PositionedDirectional(
                top: MediaQuery.paddingOf(context).top + 14,
                end: 18,
                child: AnimatedBuilder(
                  animation: _c,
                  builder: (context, _) => Opacity(
                    opacity: _from > 0 ? 1 : _seg(0.8, 1.3),
                    child: TextButton(
                      onPressed: _finish,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                        shape: StadiumBorder(
                          side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.22)),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 6),
                      ),
                      child: Text(tr('common_skip', 'Skip')),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional.bottomStart,
                child: AnimatedBuilder(
                  animation: _c,
                  builder: (context, _) => FractionallySizedBox(
                    widthFactor: ((_c.value - _from) / (1 - _from)).clamp(0.0, 1.0),
                    child: Container(
                      height: 3,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primaryColor, Color(0xFF9CD3F0)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scene(BuildContext context, double s,
      String Function(String, String) tr) {
    final t = _c.value * _baseline;

    // pass entrance, collapse to the coin, back to white for the mark
    final enter = _seg(0.15, 1.05, Curves.easeOutBack);
    final enterOp = _seg(0.15, 0.6);
    final collapse = _seg(3.1, 3.75, Curves.easeInOutCubic);
    final toMark = _seg(4.0, 4.5);
    final size = s * (1 - 0.39 * collapse);
    final radius = 26 + (size / 2 - 26) * collapse;
    final color = Color.lerp(
      Color.lerp(Colors.white, AppColors.primaryColor, collapse),
      Colors.white,
      toMark,
    )!;

    final tick = _seg(3.5, 4.0, Curves.easeInOutCubic);
    final tickOp = (_seg(3.45, 3.6) * (1 - _seg(4.0, 4.25))).clamp(0.0, 1.0);
    final markT = _seg(4.05, 4.65, Curves.easeOutBack);
    final markOp = _seg(4.05, 4.4);

    final words = _seg(4.1, 4.8, Curves.easeOutCubic);
    final tag = _seg(4.25, 4.9);
    final aud = _seg(4.55, 5.1);

    final cap1 = _window(t, 0.95, 2.1);
    final cap2 = _window(t, 2.1, 3.1);
    final cap3 = _window(t, 3.1, 4.0);

    final beamT = _seg(2.1, 3.05, Curves.easeInOut);
    final beamOp =
        (t > 2.1 && t < 3.05) ? math.min(1.0, math.min(beamT * 8, (1 - beamT) * 8)) : 0.0;

    final qrBox = s * 0.78;

    Widget ticket = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          if (collapse > 0)
            BoxShadow(
              color: (toMark < 0.5 ? AppColors.primaryColor : Colors.white)
                  .withValues(alpha: 0.22 * collapse),
              spreadRadius: 10,
              blurRadius: 0,
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 60,
            offset: const Offset(0, 30),
            spreadRadius: -14,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (collapse < 1)
            Opacity(
              opacity: 1 - collapse,
              child: SizedBox(
                width: qrBox,
                height: qrBox,
                child: CustomPaint(painter: _SplashQrPainter(t)),
              ),
            ),
          if (beamOp > 0)
            Positioned(
              left: 0,
              right: 0,
              top: -60 + (s + 70) * beamT,
              height: 46,
              child: Opacity(
                opacity: beamOp,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x003AA4DB),
                        Color(0x613AA4DB),
                        AppColors.primaryColor,
                      ],
                      stops: [0.1, 0.86, 1.0],
                    ),
                    border: Border(
                      bottom: BorderSide(color: Color(0xFF7CCBF0), width: 2),
                    ),
                  ),
                ),
              ),
            ),
          if (tickOp > 0)
            Opacity(
              opacity: tickOp,
              child: SizedBox(
                width: 76,
                height: 76,
                child: CustomPaint(painter: _TickPainter(tick)),
              ),
            ),
          if (markOp > 0)
            Opacity(
              opacity: markOp,
              child: Transform.rotate(
                angle: -0.2 * (1 - markT),
                child: Transform.scale(
                  scale: 0.4 + 0.6 * markT,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 96,
                      height: 96,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    // the pass flies in
    ticket = Opacity(
      opacity: enterOp,
      child: Transform.translate(
        offset: Offset(0, 26 * (1 - enter)),
        child: Transform.rotate(
          angle: -0.087 * (1 - enter),
          child: Transform.scale(scale: 0.86 + 0.14 * enter, child: ticket),
        ),
      ),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: Opacity(
            opacity: _seg(0.1, 1.3),
            child: Container(
              width: s * 3,
              height: s * 3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryColor.withValues(alpha: 0.34),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.72],
                ),
              ),
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: s,
                height: s,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: Size(s, s),
                      painter: _BurstPainter(t),
                    ),
                    ticket,
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 150,
                child: Column(
                  children: [
                    Opacity(
                      opacity: words,
                      child: Transform.translate(
                        offset: Offset(0, 18 * (1 - words)),
                        child: Text(
                          tr('app_name', 'مكتوب'),
                          style: const TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Opacity(
                      opacity: tag,
                      child: Text(
                        tr('splash_tagline', 'من الدعوة إلى الباب'),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF9CD3F0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Opacity(
                      opacity: aud,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 10,
                          runSpacing: 6,
                          children: [
                            for (final (i, k) in const [
                              ('splash_aud_1', 'للأفراد'),
                              ('splash_aud_2', 'للمؤسسات والشركات'),
                              ('splash_aud_3', 'لكل مكان'),
                            ].indexed) ...[
                              if (i > 0) const _Diamond(),
                              Text(
                                tr(k.$1, k.$2),
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: Colors.white.withValues(alpha: 0.72),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // story captions, one at a time
        Positioned(
          left: 0,
          right: 0,
          bottom: math.max(64.0, MediaQuery.sizeOf(context).height * 0.12),
          height: 28,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _Caption(tr('splash_cap_1', 'دعوة خاصة لكل ضيف'), cap1),
              _Caption(tr('splash_cap_2', 'رمز QR لا يشبه غيره'), cap2),
              _Caption(tr('splash_cap_3', 'تم تأكيد الحضور'), cap3),
            ],
          ),
        ),
        // ripples on confirmation
        IgnorePointer(
          child: Center(
            child: CustomPaint(
              size: Size(s, s),
              painter: _RipplePainter(t, s * 0.61),
            ),
          ),
        ),
      ],
    );
  }

  /// 0..1 visibility of a caption between [a, b], fading in/out over 0.35 s.
  double _window(double t, double a, double b) {
    const f = 0.35;
    if (t < a || t > b) return 0;
    return math.min(1.0, math.min((t - a) / f, (b - t) / f));
  }
}

class _Caption extends StatelessWidget {
  final String text;
  final double visible;
  const _Caption(this.text, this.visible);

  @override
  Widget build(BuildContext context) {
    if (visible <= 0) return const SizedBox.shrink();
    return Opacity(
      opacity: visible,
      child: Transform.translate(
        offset: Offset(0, 10 * (1 - visible)),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.86),
          ),
        ),
      ),
    );
  }
}

class _Diamond extends StatelessWidget {
  const _Diamond();

  @override
  Widget build(BuildContext context) => Transform.rotate(
        angle: math.pi / 4,
        child: Container(width: 5, height: 5, color: AppColors.primaryColor),
      );
}

/// The pseudo-QR that builds itself from the centre outward, then dissolves.
class _SplashQrPainter extends CustomPainter {
  _SplashQrPainter(this.t);
  final double t; // baseline seconds

  static const _n = 21;
  static final List<_Cell> _cells = _makeCells();

  static List<_Cell> _makeCells() {
    final rnd = math.Random(2026);
    final out = <_Cell>[];
    for (var y = 0; y < _n; y++) {
      for (var x = 0; x < _n; x++) {
        if ((x < 8 && y < 8) || (x > 12 && y < 8) || (x < 8 && y > 12)) {
          continue;
        }
        if (rnd.nextInt(100) >= 48) continue;
        final d = math.sqrt(math.pow(x - 10, 2) + math.pow(y - 10, 2));
        out.add(_Cell(
          x,
          y,
          0.35 + d * 0.042 + rnd.nextInt(13) / 100,
          math.max(0.0, (14.5 - d) * 0.02),
        ));
      }
    }
    return out;
  }

  /// scale of an element that builds in at [inAt] (0.55 s) and leaves at
  /// 3.1 s + [outDelay] (0.4 s).
  double _scale(double inAt, double outDelay, double dur) {
    final built = Curves.easeOutBack.transform(((t - inAt) / dur).clamp(0.0, 1.0));
    final gone = ((t - (3.1 + outDelay)) / 0.4).clamp(0.0, 1.0);
    return (built * (1 - gone)).clamp(0.0, 1.3);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.shortestSide / _n;
    final p = Paint()..color = AppColors.tertiaryColor;

    void cell(double x, double y, double sc) {
      if (sc <= 0.01) return;
      final c = Offset((x + 0.5) * u, (y + 0.5) * u);
      canvas.drawRect(
        Rect.fromCenter(center: c, width: u * sc, height: u * sc),
        p,
      );
    }

    for (final c in _cells) {
      cell(c.x.toDouble(), c.y.toDouble(), _scale(c.inAt, c.outAt, 0.55));
    }

    for (final o in const [
      [0, 0],
      [14, 0],
      [0, 14]
    ]) {
      final sc = _scale(0.08, 0.1, 0.7);
      if (sc <= 0.01) continue;
      final ctr = Offset((o[0] + 3.5) * u, (o[1] + 3.5) * u);
      canvas.save();
      canvas.translate(ctr.dx, ctr.dy);
      canvas.scale(sc);
      canvas.translate(-ctr.dx, -ctr.dy);
      final x = o[0] * u, y = o[1] * u;
      canvas.drawPath(
        Path()
          ..fillType = PathFillType.evenOdd
          ..addRect(Rect.fromLTWH(x, y, 7 * u, 7 * u))
          ..addRect(Rect.fromLTWH(x + u, y + u, 5 * u, 5 * u)),
        p,
      );
      canvas.drawRect(Rect.fromLTWH(x + 2 * u, y + 2 * u, 3 * u, 3 * u), p);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_SplashQrPainter old) => old.t != t;
}

class _Cell {
  final int x, y;
  final double inAt, outAt;
  const _Cell(this.x, this.y, this.inAt, this.outAt);
}

class _TickPainter extends CustomPainter {
  _TickPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 64;
    final path = Path()
      ..moveTo(17 * k, 33.5 * k)
      ..lineTo(28 * k, 44.5 * k)
      ..lineTo(47.5 * k, 21 * k);
    final metric = path.computeMetrics().first;
    canvas.drawPath(
      metric.extractPath(0, metric.length * progress),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.5 * k
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_TickPainter old) => old.progress != progress;
}

class _RipplePainter extends CustomPainter {
  _RipplePainter(this.t, this.coin);
  final double t;
  final double coin; // coin diameter

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    for (final start in const [3.45, 3.7]) {
      final k = ((t - start) / 1.2).clamp(0.0, 1.0);
      if (k <= 0 || k >= 1) continue;
      canvas.drawCircle(
        c,
        coin / 2 * (1 + 1.6 * Curves.easeOut.transform(k)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFF7CCBF0).withValues(alpha: 0.9 * (1 - k)),
      );
    }
  }

  @override
  bool shouldRepaint(_RipplePainter old) => old.t != t;
}

/// Little diamonds thrown outward when attendance is confirmed.
class _BurstPainter extends CustomPainter {
  _BurstPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final k = ((t - 3.6) / 0.9).clamp(0.0, 1.0);
    if (k <= 0 || k >= 1) return;
    final c = size.center(Offset.zero);
    final e = Curves.easeOutCubic.transform(k);
    const count = 14;
    for (var i = 0; i < count; i++) {
      final a = i * (2 * math.pi / count);
      final len = 92.0 + (i % 3) * 22;
      final sz = (5.0 + (i % 2) * 3) * (1 - 0.8 * k);
      final o = c + Offset(math.cos(a), math.sin(a)) * (len * e);
      canvas.save();
      canvas.translate(o.dx, o.dy);
      canvas.rotate(math.pi / 4);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: sz, height: sz),
        Paint()
          ..color = (i % 3 == 0 ? Colors.white : const Color(0xFF7CCBF0))
              .withValues(alpha: 1 - k),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.t != t;
}
