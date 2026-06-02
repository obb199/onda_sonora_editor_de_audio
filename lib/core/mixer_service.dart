import 'dart:io';
import 'dart:math' as math;
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';
import '../models/audio_track.dart';
import 'ffmpeg_service.dart';

/// Mixes multiple AudioTracks into a single file using FFmpeg's amix filter.
class MixerService {
  MixerService._();
  static final MixerService instance = MixerService._();

  Future<String> _outputDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final out = Directory('${dir.path}/onda_sonora/exports');
    if (!out.existsSync()) out.createSync(recursive: true);
    return out.path;
  }

  /// Mixes [tracks] into a single file. Returns the output path.
  Future<String> mixTracks({
    required List<AudioTrack> tracks,
    ExportFormat format = ExportFormat.wav,
    ExportQuality quality = ExportQuality.high,
  }) async {
    if (tracks.isEmpty) throw Exception('No active tracks to mix');

    final outDir = await _outputDir();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final ext = format.name;
    final outputPath = '$outDir/mix_$ts.$ext';

    if (tracks.length == 1) {
      return _processSingleTrack(tracks.first, outputPath, format, quality);
    }

    final inputs = tracks.map((t) => '-i "${t.filePath}"').join(' ');
    final n = tracks.length;
    final filterParts = <String>[];
    final mixInputs = <String>[];

    for (var i = 0; i < tracks.length; i++) {
      final t = tracks[i];
      final outLabel = '[a$i]';
      final effectChain = FfmpegService.instance.buildFilterChainPublic(t.effects);

      final volDb = _linearToDb(t.volume.clamp(0.001, 2.0));
      final panL = ((1.0 - t.pan) / 2).clamp(0.0, 1.0);
      final panR = ((1.0 + t.pan) / 2).clamp(0.0, 1.0);

      final parts = <String>[];
      if (t.offsetMs > 0) parts.add('adelay=${t.offsetMs}|${t.offsetMs}');
      if (effectChain.isNotEmpty) parts.add(effectChain);
      parts.add('volume=${volDb.toStringAsFixed(1)}dB');
      parts.add('pan=stereo|c0=${panL.toStringAsFixed(3)}*c0|c1=${panR.toStringAsFixed(3)}*c1');

      filterParts.add('[$i:a]${parts.join(',')}$outLabel');
      mixInputs.add(outLabel);
    }

    final filterGraph =
        '${filterParts.join(';')};${mixInputs.join('')}amix=inputs=$n:duration=longest[mixout]';
    final codec = _codecFor(format, quality);
    final cmd = '-y $inputs -filter_complex "$filterGraph" -map "[mixout]" $codec "$outputPath"';

    final session = await FFmpegKit.execute(cmd);
    final rc = await session.getReturnCode();
    if (!ReturnCode.isSuccess(rc)) {
      final logs = await session.getAllLogsAsString();
      throw Exception('Mix failed: $logs');
    }
    return outputPath;
  }

  Future<String> _processSingleTrack(
    AudioTrack track,
    String outputPath,
    ExportFormat format,
    ExportQuality quality,
  ) async {
    final effects = FfmpegService.instance.buildFilterChainPublic(track.effects);
    final filterArg = effects.isNotEmpty ? '-af "$effects"' : '';
    final codec = _codecFor(format, quality);
    final cmd = '-y -i "${track.filePath}" $filterArg $codec "$outputPath"';
    final session = await FFmpegKit.execute(cmd);
    final rc = await session.getReturnCode();
    if (!ReturnCode.isSuccess(rc)) {
      final logs = await session.getAllLogsAsString();
      throw Exception('Process failed: $logs');
    }
    return outputPath;
  }

  double _linearToDb(double linear) =>
      linear <= 0 ? -100 : 20 * math.log(linear) / math.log(10);

  String _codecFor(ExportFormat format, ExportQuality quality) {
    switch (format) {
      case ExportFormat.mp3:
        final q = quality == ExportQuality.high ? '0' : quality == ExportQuality.medium ? '3' : '6';
        return '-c:a libmp3lame -q:a $q';
      case ExportFormat.wav:
        return '-c:a pcm_s16le';
      case ExportFormat.flac:
        return '-c:a flac';
    }
  }
}
