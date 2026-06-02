import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../core/audio_player_service.dart';
import '../models/audio_project.dart';

// ─── Player service singleton
final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  ref.onDispose(service.dispose);
  return service;
});

// ─── Current project
final audioProjectProvider =
    StateNotifierProvider<AudioProjectNotifier, AudioProject?>(
  (ref) => AudioProjectNotifier(ref),
);

class AudioProjectNotifier extends StateNotifier<AudioProject?> {
  AudioProjectNotifier(this._ref) : super(null);

  final Ref _ref;

  AudioPlayerService get _player =>
      _ref.read(audioPlayerServiceProvider);

  Future<void> loadFile(String path, String name) async {
    try {
      await _player.load(path);
      final duration = _player.duration ?? Duration.zero;
      state = AudioProject(
        filePath: path,
        fileName: name,
        duration: duration,
      );
    } catch (e) {
      state = null;
      rethrow;
    }
  }

  Future<void> setSpeed(double speed) async {
    if (state == null) return;
    await _player.setSpeed(speed);
    state = state!.copyWith(speed: speed);
  }

  Future<void> setPitch(double pitch) async {
    if (state == null) return;
    await _player.setPitch(pitch);
    state = state!.copyWith(pitch: pitch);
  }

  Future<void> setVolume(double volume) async {
    if (state == null) return;
    await _player.setVolume(volume);
    state = state!.copyWith(volume: volume);
  }

  void addEffect(dynamic effect) {
    if (state == null) return;
    state = state!.withEffect(effect);
  }

  void updateEffect(int index, dynamic updated) {
    if (state == null) return;
    state = state!.updateEffect(index, updated);
  }

  void removeEffect(int index) {
    if (state == null) return;
    state = state!.removeEffect(index);
  }

  void undo() {
    if (state == null) return;
    state = state!.undo();
  }

  void redo() {
    if (state == null) return;
    state = state!.redo();
  }

  void close() {
    state = null;
  }
}

// ─── Playback state streams
final playerStateProvider = StreamProvider<PlayerState>((ref) {
  final player = ref.watch(audioPlayerServiceProvider);
  return player.playerStateStream;
});

final positionProvider = StreamProvider<Duration>((ref) {
  final player = ref.watch(audioPlayerServiceProvider);
  return player.positionStream;
});

final durationProvider = StreamProvider<Duration?>((ref) {
  final player = ref.watch(audioPlayerServiceProvider);
  return player.durationStream;
});

// ─── Waveform samples (mock — real extraction via ffmpeg or audio_waveforms)
final waveformSamplesProvider = FutureProvider.family<List<double>, String>(
  (ref, filePath) async {
    // Simulate waveform extraction with pseudo-random data.
    // Replace with real PCM extraction in production.
    await Future.delayed(const Duration(milliseconds: 300));
    final samples = <double>[];
    double phase = 0;
    for (var i = 0; i < 200; i++) {
      phase += 0.15;
      samples.add(
        0.3 * (1 + (i % 7 == 0 ? 1.5 : 0.5)) * (0.5 + 0.5 * _sin(phase)),
      );
    }
    return samples;
  },
);

double _sin(double x) {
  // Cheap sine approximation
  final b = 4.0 / 3.14159265;
  final c = -4.0 / (3.14159265 * 3.14159265);
  final y = b * x + c * x * (x < 0 ? -x : x);
  return 0.225 * (y * (y < 0 ? -y : y) - y) + y;
}
