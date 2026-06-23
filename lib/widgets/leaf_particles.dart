import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Floating olive-leaf particles that drift across the screen.
class LeafParticles extends StatefulWidget {
  final Widget child;
  const LeafParticles({super.key, required this.child});

  @override
  State<LeafParticles> createState() => _LeafParticlesState();
}

class _LeafParticlesState extends State<LeafParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Leaf> _leaves;
  final _rand = math.Random(42);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 12))
      ..repeat();
    _leaves = List.generate(14, (i) => _Leaf(_rand, i));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => CustomPaint(
                painter: _LeafPainter(_leaves, _ctrl.value),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Leaf {
  final double startX;
  final double startY;
  final double speed;
  final double size;
  final double phase;
  final double drift;
  final double rotSpeed;

  _Leaf(math.Random r, int seed)
      : startX   = r.nextDouble(),
        startY   = r.nextDouble(),
        speed    = 0.04 + r.nextDouble() * 0.06,
        size     = 6 + r.nextDouble() * 10,
        phase    = r.nextDouble() * math.pi * 2,
        drift    = (r.nextDouble() - 0.5) * 0.12,
        rotSpeed = (r.nextDouble() - 0.5) * 3;
}

class _LeafPainter extends CustomPainter {
  final List<_Leaf> leaves;
  final double t;
  _LeafPainter(this.leaves, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final leaf in leaves) {
      final progress = (t * leaf.speed + leaf.phase / (math.pi * 2)) % 1.0;
      final x = (leaf.startX + math.sin(progress * math.pi * 2 + leaf.phase) * leaf.drift) * size.width;
      final y = (leaf.startY + progress * 1.2 - 0.1) * size.height;

      if (y < -20 || y > size.height + 20) continue;

      final opacity = (0.12 + 0.18 * math.sin(progress * math.pi)).clamp(0.0, 1.0);
      final rotation = progress * math.pi * 2 * leaf.rotSpeed + leaf.phase;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      _drawLeaf(canvas, leaf.size, opacity);

      canvas.restore();
    }
  }

  void _drawLeaf(Canvas canvas, double size, double opacity) {
    final paint = Paint()
      ..color = const Color(0xFFAFB796).withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, -size)
      ..cubicTo(size * 0.6, -size * 0.6, size * 0.6, size * 0.2, 0, size * 0.5)
      ..cubicTo(-size * 0.6, size * 0.2, -size * 0.6, -size * 0.6, 0, -size);

    canvas.drawPath(path, paint);

    // Leaf vein
    final veinPaint = Paint()
      ..color = const Color(0xFF2E3A2E).withValues(alpha: opacity * 0.5)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, -size * 0.8), Offset(0, size * 0.4), veinPaint);
  }

  @override
  bool shouldRepaint(_LeafPainter old) => old.t != t;
}
