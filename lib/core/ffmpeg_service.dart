import 'dart:io';
import 'dart:math' as math;
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/audio_effect.dart';

enum ExportFormat { mp3, wav, flac }

enum ExportQuality { high, medium, low }

/// Builds and executes FFmpeg commands for offline effects and export.
class FfmpegService {
  FfmpegService._();

  static final FfmpegService instance = FfmpegService._();

  Future<String> _tempDir() async {
    final dir = await getTemporaryDirectory();
    return dir.path;
  }

  Future<String> _outputDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final out = Directory('${dir.path}/onda_sonora/exports');
    if (!out.existsSync()) out.createSync(recursive: true);
    return out.path;
  }

  /// Applies all enabled effects and exports to [format].
  /// Returns the output file path on success, throws on failure.
  Future<String> applyAndExport({
    required String inputPath,
    required List<AudioEffect> effects,
    required ExportFormat format,
    required ExportQuality quality,
    void Function(double progress)? onProgress,
  }) async {
    final filterChain = _buildFilterChain(effects);
    final codec = _codecFor(format, quality);
    final outDir = await _outputDir();
    final baseName = _baseName(inputPath);
    final ext = format.name;
    final outputPath = '$outDir/${baseName}_onda.$ext';

    final filterArg = filterChain.isNotEmpty ? '-af "$filterChain"' : '';

    final cmd = '-y -i "$inputPath" $filterArg $codec "$outputPath"';

    final session = await FFmpegKit.execute(cmd);
    final returnCode = await session.getReturnCode();

    if (!ReturnCode.isSuccess(returnCode)) {
      final logs = await session.getAllLogsAsString();
      throw Exception('FFmpeg failed: $logs');
    }

    return outputPath;
  }

  /// Preview-only: applies a single effect to a temp file for quick audition.
  Future<String?> previewEffect({
    required String inputPath,
    required AudioEffect effect,
  }) async {
    final filter = _filterForEffect(effect);
    if (filter == null) return null;

    final tmp = await _tempDir();
    final outputPath = '$tmp/preview_${effect.type.name}.wav';

    final cmd = '-y -i "$inputPath" -af "$filter" -c:a pcm_s16le "$outputPath"';
    final session = await FFmpegKit.execute(cmd);
    final rc = await session.getReturnCode();
    return ReturnCode.isSuccess(rc) ? outputPath : null;
  }

  String _buildFilterChain(List<AudioEffect> effects) =>
      buildFilterChainPublic(effects);

  /// Public entry point used by LivePreviewService.
  String buildFilterChainPublic(List<AudioEffect> effects) {
    final filters = effects
        .where((e) => e.enabled)
        .map(_filterForEffect)
        .whereType<String>()
        .toList();
    return filters.join(',');
  }

  /// Exposed for unit testing. Do not call in production code.
  @visibleForTesting
  String? filterForEffect(AudioEffect effect) => _filterForEffect(effect);

  String? _filterForEffect(AudioEffect effect) {
    final p = effect.parameters;
    switch (effect.type) {
      case EffectType.reverb:
        final wet = (p['wetness'] ?? 0.3);
        final room = (p['roomSize'] ?? 0.5) * 1000;
        final fb = p['feedback'] ?? 0.4;
        return 'aecho=0.8:${wet.toStringAsFixed(1)}:${room.toInt()}:${fb.toStringAsFixed(1)}';

      case EffectType.delay:
        final ms = (p['delayMs'] ?? 500).toInt();
        final fb = p['feedback'] ?? 0.5;
        final wet = p['wetness'] ?? 0.4;
        return 'aecho=0.8:${wet.toStringAsFixed(1)}:$ms:${fb.toStringAsFixed(1)}';

      case EffectType.equalizer:
        final bass = p['bass'] ?? 0.0;
        final mid = p['mid'] ?? 0.0;
        final treble = p['treble'] ?? 0.0;
        final parts = <String>[];
        if (bass != 0.0) parts.add('equalizer=f=100:width_type=o:g=${bass.toStringAsFixed(1)}');
        if (mid != 0.0) parts.add('equalizer=f=1000:width_type=o:g=${mid.toStringAsFixed(1)}');
        if (treble != 0.0) parts.add('equalizer=f=8000:width_type=o:g=${treble.toStringAsFixed(1)}');
        return parts.isEmpty ? null : parts.join(',');

      case EffectType.distortion:
        final drive = ((p['drive'] ?? 0.3) * 40 + 10).toInt();
        return 'acrusher=level_in=$drive:level_out=1:bits=8:mode=log:aa=1';

      case EffectType.chorus:
        final depth = (p['depth'] ?? 0.5) * 0.03;
        final rate = p['rate'] ?? 1.0;
        return 'chorus=0.7:0.9:${(rate * 50).toInt()}:${depth.toStringAsFixed(3)}:${(rate * 0.25).toStringAsFixed(3)}:s';

      case EffectType.flanger:
        final depth = ((p['depth'] ?? 0.5) * 10).toStringAsFixed(1);
        final rate = (p['rate'] ?? 0.5).toStringAsFixed(1);
        return 'flanger=delay=5:depth=$depth:speed=$rate:shape=sinusoidal';

      case EffectType.phaser:
        final rate = (p['rate'] ?? 0.5).toStringAsFixed(1);
        final depth = ((p['depth'] ?? 0.5) * 0.9 + 0.1).toStringAsFixed(1);
        return 'aphaser=type=q:speed=$rate:decay=$depth';

      case EffectType.bitcrusher:
        final bits = (p['bits'] ?? 8.0).toInt().clamp(1, 16);
        return 'acrusher=bits=$bits:mode=log:aa=1';

      case EffectType.lowPass:
        final cutoff = (p['cutoff'] ?? 3000.0).toInt();
        return 'lowpass=f=$cutoff';

      case EffectType.highPass:
        final cutoff = (p['cutoff'] ?? 200.0).toInt();
        return 'highpass=f=$cutoff';

      case EffectType.normalize:
        final lufs = (p['targetLufs'] ?? -14.0).toStringAsFixed(1);
        return 'loudnorm=I=$lufs:LRA=7:TP=-2';

      case EffectType.reverse:
        return 'areverse';

      case EffectType.fadeIn:
        final dur = (p['durationSec'] ?? 2.0).toStringAsFixed(1);
        return 'afade=t=in:d=$dur';

      case EffectType.fadeOut:
        final dur = (p['durationSec'] ?? 2.0).toStringAsFixed(1);
        return 'afade=t=out:d=$dur';

      case EffectType.compressor:
        final thr = (p['threshold'] ?? -20.0).toStringAsFixed(1);
        final ratio = (p['ratio'] ?? 4.0).toStringAsFixed(1);
        return 'acompressor=threshold=${_dbToLinear(double.parse(thr))}:ratio=$ratio:attack=200:release=1000';
    }
  }

  double _dbToLinear(double db) => (db <= -80) ? 0.0 : math.pow(10.0, db / 20.0).toDouble();

  String _codecFor(ExportFormat format, ExportQuality quality) {
    switch (format) {
      case ExportFormat.mp3:
        final q = quality == ExportQuality.high
            ? '0'
            : quality == ExportQuality.medium
                ? '3'
                : '6';
        return '-c:a libmp3lame -q:a $q';
      case ExportFormat.wav:
        return '-c:a pcm_s16le';
      case ExportFormat.flac:
        return '-c:a flac';
    }
  }

  String _baseName(String path) {
    final name = path.split('/').last;
    final dot = name.lastIndexOf('.');
    return dot > 0 ? name.substring(0, dot) : name;
  }
}
