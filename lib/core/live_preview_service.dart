import 'dart:async';
import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:just_audio/just_audio.dart' hide AudioEffect;
import 'package:path_provider/path_provider.dart';
import '../models/audio_effect.dart';
import 'ffmpeg_service.dart';

/// Provides debounced FFmpeg-based live previews of the full effects chain.
///
/// When the user adjusts any effect slider the preview re-renders a short clip
/// (default 8 s) in the background and auto-plays it so the user hears the
/// result within ~1-2 s on a modern device.
class LivePreviewService {
  LivePreviewService._();
  static final LivePreviewService instance = LivePreviewService._();

  final AudioPlayer _previewPlayer = AudioPlayer();
  Timer? _debounce;
  bool _isRendering = false;
  String? _sourcePath;
  Duration _previewStart = Duration.zero;
  double _previewDurationSec = 8.0;

  final _stateController = StreamController<LivePreviewState>.broadcast();
  Stream<LivePreviewState> get stateStream => _stateController.stream;
  LivePreviewState _state = LivePreviewState.idle;

  LivePreviewState get state => _state;
  bool get isRendering => _isRendering;

  void configure({
    required String sourcePath,
    double previewDurationSec = 8.0,
  }) {
    _sourcePath = sourcePath;
    _previewDurationSec = previewDurationSec.clamp(3.0, 30.0);
  }

  /// Call whenever an effect parameter changes. Debounces 600 ms before rendering.
  void schedulePreview({
    required List<AudioEffect> effects,
    Duration fromPosition = Duration.zero,
  }) {
    if (_sourcePath == null) return;
    _previewStart = fromPosition;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      _render(effects);
    });
  }

  void setPreviewStart(Duration position) {
    _previewStart = position;
  }

  Future<void> _render(List<AudioEffect> effects) async {
    if (_sourcePath == null || _isRendering) return;
    _isRendering = true;
    _emit(LivePreviewState.rendering);

    try {
      final tmp = (await getTemporaryDirectory()).path;
      final outPath = '$tmp/onda_live_preview.wav';
      final startSec = _previewStart.inSeconds;
      final filters = FfmpegService.instance.buildFilterChainPublic(effects);
      final filterArg = filters.isNotEmpty ? '-af "$filters"' : '';

      final cmd = '-y -i "$_sourcePath" -ss $startSec -t $_previewDurationSec '
          '$filterArg -c:a pcm_s16le "$outPath"';

      final session = await FFmpegKit.execute(cmd);
      final rc = await session.getReturnCode();

      if (ReturnCode.isSuccess(rc) && File(outPath).existsSync()) {
        await _previewPlayer.stop();
        await _previewPlayer.setFilePath(outPath);
        await _previewPlayer.play();
        _emit(LivePreviewState.playing);
      } else {
        _emit(LivePreviewState.error);
      }
    } catch (_) {
      _emit(LivePreviewState.error);
    } finally {
      _isRendering = false;
    }
  }

  void stopPreview() {
    _debounce?.cancel();
    _previewPlayer.stop();
    _emit(LivePreviewState.idle);
  }

  void _emit(LivePreviewState s) {
    _state = s;
    _stateController.add(s);
  }

  Future<void> dispose() async {
    _debounce?.cancel();
    await _previewPlayer.dispose();
    await _stateController.close();
  }
}

enum LivePreviewState { idle, rendering, playing, error }
