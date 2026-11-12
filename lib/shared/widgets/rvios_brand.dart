import 'dart:math' as math;

import 'package:flutter/material.dart';

/// هوية ريفيوس الرسمية — من ملفات الهوية الأصلية (`assets/brand/svg/`).
///
/// * [RvMark] / [AnimatedRvMark]: علامة RV (المسار نفسه في `rvios_mark.svg`).
/// * [RviosWordmark]: «ريفيوس RVIOS للإبداع والتقنية» بخطوطها الأصلية
///   (مداد سوني، مسلمة، ثمانية سيرف ديسبلاي) كما في `rvios_wordmark.svg`.
class RvBrand {
  RvBrand._();

  static const red = Color(0xFFA3272D);
  static const cream = Color(0xFFFFDAA7);

  /// أبعاد العلامة في ملف SVG
  static const markW = 882.74;
  static const markH = 478.11;

  /// أبعاد العلامة اللفظية في ملف SVG
  static const wordW = 643.92;
  static const wordH = 252.54;
}

final Path _rvBase = Path()
  ..moveTo(882.74, 1.55)
  ..cubicTo(818.32, 1.55, 779.23, -9.91, 742.29, 29.41)
  ..lineTo(447.65, 345.03)
  ..lineTo(445.76, 347.12)
  ..lineTo(362.24, 269.04)
  ..cubicTo(386.28, 269.04, 410.55, 266.60, 426.53, 261.71)
  ..cubicTo(442.50, 256.82, 455.30, 249.14, 464.92, 238.67)
  ..cubicTo(474.53, 228.20, 481.58, 214.41, 486.05, 197.30)
  ..cubicTo(490.51, 180.20, 492.75, 159.07, 492.75, 133.93)
  ..cubicTo(492.75, 108.79, 489.92, 88.03, 484.25, 71.61)
  ..cubicTo(478.58, 55.20, 469.73, 42.20, 457.71, 32.60)
  ..cubicTo(445.68, 23.00, 430.22, 16.10, 411.34, 11.91)
  ..cubicTo(392.44, 7.72, 364.49, 5.63, 335.98, 5.63)
  ..lineTo(0.00, 5.63)
  ..lineTo(97.03, 84.52)
  ..cubicTo(115.64, 99.65, 141.93, 108.27, 169.48, 108.27)
  ..lineTo(326.68, 108.27)
  ..cubicTo(339.05, 108.27, 349.87, 112.20, 359.14, 120.05)
  ..cubicTo(368.41, 127.91, 373.05, 137.95, 373.05, 150.16)
  ..cubicTo(373.05, 164.13, 368.24, 174.77, 358.62, 182.10)
  ..cubicTo(349.00, 189.43, 337.83, 193.10, 325.13, 193.10)
  ..lineTo(177.52, 193.10)
  ..lineTo(388.78, 413.57)
  ..lineTo(449.32, 478.08)
  ..lineTo(882.74, 1.55)
  ..close();

/// مسار العلامة مُحجَّمًا ليتوسّط [size] مع حفظ النسبة.
Path rvMarkPath(Size size) {
  final s = math.min(size.width / RvBrand.markW, size.height / RvBrand.markH);
  final dx = (size.width - RvBrand.markW * s) / 2;
  final dy = (size.height - RvBrand.markH * s) / 2;
  final m = Matrix4.identity()
    ..translateByDouble(dx, dy, 0, 1)
    ..scaleByDouble(s, s, 1, 1);
  return _rvBase.transform(m.storage);
}

/// علامة RV ثابتة.
class RvMark extends StatelessWidget {
  const RvMark({super.key, this.width = 64, this.color = RvBrand.red});
  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        height: width * RvBrand.markH / RvBrand.markW,
        child: CustomPaint(painter: _RvPainter(color: color, draw: 1, fill: 1, shine: -1)),
      );
}

/// علامة RV متحرّكة: يُرسم خطّها، ثم تمتلئ وتستقر بنبضة خفيفة، ثم يعبرها بريق.
/// مع [loop] يعود البريق كل بضع ثوانٍ.
class AnimatedRvMark extends StatefulWidget {
  const AnimatedRvMark({
    super.key,
    this.width = 160,
    this.color = RvBrand.red,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 1900),
    this.loop = true,
    this.glow = false,
  });

  final double width;
  final Color color;
  final Duration delay;
  final Duration duration;
  final bool loop;

  /// توهّج ناعم خلف العلامة — للخلفيات الداكنة والحمراء
  final bool glow;

  @override
  State<AnimatedRvMark> createState() => _AnimatedRvMarkState();
}

class _AnimatedRvMarkState extends State<AnimatedRvMark> with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(vsync: this, duration: widget.duration);
  late final AnimationController _shine = AnimationController(vsync: this, duration: const Duration(milliseconds: 4200));

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (!mounted) return;
      _intro.forward().whenComplete(() {
        if (mounted && widget.loop) _shine.repeat();
      });
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _shine.dispose();
    super.dispose();
  }

  static double _seg(double t, double a, double b, [Curve c = Curves.easeInOutCubic]) =>
      c.transform(((t - a) / (b - a)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final h = widget.width * RvBrand.markH / RvBrand.markW;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_intro, _shine]),
        builder: (context, _) {
          final t = _intro.value;
          final draw = _seg(t, 0, .55);
          final fill = _seg(t, .38, .78, Curves.easeOutCubic);
          final pop = t < .38 ? .94 : .94 + .06 * Curves.easeOutBack.transform(_seg(t, .38, .85, Curves.linear));
          // البريق: مرة في نهاية الدخول، ثم في أول ربع من كل دورة تكرار
          double shine = -1;
          if (t > .74 && t < 1) {
            shine = _seg(t, .74, 1, Curves.easeInOut);
          } else if (_shine.isAnimating && _shine.value < .28) {
            shine = Curves.easeInOut.transform(_shine.value / .28);
          }
          return Transform.scale(
            scale: pop,
            child: Container(
              width: widget.width,
              height: h,
              decoration: widget.glow
                  ? BoxDecoration(boxShadow: [
                      BoxShadow(color: widget.color.withValues(alpha: .18 * fill), blurRadius: widget.width * .35, spreadRadius: -widget.width * .12),
                    ])
                  : null,
              child: CustomPaint(painter: _RvPainter(color: widget.color, draw: draw, fill: fill, shine: shine)),
            ),
          );
        },
      ),
    );
  }
}

class _RvPainter extends CustomPainter {
  _RvPainter({required this.color, required this.draw, required this.fill, required this.shine});
  final Color color;
  final double draw;
  final double fill;

  /// موضع البريق ٠..١ (−١ = لا بريق)
  final double shine;

  @override
  void paint(Canvas canvas, Size size) {
    final path = rvMarkPath(size);

    if (fill > 0) {
      canvas.drawPath(path, Paint()..color = color.withValues(alpha: color.a * fill));
    }

    // الخطّ المرسوم يتلاشى حين تكتمل التعبئة
    final strokeAlpha = draw >= 1 ? (1 - fill) : 1.0;
    if (draw > 0 && strokeAlpha > 0) {
      final stroke = Paint()
        ..color = color.withValues(alpha: color.a * strokeAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.2, size.width * .008)
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round;
      for (final m in path.computeMetrics()) {
        canvas.drawPath(m.extractPath(0, m.length * draw), stroke);
      }
    }

    if (shine >= 0 && fill > .5) {
      canvas.save();
      canvas.clipPath(path);
      final band = size.width * .32;
      final x = -band + (size.width + band * 2) * shine;
      final light = color.computeLuminance() > .5 ? Colors.white : const Color(0xFFFFF1DC);
      final g = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [light.withValues(alpha: 0), light.withValues(alpha: .55), light.withValues(alpha: 0)],
        transform: const GradientRotation(-.35),
      );
      final r = Rect.fromLTWH(x - band / 2, -size.height * .2, band, size.height * 1.4);
      canvas.drawRect(r, Paint()..shader = g.createShader(r));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_RvPainter o) => o.draw != draw || o.fill != fill || o.shine != shine || o.color != color;
}

/// العلامة اللفظية «ريفيوس / RVIOS / للإبداع والتقنية» كما في ملف الهوية.
///
/// [onDark]: للخلفيات الحمراء والداكنة — النص كريمي، والشريط كريمي بنص أحمر.
/// [animate]: دخول متتابع (الاسم العربي يتكشّف من اليمين، ثم RVIOS، ثم الشريط).
class RviosWordmark extends StatefulWidget {
  const RviosWordmark({
    super.key,
    this.width = 220,
    this.onDark = false,
    this.animate = false,
    this.delay = Duration.zero,
    this.showTag = true,
  });

  final double width;
  final bool onDark;
  final bool animate;
  final Duration delay;

  /// شريط «للإبداع والتقنية»
  final bool showTag;

  @override
  State<RviosWordmark> createState() => _RviosWordmarkState();
}

class _RviosWordmarkState extends State<RviosWordmark> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
    value: widget.animate ? 0 : 1,
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      Future.delayed(widget.delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  static double _seg(double t, double a, double b, [Curve c = Curves.easeOutCubic]) =>
      c.transform(((t - a) / (b - a)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final ink = widget.onDark ? RvBrand.cream : RvBrand.red;
    final tagBg = widget.onDark ? RvBrand.cream : RvBrand.red;
    final tagInk = widget.onDark ? RvBrand.red : RvBrand.cream;

    return SizedBox(
      width: widget.width,
      height: widget.width * RvBrand.wordH / RvBrand.wordW,
      child: FittedBox(
        child: SizedBox(
          width: RvBrand.wordW,
          height: RvBrand.wordH,
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              final t = _c.value;
              final ar = _seg(t, 0, .55);
              final en = _seg(t, .3, .72);
              final tag = _seg(t, .5, .82, Curves.easeOutQuart);
              final tagText = _seg(t, .7, 1);
              return Directionality(
                textDirection: TextDirection.ltr,
                child: Stack(clipBehavior: Clip.none, children: [
                  // ريفـيـــوس — يتكشّف من اليمين مع اتجاه الكتابة
                  Positioned(
                    left: 0,
                    right: 0,
                    top: -6,
                    height: 136,
                    child: ClipRect(
                      clipper: _RevealFromRight(ar),
                      child: Opacity(
                        opacity: (ar * 1.4).clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(0, 14 * (1 - ar)),
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: Text(
                              'ريفـيـــوس',
                              textDirection: TextDirection.rtl,
                              style: TextStyle(fontFamily: 'MedadSony', fontSize: 130.52, height: 1.05, color: ink),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // RVIOS
                  Positioned(
                    left: 0,
                    top: 132,
                    width: 366,
                    height: 100,
                    child: Opacity(
                      opacity: en,
                      child: Transform.translate(
                        offset: Offset(-26 * (1 - en), 0),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'RVIOS',
                            style: TextStyle(fontFamily: 'Muslimah', fontSize: 113.84, fontWeight: FontWeight.w300, height: 1, letterSpacing: 6, color: ink),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // شريط «للإبداع والتقنية»
                  if (widget.showTag)
                    Positioned(
                      left: 376.1,
                      top: 150.35,
                      width: 264.55,
                      height: 65.88,
                      child: Transform(
                        alignment: Alignment.centerRight,
                        transform: Matrix4.diagonal3Values(tag, 1, 1),
                        child: Container(
                          color: tagBg,
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                          child: Opacity(
                            opacity: tagText,
                            child: FittedBox(
                              child: Text(
                                'للإبداع والتقنية',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(fontFamily: 'ThmanyahDisplay', fontSize: 43.91, fontWeight: FontWeight.w500, height: 1.1, color: tagInk),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ]),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RevealFromRight extends CustomClipper<Rect> {
  _RevealFromRight(this.p);
  final double p;
  @override
  Rect getClip(Size s) => Rect.fromLTRB(s.width * (1 - p) - 2, -40, s.width + 2, s.height + 40);
  @override
  bool shouldReclip(_RevealFromRight o) => o.p != p;
}
