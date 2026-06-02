import 'package:equatable/equatable.dart';
import 'audio_effect.dart';

/// Saved combination of effects.
class EffectPreset extends Equatable {
  const EffectPreset({
    required this.id,
    required this.name,
    required this.effects,
    required this.createdAt,
  });

  final String id;
  final String name;
  final List<AudioEffect> effects;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'effects': effects.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory EffectPreset.fromJson(Map<String, dynamic> json) => EffectPreset(
        id: json['id'] as String,
        name: json['name'] as String,
        effects: (json['effects'] as List<dynamic>)
            .map((e) => AudioEffect.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  @override
  List<Object?> get props => [id, name, effects, createdAt];
}
