import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Animated frequency-bar visualizer.
/// In production, feed real FFT magnitudes; here uses animated mock data.
class FrequencyVisualizer extends StatefulWidget {
  const FrequencyVisualizer({
    super.key,
    this.barCount = 32,
    this.height = 64,
    this.isActive = false,
  });

  final int barCount;
  final double height;
  final bool isActive;

  @override
  State<FrequencyVisualizer> createState() => _FrequencyVisualizerState();
}

class _FrequencyVisualizerState extends State<FrequencyVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _rng = math.Random();
  late List<double> _targets;
  late List<double> _current;

  @override
  void initState() {
    super.initState();
    _targets = List.filled(widget.barCount, 0.1);
    _current = List.filled(widget.barCount, 0.1);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..addListener(_updateBars);

    if (widget.isActive) _controller.repeat();
  }

  void _updateBars() {
    if (!widget.isActive) return;
    setState(() {
      for (var i = 0; i < widget.barCount; i++) {
        // Drift toward target with some smoothing
        _current[i] += (_targets[i] - _current[i]) * 0.25;
        // Occasionally update target
        if (_rng.nextDouble() < 0.15) {
          final freq = i / widget.barCount;
          // Simulate spectral shape (more energy in lows/mids)
          final base = freq < 0.3 ? 0.6 : (freq < 0.7 ? 0.4 : 0.2);
          _targets[i] = (base + _rng.nextDouble() * 0.5).clamp(0.05, 1.0);
        }
      }
    });
  }

  @override
  void didUpdateWidget(FrequencyVisualizer old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isActive) {
      _controller.stop();
      setState(() {
        for (var i = 0; i < widget.barCount; i++) {
          _current[i] = 0.05;
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: CustomPaint(
        painter: _FreqPainter(bars: _current),
        size: Size.infinite,
      ),
    );
  }
}

class _FreqPainter extends CustomPainter {
  const _FreqPainter({required this.bars});
  final List<double> bars;

  @override
  void paint(Canvas canvas, Size size) {
    final n = bars.length;
    final barW = size.width / n;
    final gap = barW * 0.2;

    for (var i = 0; i < n; i++) {
      final t = i / n;
      final color = Color.lerp(
        AppColors.primary,
        AppColors.secondary,
        t,
      )!;

      final h = (bars[i] * size.height).clamp(4.0, size.height);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          i * barW + gap / 2,
          size.height - h,
          barW - gap,
          h,
        ),
        const Radius.circular(3),
      );

      canvas.drawRRect(rect, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_FreqPainter old) => old.bars != bars;
}
