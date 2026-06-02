import 'dart:async';
import 'package:just_audio/just_audio.dart';

/// Wraps just_audio and exposes live-preview controls:
/// speed, pitch, and volume change instantaneously while the audio plays.
class AudioPlayerService {
  AudioPlayerService() : _player = AudioPlayer();

  final AudioPlayer _player;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  Duration get position => _player.position;
  Duration? get duration => _player.duration;
  bool get isPlaying => _player.playing;
  ProcessingState get processingState => _player.processingState;

  Future<void> load(String filePath) async {
    await _player.setFilePath(filePath);
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> stop() async {
    await _player.stop();
    await _player.seek(Duration.zero);
  }

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> setSpeed(double speed) => _player.setSpeed(speed.clamp(0.25, 4.0));
  Future<void> setPitch(double pitch) => _player.setPitch(pitch.clamp(0.5, 2.0));
  Future<void> setVolume(double volume) => _player.setVolume(volume.clamp(0.0, 1.0));

  Future<void> setLoopMode(LoopMode mode) => _player.setLoopMode(mode);

  Future<void> dispose() async {
    await _player.dispose();
  }
}
