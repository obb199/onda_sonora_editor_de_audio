import 'package:equatable/equatable.dart';
import 'audio_effect.dart';

/// Automation point: a (time → value) pair for a single parameter.
class AutomationPoint extends Equatable {
  const AutomationPoint({required this.timeMs, required this.value});
  final int timeMs;
  final double value;

  AutomationPoint copyWith({int? timeMs, double? value}) =>
      AutomationPoint(timeMs: timeMs ?? this.timeMs, value: value ?? this.value);

  Map<String, dynamic> toJson() => {'timeMs': timeMs, 'value': value};
  factory AutomationPoint.fromJson(Map<String, dynamic> j) =>
      AutomationPoint(timeMs: j['timeMs'] as int, value: (j['value'] as num).toDouble());

  @override
  List<Object?> get props => [timeMs, value];
}

/// A single track in the multi-track mixer.
class AudioTrack extends Equatable {
  const AudioTrack({
    required this.id,
    required this.name,
    required this.filePath,
    this.volume = 1.0,
    this.pan = 0.0,
    this.isMuted = false,
    this.isSolo = false,
    this.effects = const [],
    this.volumeAutomation = const [],
    this.offsetMs = 0,
  });

  final String id;
  final String name;
  final String filePath;
  final double volume;   // 0.0–1.0
  final double pan;      // -1.0 (L) to 1.0 (R)
  final bool isMuted;
  final bool isSolo;
  final List<AudioEffect> effects;
  final List<AutomationPoint> volumeAutomation;
  final int offsetMs;  // start offset in the timeline

  bool get isActive => !isMuted;

  AudioTrack copyWith({
    String? id,
    String? name,
    String? filePath,
    double? volume,
    double? pan,
    bool? isMuted,
    bool? isSolo,
    List<AudioEffect>? effects,
    List<AutomationPoint>? volumeAutomation,
    int? offsetMs,
  }) =>
      AudioTrack(
        id: id ?? this.id,
        name: name ?? this.name,
        filePath: filePath ?? this.filePath,
        volume: volume ?? this.volume,
        pan: pan ?? this.pan,
        isMuted: isMuted ?? this.isMuted,
        isSolo: isSolo ?? this.isSolo,
        effects: effects ?? this.effects,
        volumeAutomation: volumeAutomation ?? this.volumeAutomation,
        offsetMs: offsetMs ?? this.offsetMs,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'filePath': filePath,
        'volume': volume,
        'pan': pan,
        'isMuted': isMuted,
        'isSolo': isSolo,
        'effects': effects.map((e) => e.toJson()).toList(),
        'volumeAutomation': volumeAutomation.map((p) => p.toJson()).toList(),
        'offsetMs': offsetMs,
      };

  factory AudioTrack.fromJson(Map<String, dynamic> j) => AudioTrack(
        id: j['id'] as String,
        name: j['name'] as String,
        filePath: j['filePath'] as String,
        volume: (j['volume'] as num?)?.toDouble() ?? 1.0,
        pan: (j['pan'] as num?)?.toDouble() ?? 0.0,
        isMuted: j['isMuted'] as bool? ?? false,
        isSolo: j['isSolo'] as bool? ?? false,
        effects: (j['effects'] as List<dynamic>? ?? [])
            .map((e) => AudioEffect.fromJson(e as Map<String, dynamic>))
            .toList(),
        volumeAutomation: (j['volumeAutomation'] as List<dynamic>? ?? [])
            .map((p) => AutomationPoint.fromJson(p as Map<String, dynamic>))
            .toList(),
        offsetMs: j['offsetMs'] as int? ?? 0,
      );

  @override
  List<Object?> get props => [id, name, filePath, volume, pan, isMuted, isSolo, effects, offsetMs];
}

/// A cue point / marker on the timeline.
class CueMarker extends Equatable {
  const CueMarker({required this.id, required this.name, required this.timeMs});
  final String id;
  final String name;
  final int timeMs;

  CueMarker copyWith({String? name, int? timeMs}) =>
      CueMarker(id: id, name: name ?? this.name, timeMs: timeMs ?? this.timeMs);

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'timeMs': timeMs};
  factory CueMarker.fromJson(Map<String, dynamic> j) =>
      CueMarker(id: j['id'] as String, name: j['name'] as String, timeMs: j['timeMs'] as int);

  @override
  List<Object?> get props => [id, name, timeMs];
}
