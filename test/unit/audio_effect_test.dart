import 'package:flutter_test/flutter_test.dart';
import 'package:onda_sonora/models/audio_effect.dart';

void main() {
  group('AudioEffect', () {
    test('defaultFor returns correct effect type', () {
      for (final type in EffectType.values) {
        final effect = AudioEffect.defaultFor(type);
        expect(effect.type, type);
        expect(effect.enabled, isTrue);
      }
    });

    test('withParam updates a parameter', () {
      final effect = AudioEffect.defaultReverb();
      final updated = effect.withParam('roomSize', 0.9);

      expect(updated.parameters['roomSize'], 0.9);
      // Other parameters unchanged
      expect(updated.parameters['wetness'], effect.parameters['wetness']);
    });

    test('toggled flips enabled state', () {
      final effect = AudioEffect.defaultDelay();
      expect(effect.enabled, isTrue);

      final toggled = effect.toggled();
      expect(toggled.enabled, isFalse);

      final toggled2 = toggled.toggled();
      expect(toggled2.enabled, isTrue);
    });

    test('toJson / fromJson round-trip', () {
      final original = AudioEffect.defaultEqualizer();
      final json = original.toJson();
      final restored = AudioEffect.fromJson(json);

      expect(restored.type, original.type);
      expect(restored.enabled, original.enabled);
      expect(restored.parameters, original.parameters);
    });

    test('copyWith does not mutate original', () {
      const original = AudioEffect(
        type: EffectType.reverb,
        parameters: {'roomSize': 0.5},
      );
      final copy = original.copyWith(enabled: false);

      expect(original.enabled, isTrue);
      expect(copy.enabled, isFalse);
    });

    group('default parameters are in valid range', () {
      test('reverb roomSize between 0 and 1', () {
        final e = AudioEffect.defaultReverb();
        final v = e.parameters['roomSize']!;
        expect(v, greaterThanOrEqualTo(0.0));
        expect(v, lessThanOrEqualTo(1.0));
      });

      test('delay delayMs between 50 and 2000', () {
        final e = AudioEffect.defaultDelay();
        final v = e.parameters['delayMs']!;
        expect(v, greaterThanOrEqualTo(50));
        expect(v, lessThanOrEqualTo(2000));
      });

      test('bitcrusher bits between 1 and 16', () {
        final e = AudioEffect.defaultBitcrusher();
        final bits = e.parameters['bits']!;
        expect(bits, greaterThanOrEqualTo(1));
        expect(bits, lessThanOrEqualTo(16));
      });
    });
  });
}
