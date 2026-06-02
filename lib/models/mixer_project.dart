import 'package:equatable/equatable.dart';
import 'audio_track.dart';

/// Loop region defined by start/end times in milliseconds.
class LoopRegion extends Equatable {
  const LoopRegion({required this.startMs, required this.endMs});
  final int startMs;
  final int endMs;

  bool get isValid => endMs > startMs;
  Duration get startDuration => Duration(milliseconds: startMs);
  Duration get endDuration => Duration(milliseconds: endMs);

  @override
  List<Object?> get props => [startMs, endMs];
}

/// The multi-track mixer project.
class MixerProject extends Equatable {
  const MixerProject({
    this.tracks = const [],
    this.markers = const [],
    this.loopRegion,
    this.masterVolume = 1.0,
    this.isLooping = false,
  });

  final List<AudioTrack> tracks;
  final List<CueMarker> markers;
  final LoopRegion? loopRegion;
  final double masterVolume;
  final bool isLooping;

  List<AudioTrack> get activeTracks {
    final hasSolo = tracks.any((t) => t.isSolo);
    if (hasSolo) return tracks.where((t) => t.isSolo).toList();
    return tracks.where((t) => !t.isMuted).toList();
  }

  MixerProject copyWith({
    List<AudioTrack>? tracks,
    List<CueMarker>? markers,
    LoopRegion? loopRegion,
    bool clearLoop = false,
    double? masterVolume,
    bool? isLooping,
  }) =>
      MixerProject(
        tracks: tracks ?? this.tracks,
        markers: markers ?? this.markers,
        loopRegion: clearLoop ? null : (loopRegion ?? this.loopRegion),
        masterVolume: masterVolume ?? this.masterVolume,
        isLooping: isLooping ?? this.isLooping,
      );

  MixerProject addTrack(AudioTrack track) =>
      copyWith(tracks: [...tracks, track]);

  MixerProject removeTrack(String id) =>
      copyWith(tracks: tracks.where((t) => t.id != id).toList());

  MixerProject updateTrack(AudioTrack updated) => copyWith(
        tracks: tracks.map((t) => t.id == updated.id ? updated : t).toList(),
      );

  MixerProject addMarker(CueMarker marker) =>
      copyWith(markers: [...markers, marker]
        ..sort((a, b) => a.timeMs.compareTo(b.timeMs)));

  MixerProject removeMarker(String id) =>
      copyWith(markers: markers.where((m) => m.id != id).toList());

  @override
  List<Object?> get props => [tracks, markers, loopRegion, masterVolume, isLooping];
}
