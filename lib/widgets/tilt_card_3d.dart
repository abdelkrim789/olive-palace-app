import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A card that tilts in 3D in response to touch position — igloo.inc style.
class TiltCard3D extends StatefulWidget {
  final Widget child;
  final double maxTilt;
  final BorderRadius? borderRadius;

  const TiltCard3D({
    super.key,
    required this.child,
    this.maxTilt = 0.25,
    this.borderRadius,
  });

  @override
  State<TiltCard3D> createState() => _TiltCard3DState();
}

class _TiltCard3DState extends State<TiltCard3D>
    with SingleTickerProviderStateMixin {
  double _rotX = 0;
  double _rotY = 0;
  double _glowX = 0.5;
  double _glowY = 0.3;

  late final AnimationController _reset;
  late Animation<double> _rotXAnim;
  late Animation<double> _rotYAnim;

  @override
  void initState() {
    super.initState();
    _reset = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _reset.dispose();
    super.dispose();
  }

  void _onPointerMove(PointerMoveEvent e, Size size) {
    final nx = (e.localPosition.dx / size.width).clamp(0.0, 1.0);
    final ny = (e.localPosition.dy / size.height).clamp(0.0, 1.0);
    setState(() {
      _rotX = (ny - 0.5) * -widget.maxTilt;
      _rotY = (nx - 0.5) *  widget.maxTilt;
      _glowX = nx;
      _glowY = ny;
    });
  }

  void _onPointerUp() {
    _rotXAnim = Tween(begin: _rotX, end: 0.0).animate(
      CurvedAnimation(parent: _reset, curve: Curves.elasticOut),
    );
    _rotYAnim = Tween(begin: _rotY, end: 0.0).animate(
      CurvedAnimation(parent: _reset, curve: Curves.elasticOut),
    );
    _reset
      ..reset()
      ..forward().then((_) {
        if (mounted) setState(() { _rotX = 0; _rotY = 0; });
      });
    _reset.addListener(() {
      if (mounted) setState(() {
        _rotX = _rotXAnim.value;
        _rotY = _rotYAnim.value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final br = widget.borderRadius ?? BorderRadius.circular(20);
    return LayoutBuilder(builder: (context, constraints) {
      final size = Size(constraints.maxWidth, constraints.maxHeight);
      return Listener(
        onPointerMove: (e) => _onPointerMove(e, size),
        onPointerUp:   (_) => _onPointerUp(),
        onPointerCancel: (_) => _onPointerUp(),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_rotX)
            ..rotateY(_rotY),
          child: Stack(
            children: [
              ClipRRect(borderRadius: br, child: widget.child),
              // Gloss overlay follows touch position
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: br,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(
                            (_glowX - 0.5) * 2,
                            (_glowY - 0.5) * 2,
                          ),
                          radius: 0.8,
                          colors: [
                            Colors.white.withAlpha(40),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
