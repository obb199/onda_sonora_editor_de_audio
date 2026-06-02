import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Onda Sonora logo — a stylized sound-wave emanating from a central dot.
/// Drawn entirely with Flutter's Canvas API (no external image files needed).
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 64, this.showLabel = false});

  final double size;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size(size, size),
          painter: _LogoPainter(),
        ),
        if (showLabel) ...[
          const SizedBox(height: 8),
          Text(
            'Onda Sonora',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: size * 0.25,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ],
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // Background circle
    final bgPaint = Paint()
      ..shader = const RadialGradient(
        colors: [AppColors.primaryDark, AppColors.background],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawCircle(Offset(cx, cy), r, bgPaint);

    // Sound waves — concentric arcs on both sides
    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.035;

    for (var side in [-1, 1]) {
      for (var i = 1; i <= 3; i++) {
        final alpha = (1.0 - (i - 1) * 0.28).clamp(0.0, 1.0);
        wavePaint.color = Color.fromRGBO(
          0x00,
          0xE5,
          0xFF,
          alpha * 0.9,
        );

        final waveR = r * (0.2 + i * 0.16);
        final startAngle = side == -1
            ? math.pi + math.pi * 0.25
            : -math.pi * 0.25;
        final sweep = math.pi * 0.5;

        final rect = Rect.fromCircle(
          center: Offset(cx, cy),
          radius: waveR,
        );

        canvas.drawArc(rect, startAngle, sweep, false, wavePaint);
      }
    }

    // Center dot (primary)
    final dotPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.primary, AppColors.secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.18));
    canvas.drawCircle(Offset(cx, cy), r * 0.18, dotPaint);

    // Highlight on dot
    final hlPaint = Paint()
      ..color = Colors.white.withAlpha(80)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(cx - r * 0.06, cy - r * 0.06),
      r * 0.07,
      hlPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Animated version of the logo that pulses while audio is playing.
class AnimatedAppLogo extends StatefulWidget {
  const AnimatedAppLogo({super.key, this.size = 64, this.isAnimating = false});

  final double size;
  final bool isAnimating;

  @override
  State<AnimatedAppLogo> createState() => _AnimatedAppLogoState();
}

class _AnimatedAppLogoState extends State<AnimatedAppLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(AnimatedAppLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isAnimating) {
      _controller.stop();
      _controller.value = 0.5;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, child) => Transform.scale(
        scale: widget.isAnimating ? _pulse.value : 1.0,
        child: child,
      ),
      child: AppLogo(size: widget.size),
    );
  }
}
