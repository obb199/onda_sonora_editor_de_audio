import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/audio_track.dart';
import '../models/mixer_project.dart';

const _uuid = Uuid();

class EditorUiState {
  const EditorUiState({
    this.isLooping = false,
    this.loopRegion,
    this.markers = const [],
    this.livePreviewEnabled = true,
    this.showMarkers = true,
  });

  final bool isLooping;
  final LoopRegion? loopRegion;
  final List<CueMarker> markers;
  final bool livePreviewEnabled;
  final bool showMarkers;

  EditorUiState copyWith({
    bool? isLooping,
    LoopRegion? loopRegion,
    bool clearLoop = false,
    List<CueMarker>? markers,
    bool? livePreviewEnabled,
    bool? showMarkers,
  }) =>
      EditorUiState(
        isLooping: isLooping ?? this.isLooping,
        loopRegion: clearLoop ? null : (loopRegion ?? this.loopRegion),
        markers: markers ?? this.markers,
        livePreviewEnabled: livePreviewEnabled ?? this.livePreviewEnabled,
        showMarkers: showMarkers ?? this.showMarkers,
      );
}

final editorUiProvider =
    StateNotifierProvider<EditorUiNotifier, EditorUiState>(
  (ref) => EditorUiNotifier(),
);

class EditorUiNotifier extends StateNotifier<EditorUiState> {
  EditorUiNotifier() : super(const EditorUiState());

  void setLoopRegion(LoopRegion region) =>
      state = state.copyWith(loopRegion: region);

  void clearLoopRegion() => state = state.copyWith(clearLoop: true);

  void toggleLoop() => state = state.copyWith(isLooping: !state.isLooping);

  void addMarker(String name, int timeMs) {
    final marker = CueMarker(id: _uuid.v4(), name: name, timeMs: timeMs);
    final updated = [...state.markers, marker]
      ..sort((a, b) => a.timeMs.compareTo(b.timeMs));
    state = state.copyWith(markers: updated);
  }

  void removeMarker(String id) =>
      state = state.copyWith(
          markers: state.markers.where((m) => m.id != id).toList());

  void toggleLivePreview() =>
      state = state.copyWith(livePreviewEnabled: !state.livePreviewEnabled);

  void toggleShowMarkers() =>
      state = state.copyWith(showMarkers: !state.showMarkers);

  void reset() => state = const EditorUiState();
}
