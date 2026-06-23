import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A GPU-drawn 3D-looking olive sphere with a rotating ring and gentle float.
class OliveOrb extends StatefulWidget {
  final double size;
  const OliveOrb({super.key, this.size = 220});

  @override
  State<OliveOrb> createState() => _OliveOrbState();
}

class _OliveOrbState extends State<OliveOrb> with TickerProviderStateMixin {
  late final AnimationController _spin;
  late final AnimationController _float;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _spin  = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();
    _float = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _spin.dispose();
    _float.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return AnimatedBuilder(
      animation: Listenable.merge([_spin, _float, _pulse]),
      builder: (_, __) {
        final floatY = math.sin(_float.value * math.pi) * 14;
        final scale  = 1.0 + _pulse.value * 0.04;
        return Transform.translate(
          offset: Offset(0, floatY),
          child: Transform.scale(
            scale: scale,
            child: SizedBox(
              width: s,
              height: s,
              child: CustomPaint(painter: _OrbPainter(_spin.value)),
            ),
          ),
        );
      },
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double t;
  _OrbPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width / 2;

    // ── Outer glow ──────────────────────────────────────────────────────────
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF6A7562).withAlpha(80),
          Colors.transparent,
        ],
        stops: const [0.6, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r * 1.3))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawCircle(Offset(cx, cy), r * 1.3, glowPaint);

    // ── Main sphere ──────────────────────────────────────────────────────────
    final spherePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.4),
        radius: 0.9,
        colors: const [
          Color(0xFF5A6E50),
          Color(0xFF2E3A2E),
          Color(0xFF1A2418),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawCircle(Offset(cx, cy), r, spherePaint);

    // ── Specular highlight (top-left glossy spot) ────────────────────────────
    final highlightPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.5, -0.55),
        radius: 0.45,
        colors: [
          Colors.white.withAlpha(100),
          Colors.white.withAlpha(0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawCircle(Offset(cx, cy), r, highlightPaint);

    // ── Rotating elliptical ring (equator) ───────────────────────────────────
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(t * math.pi * 2 * 0.3);

    final ringRect = Rect.fromCenter(
      center: Offset.zero,
      width: r * 1.9,
      height: r * 0.55,
    );
    final ringPaint = Paint()
      ..color = const Color(0xFFAFB796).withAlpha(180)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawOval(ringRect, ringPaint);

    // Small olive dots on the ring
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * math.pi * 2 + t * math.pi * 2 * 0.3;
      final dx    = math.cos(angle) * r * 0.95;
      final dy    = math.sin(angle) * r * 0.275;
      canvas.drawCircle(
        Offset(dx, dy),
        3.5,
        Paint()..color = const Color(0xFFDAB79F).withAlpha(220),
      );
    }
    canvas.restore();

    // ── Second inner ring (tilted opposite) ──────────────────────────────────
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(-t * math.pi * 2 * 0.15 + math.pi / 5);

    final ring2Paint = Paint()
      ..color = const Color(0xFF6A7562).withAlpha(100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: r * 1.4, height: r * 0.38),
      ring2Paint,
    );
    canvas.restore();

    // ── Rim light (bottom-right subtle highlight) ────────────────────────────
    final rimPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.7, 0.7),
        radius: 0.5,
        colors: [
          const Color(0xFFAFB796).withAlpha(60),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawCircle(Offset(cx, cy), r, rimPaint);
  }

  @override
  bool shouldRepaint(_OrbPainter old) => old.t != t;
}
