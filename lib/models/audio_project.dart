import 'package:equatable/equatable.dart';
import 'audio_effect.dart';

/// Represents the current editing session.
class AudioProject extends Equatable {
  const AudioProject({
    required this.filePath,
    required this.fileName,
    this.duration = Duration.zero,
    this.speed = 1.0,
    this.pitch = 1.0,
    this.volume = 1.0,
    this.effects = const [],
    this.undoStack = const [],
    this.redoStack = const [],
  });

  final String filePath;
  final String fileName;
  final Duration duration;

  /// Live-preview controls (just_audio)
  final double speed;
  final double pitch;
  final double volume;

  /// Effects chain applied at export time
  final List<AudioEffect> effects;

  /// Undo/redo stacks store full snapshots of the effects list
  final List<List<AudioEffect>> undoStack;
  final List<List<AudioEffect>> redoStack;

  bool get canUndo => undoStack.isNotEmpty;
  bool get canRedo => redoStack.isNotEmpty;
  List<AudioEffect> get enabledEffects =>
      effects.where((e) => e.enabled).toList();

  AudioProject copyWith({
    String? filePath,
    String? fileName,
    Duration? duration,
    double? speed,
    double? pitch,
    double? volume,
    List<AudioEffect>? effects,
    List<List<AudioEffect>>? undoStack,
    List<List<AudioEffect>>? redoStack,
  }) =>
      AudioProject(
        filePath: filePath ?? this.filePath,
        fileName: fileName ?? this.fileName,
        duration: duration ?? this.duration,
        speed: speed ?? this.speed,
        pitch: pitch ?? this.pitch,
        volume: volume ?? this.volume,
        effects: effects ?? this.effects,
        undoStack: undoStack ?? this.undoStack,
        redoStack: redoStack ?? this.redoStack,
      );

  AudioProject withEffect(AudioEffect effect) {
    final newUndo = [...undoStack, effects];
    if (newUndo.length > 50) newUndo.removeAt(0);
    return copyWith(
      effects: [...effects, effect],
      undoStack: newUndo,
      redoStack: [],
    );
  }

  AudioProject updateEffect(int index, AudioEffect updated) {
    final newEffects = [...effects];
    newEffects[index] = updated;
    final newUndo = [...undoStack, effects];
    if (newUndo.length > 50) newUndo.removeAt(0);
    return copyWith(
      effects: newEffects,
      undoStack: newUndo,
      redoStack: [],
    );
  }

  AudioProject removeEffect(int index) {
    final newEffects = [...effects]..removeAt(index);
    final newUndo = [...undoStack, effects];
    if (newUndo.length > 50) newUndo.removeAt(0);
    return copyWith(
      effects: newEffects,
      undoStack: newUndo,
      redoStack: [],
    );
  }

  AudioProject undo() {
    if (!canUndo) return this;
    final previous = undoStack.last;
    final newUndo = [...undoStack]..removeLast();
    return copyWith(
      effects: previous,
      undoStack: newUndo,
      redoStack: [effects, ...redoStack],
    );
  }

  AudioProject redo() {
    if (!canRedo) return this;
    final next = redoStack.first;
    final newRedo = [...redoStack]..removeAt(0);
    return copyWith(
      effects: next,
      undoStack: [...undoStack, effects],
      redoStack: newRedo,
    );
  }

  Map<String, dynamic> toJson() => {
        'filePath': filePath,
        'fileName': fileName,
        'speed': speed,
        'pitch': pitch,
        'volume': volume,
        'effects': effects.map((e) => e.toJson()).toList(),
      };

  factory AudioProject.fromJson(Map<String, dynamic> json) => AudioProject(
        filePath: json['filePath'] as String,
        fileName: json['fileName'] as String,
        speed: (json['speed'] as num?)?.toDouble() ?? 1.0,
        pitch: (json['pitch'] as num?)?.toDouble() ?? 1.0,
        volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
        effects: (json['effects'] as List<dynamic>?)
                ?.map((e) => AudioEffect.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  @override
  List<Object?> get props =>
      [filePath, fileName, duration, speed, pitch, volume, effects];
}
