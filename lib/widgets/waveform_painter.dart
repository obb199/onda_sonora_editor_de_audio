import 'package:flutter/material.dart';
import '../models/audio_track.dart';
import '../models/mixer_project.dart';
import '../theme/app_theme.dart';

/// Draws an audio waveform with optional loop region and cue markers.
class WaveformPainter extends CustomPainter {
  const WaveformPainter({
    required this.samples,
    required this.progress,
    this.loopRegion,
    this.markers = const [],
    this.totalDurationMs = 0,
    this.waveColor = AppColors.waveformColor,
    this.playedColor = AppColors.secondary,
    this.cursorColor = AppColors.textPrimary,
    this.backgroundColor = AppColors.waveformBackground,
  });

  final List<double> samples;
  final double progress;
  final LoopRegion? loopRegion;
  final List<CueMarker> markers;
  final int totalDurationMs;
  final Color waveColor;
  final Color playedColor;
  final Color cursorColor;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.isEmpty) return;

    // Background
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12)),
      Paint()..color = backgroundColor,
    );

    // Loop region highlight
    if (loopRegion != null && totalDurationMs > 0) {
      final startX = size.width * (loopRegion!.startMs / totalDurationMs);
      final endX = size.width * (loopRegion!.endMs / totalDurationMs);
      canvas.drawRect(
        Rect.fromLTWH(startX, 0, endX - startX, size.height),
        Paint()..color = AppColors.secondary.withAlpha(25),
      );
      // Loop region borders
      final borderPaint = Paint()
        ..color = AppColors.secondary.withAlpha(120)
        ..strokeWidth = 1.5;
      canvas.drawLine(Offset(startX, 0), Offset(startX, size.height), borderPaint);
      canvas.drawLine(Offset(endX, 0), Offset(endX, size.height), borderPaint);
    }

    // Waveform bars
    final barWidth = size.width / samples.length;
    final cursorX = size.width * progress;

    final playedPaint = Paint()
      ..color = playedColor
      ..strokeWidth = barWidth * 0.6
      ..strokeCap = StrokeCap.round;
    final unplayedPaint = Paint()
      ..color = waveColor.withAlpha(160)
      ..strokeWidth = barWidth * 0.6
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < samples.length; i++) {
      final x = i * barWidth + barWidth / 2;
      final amp = (samples[i]).clamp(0.0, 1.0);
      final halfH = amp * size.height * 0.45;
      final cy = size.height / 2;
      final paint = x <= cursorX ? playedPaint : unplayedPaint;
      canvas.drawLine(Offset(x, cy - halfH), Offset(x, cy + halfH), paint);
    }

    // Cue markers
    if (totalDurationMs > 0) {
      for (final m in markers) {
        final x = size.width * (m.timeMs / totalDurationMs);
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, size.height),
          Paint()
            ..color = AppColors.accent.withAlpha(200)
            ..strokeWidth = 1.5,
        );
        // Small flag
        final flagPath = Path()
          ..moveTo(x, 2)
          ..lineTo(x + 10, 6)
          ..lineTo(x, 10)
          ..close();
        canvas.drawPath(flagPath, Paint()..color = AppColors.accent);
      }
    }

    // Cursor
    canvas.drawLine(
      Offset(cursorX, 4),
      Offset(cursorX, size.height - 4),
      Paint()..color = cursorColor..strokeWidth = 2,
    );
    final path = Path()
      ..moveTo(cursorX - 6, 0)
      ..lineTo(cursorX + 6, 0)
      ..lineTo(cursorX, 10)
      ..close();
    canvas.drawPath(path, Paint()..color = cursorColor);
  }

  @override
  bool shouldRepaint(WaveformPainter old) =>
      old.progress != progress ||
      old.samples != samples ||
      old.loopRegion != loopRegion ||
      old.markers != markers;
}

/// Interactive waveform widget with seek, loop region and marker rendering.
class WaveformView extends StatelessWidget {
  const WaveformView({
    super.key,
    required this.samples,
    required this.progress,
    this.onSeek,
    this.height = 100,
    this.loopRegion,
    this.markers = const [],
    this.totalDurationMs = 0,
  });

  final List<double> samples;
  final double progress;
  final ValueChanged<double>? onSeek;
  final double height;
  final LoopRegion? loopRegion;
  final List<CueMarker> markers;
  final int totalDurationMs;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (d) => _seek(d.localPosition.dx, context),
      onHorizontalDragUpdate: (d) => _seek(d.localPosition.dx, context),
      child: SizedBox(
        height: height,
        child: CustomPaint(
          painter: WaveformPainter(
            samples: samples,
            progress: progress,
            loopRegion: loopRegion,
            markers: markers,
            totalDurationMs: totalDurationMs,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }

  void _seek(double dx, BuildContext context) {
    if (onSeek == null) return;
    final box = context.findRenderObject() as RenderBox;
    final p = (dx / box.size.width).clamp(0.0, 1.0);
    onSeek!(p);
  }
}
