import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_strings.dart';
import '../../providers/audio_provider.dart';
import '../../providers/recorder_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../editor/editor_screen.dart';

class RecorderScreen extends ConsumerWidget {
  const RecorderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(settingsProvider);
    final state = ref.watch(recorderProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.recorder),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () async {
            if (state.isRecording) {
              await ref.read(recorderProvider.notifier).cancel();
            }
            if (context.mounted) Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              _VuMeter(amplitude: state.amplitude, isActive: state.isRecording),
              const SizedBox(height: 32),
              _Timer(durationMs: state.durationMs, isRunning: state.isRecording),
              const SizedBox(height: 8),
              Text(
                _statusLabel(state),
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const Spacer(),
              _Controls(state: state),
              if (state.isDone && state.filePath != null) ...[
                const SizedBox(height: 20),
                _SendToEditorButton(filePath: state.filePath!),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(RecorderState s) {
    switch (s.status) {
      case RecorderStatus.idle:
        return AppStrings.tapToRecord;
      case RecorderStatus.recording:
        return AppStrings.recordingInProgress;
      case RecorderStatus.paused:
        return AppStrings.recordingPaused;
      case RecorderStatus.done:
        return AppStrings.recordingStopped;
    }
  }
}

// ─── VU Meter

class _VuMeter extends StatelessWidget {
  const _VuMeter({required this.amplitude, required this.isActive});
  final double amplitude;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: CustomPaint(
        painter: _VuPainter(amplitude: amplitude, isActive: isActive),
      ),
    );
  }
}

class _VuPainter extends CustomPainter {
  const _VuPainter({required this.amplitude, required this.isActive});
  final double amplitude;
  final bool isActive;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // Background ring
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()..color = AppColors.surface,
    );

    // Amplitude arc
    if (isActive && amplitude > 0) {
      final sweep = math.pi * 2 * amplitude;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.85),
        -math.pi / 2,
        sweep,
        false,
        Paint()
          ..color = amplitude > 0.8 ? AppColors.accentRecord : AppColors.primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.15
          ..strokeCap = StrokeCap.round,
      );
    }

    // Center mic icon background
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.4,
      Paint()
        ..color = isActive
            ? AppColors.accentRecord.withAlpha(40)
            : AppColors.surfaceVariant,
    );

    // Mic icon (simplified)
    final micPaint = Paint()
      ..color = isActive ? AppColors.accentRecord : AppColors.textSecondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.06
      ..strokeCap = StrokeCap.round;

    // Mic body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy - r * 0.05), width: r * 0.3, height: r * 0.45),
        Radius.circular(r * 0.15),
      ),
      micPaint,
    );
    // Mic stand arm
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy + r * 0.18), width: r * 0.5, height: r * 0.3),
      math.pi,
      math.pi,
      false,
      micPaint,
    );
    // Mic stand base
    canvas.drawLine(
      Offset(cx, cy + r * 0.33),
      Offset(cx, cy + r * 0.42),
      micPaint,
    );
    canvas.drawLine(
      Offset(cx - r * 0.12, cy + r * 0.42),
      Offset(cx + r * 0.12, cy + r * 0.42),
      micPaint,
    );
  }

  @override
  bool shouldRepaint(_VuPainter old) =>
      old.amplitude != amplitude || old.isActive != isActive;
}

// ─── Timer display

class _Timer extends StatelessWidget {
  const _Timer({required this.durationMs, required this.isRunning});
  final int durationMs;
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    final total = Duration(milliseconds: durationMs);
    final m = total.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = total.inSeconds.remainder(60).toString().padLeft(2, '0');
    final ms = ((total.inMilliseconds % 1000) ~/ 10).toString().padLeft(2, '0');

    return Text(
      '$m:$s.$ms',
      style: TextStyle(
        color: isRunning ? AppColors.accentRecord : AppColors.textPrimary,
        fontSize: 52,
        fontWeight: FontWeight.bold,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

// ─── Controls row

class _Controls extends ConsumerWidget {
  const _Controls({required this.state});
  final RecorderState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(recorderProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (state.isRecording || state.isPaused) ...[
          _ControlButton(
            icon: Icons.stop_rounded,
            color: AppColors.textSecondary,
            size: 52,
            onTap: () async {
              await notifier.stop();
            },
          ),
          const SizedBox(width: 24),
          _ControlButton(
            icon: state.isPaused ? Icons.mic_rounded : Icons.pause_rounded,
            color: state.isPaused ? AppColors.primary : AppColors.accentRecord,
            size: 72,
            onTap: () async {
              if (state.isPaused) {
                await notifier.resume();
              } else {
                await notifier.pause();
              }
            },
          ),
        ] else if (state.isDone) ...[
          _ControlButton(
            icon: Icons.refresh_rounded,
            color: AppColors.textSecondary,
            size: 52,
            onTap: () => notifier.reset(),
          ),
        ] else ...[
          _ControlButton(
            icon: Icons.mic_rounded,
            color: AppColors.accentRecord,
            size: 80,
            onTap: () async {
              final ok = await notifier.start();
              if (!ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppStrings.micPermissionRequired)),
                );
              }
            },
          ),
        ],
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.color,
    required this.size,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(icon, color: color, size: size * 0.5),
      ),
    );
  }
}

// ─── Send to editor button

class _SendToEditorButton extends ConsumerWidget {
  const _SendToEditorButton({required this.filePath});
  final String filePath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.edit_rounded),
        label: Text(AppStrings.sendToEditor),
        onPressed: () async {
          final name = filePath.split('/').last;
          await ref
              .read(audioProjectProvider.notifier)
              .loadFile(filePath, name);
          if (context.mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const EditorScreen()),
            );
          }
        },
      ),
    );
  }
}
