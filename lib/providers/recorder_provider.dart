import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/recorder_service.dart';

final recorderServiceProvider = Provider.autoDispose<RecorderService>((ref) {
  final svc = RecorderService();
  ref.onDispose(svc.dispose);
  return svc;
});

enum RecorderStatus { idle, recording, paused, done }

class RecorderState {
  const RecorderState({
    this.status = RecorderStatus.idle,
    this.filePath,
    this.durationMs = 0,
    this.amplitude = 0.0,
  });

  final RecorderStatus status;
  final String? filePath;
  final int durationMs;
  final double amplitude;

  bool get isRecording => status == RecorderStatus.recording;
  bool get isPaused => status == RecorderStatus.paused;
  bool get isDone => status == RecorderStatus.done;

  RecorderState copyWith({
    RecorderStatus? status,
    String? filePath,
    int? durationMs,
    double? amplitude,
  }) =>
      RecorderState(
        status: status ?? this.status,
        filePath: filePath ?? this.filePath,
        durationMs: durationMs ?? this.durationMs,
        amplitude: amplitude ?? this.amplitude,
      );
}

final recorderProvider =
    StateNotifierProvider.autoDispose<RecorderNotifier, RecorderState>((ref) {
  final svc = ref.watch(recorderServiceProvider);
  return RecorderNotifier(svc);
});

class RecorderNotifier extends StateNotifier<RecorderState> {
  RecorderNotifier(this._svc) : super(const RecorderState()) {
    _ampSub = _svc.amplitudeStream.listen((amp) {
      if (!mounted) return;
      final normalized = ((amp.current + 60) / 60).clamp(0.0, 1.0);
      final elapsed = state.isRecording
          ? DateTime.now().millisecondsSinceEpoch - _startMs
          : state.durationMs;
      state = state.copyWith(amplitude: normalized, durationMs: elapsed);
    });
  }

  final RecorderService _svc;
  int _startMs = 0;
  late StreamSubscription<dynamic> _ampSub;

  Future<bool> start() async {
    final hasPermission = await _svc.hasPermission();
    if (!hasPermission) return false;
    await _svc.start();
    _startMs = DateTime.now().millisecondsSinceEpoch;
    state = const RecorderState(status: RecorderStatus.recording);
    return true;
  }

  Future<void> pause() async {
    await _svc.pause();
    state = state.copyWith(status: RecorderStatus.paused);
  }

  Future<void> resume() async {
    await _svc.resume();
    state = state.copyWith(status: RecorderStatus.recording);
  }

  Future<String?> stop() async {
    final path = await _svc.stop();
    state = state.copyWith(status: RecorderStatus.done, filePath: path);
    return path;
  }

  Future<void> cancel() async {
    await _svc.cancel();
    state = const RecorderState();
  }

  void reset() => state = const RecorderState();

  @override
  void dispose() {
    _ampSub.cancel();
    super.dispose();
  }
}
