import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/audio_track.dart';
import '../models/mixer_project.dart';

const _uuid = Uuid();

final mixerProvider =
    StateNotifierProvider<MixerNotifier, MixerProject>((ref) => MixerNotifier());

class MixerNotifier extends StateNotifier<MixerProject> {
  MixerNotifier() : super(const MixerProject());

  void addTrack(String filePath, String name) {
    final track = AudioTrack(
      id: _uuid.v4(),
      name: name,
      filePath: filePath,
    );
    state = state.addTrack(track);
  }

  void removeTrack(String id) => state = state.removeTrack(id);

  void updateVolume(String id, double volume) {
    final t = state.tracks.firstWhere((t) => t.id == id);
    state = state.updateTrack(t.copyWith(volume: volume));
  }

  void updatePan(String id, double pan) {
    final t = state.tracks.firstWhere((t) => t.id == id);
    state = state.updateTrack(t.copyWith(pan: pan));
  }

  void toggleMute(String id) {
    final t = state.tracks.firstWhere((t) => t.id == id);
    state = state.updateTrack(t.copyWith(isMuted: !t.isMuted));
  }

  void toggleSolo(String id) {
    // Turn off solo on all other tracks, toggle this one
    final updated = state.tracks.map((t) {
      if (t.id == id) return t.copyWith(isSolo: !t.isSolo);
      return t.copyWith(isSolo: false);
    }).toList();
    state = state.copyWith(tracks: updated);
  }

  void updateMasterVolume(double v) => state = state.copyWith(masterVolume: v);

  void setLoopRegion(int startMs, int endMs) =>
      state = state.copyWith(loopRegion: LoopRegion(startMs: startMs, endMs: endMs));

  void clearLoop() => state = state.copyWith(clearLoop: true);

  void toggleLoop() => state = state.copyWith(isLooping: !state.isLooping);

  void addMarker(String name, int timeMs) {
    final marker = CueMarker(id: _uuid.v4(), name: name, timeMs: timeMs);
    state = state.addMarker(marker);
  }

  void removeMarker(String id) => state = state.removeMarker(id);

  void clear() => state = const MixerProject();
}

// ─── Overdub state
final overdubActiveProvider = StateProvider<bool>((ref) => false);
