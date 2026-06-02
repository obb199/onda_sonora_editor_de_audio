import 'package:equatable/equatable.dart';

enum EffectType {
  reverb,
  delay,
  equalizer,
  distortion,
  chorus,
  flanger,
  phaser,
  bitcrusher,
  lowPass,
  highPass,
  normalize,
  reverse,
  fadeIn,
  fadeOut,
  compressor,
}

/// Single audio effect with its parameters.
class AudioEffect extends Equatable {
  const AudioEffect({
    required this.type,
    required this.parameters,
    this.enabled = true,
  });

  final EffectType type;
  final Map<String, double> parameters;
  final bool enabled;

  AudioEffect copyWith({
    EffectType? type,
    Map<String, double>? parameters,
    bool? enabled,
  }) =>
      AudioEffect(
        type: type ?? this.type,
        parameters: parameters ?? this.parameters,
        enabled: enabled ?? this.enabled,
      );

  AudioEffect withParam(String key, double value) => copyWith(
        parameters: {...parameters, key: value},
      );

  AudioEffect toggled() => copyWith(enabled: !enabled);

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'parameters': parameters,
        'enabled': enabled,
      };

  factory AudioEffect.fromJson(Map<String, dynamic> json) => AudioEffect(
        type: EffectType.values.firstWhere((e) => e.name == json['type']),
        parameters: Map<String, double>.from(json['parameters'] as Map),
        enabled: json['enabled'] as bool? ?? true,
      );

  @override
  List<Object?> get props => [type, parameters, enabled];

  // ─── Default effects with sane parameter values

  static AudioEffect defaultReverb() => const AudioEffect(
        type: EffectType.reverb,
        parameters: {'roomSize': 0.5, 'wetness': 0.3, 'feedback': 0.4},
      );

  static AudioEffect defaultDelay() => const AudioEffect(
        type: EffectType.delay,
        parameters: {'delayMs': 500.0, 'feedback': 0.5, 'wetness': 0.4},
      );

  static AudioEffect defaultEqualizer() => const AudioEffect(
        type: EffectType.equalizer,
        parameters: {'bass': 0.0, 'mid': 0.0, 'treble': 0.0},
      );

  static AudioEffect defaultDistortion() => const AudioEffect(
        type: EffectType.distortion,
        parameters: {'drive': 0.3, 'wetness': 0.5},
      );

  static AudioEffect defaultChorus() => const AudioEffect(
        type: EffectType.chorus,
        parameters: {'depth': 0.5, 'rate': 1.0, 'wetness': 0.5},
      );

  static AudioEffect defaultFlanger() => const AudioEffect(
        type: EffectType.flanger,
        parameters: {'depth': 0.5, 'rate': 0.5, 'feedback': 0.5},
      );

  static AudioEffect defaultPhaser() => const AudioEffect(
        type: EffectType.phaser,
        parameters: {'depth': 0.5, 'rate': 0.5},
      );

  static AudioEffect defaultBitcrusher() => const AudioEffect(
        type: EffectType.bitcrusher,
        parameters: {'bits': 8.0},
      );

  static AudioEffect defaultLowPass() => const AudioEffect(
        type: EffectType.lowPass,
        parameters: {'cutoff': 3000.0},
      );

  static AudioEffect defaultHighPass() => const AudioEffect(
        type: EffectType.highPass,
        parameters: {'cutoff': 200.0},
      );

  static AudioEffect defaultNormalize() => const AudioEffect(
        type: EffectType.normalize,
        parameters: {'targetLufs': -14.0},
      );

  static AudioEffect defaultReverse() => const AudioEffect(
        type: EffectType.reverse,
        parameters: {},
      );

  static AudioEffect defaultFadeIn() => const AudioEffect(
        type: EffectType.fadeIn,
        parameters: {'durationSec': 2.0},
      );

  static AudioEffect defaultFadeOut() => const AudioEffect(
        type: EffectType.fadeOut,
        parameters: {'durationSec': 2.0},
      );

  static AudioEffect defaultCompressor() => const AudioEffect(
        type: EffectType.compressor,
        parameters: {'threshold': -20.0, 'ratio': 4.0},
      );

  static AudioEffect defaultFor(EffectType type) {
    switch (type) {
      case EffectType.reverb:
        return defaultReverb();
      case EffectType.delay:
        return defaultDelay();
      case EffectType.equalizer:
        return defaultEqualizer();
      case EffectType.distortion:
        return defaultDistortion();
      case EffectType.chorus:
        return defaultChorus();
      case EffectType.flanger:
        return defaultFlanger();
      case EffectType.phaser:
        return defaultPhaser();
      case EffectType.bitcrusher:
        return defaultBitcrusher();
      case EffectType.lowPass:
        return defaultLowPass();
      case EffectType.highPass:
        return defaultHighPass();
      case EffectType.normalize:
        return defaultNormalize();
      case EffectType.reverse:
        return defaultReverse();
      case EffectType.fadeIn:
        return defaultFadeIn();
      case EffectType.fadeOut:
        return defaultFadeOut();
      case EffectType.compressor:
        return defaultCompressor();
    }
  }
}
