import 'package:flutter_test/flutter_test.dart';
import 'package:onda_sonora/models/audio_effect.dart';
import 'package:onda_sonora/models/audio_project.dart';

AudioProject _baseProject() => const AudioProject(
      filePath: '/test/audio.mp3',
      fileName: 'audio.mp3',
      duration: Duration(seconds: 60),
    );

void main() {
  group('AudioProject', () {
    test('initial state has no effects and no undo history', () {
      final project = _baseProject();
      expect(project.effects, isEmpty);
      expect(project.canUndo, isFalse);
      expect(project.canRedo, isFalse);
    });

    test('withEffect adds effect and records undo entry', () {
      final project = _baseProject()
          .withEffect(AudioEffect.defaultReverb());

      expect(project.effects, hasLength(1));
      expect(project.canUndo, isTrue);
    });

    test('undo restores previous effects list', () {
      final project = _baseProject()
          .withEffect(AudioEffect.defaultReverb());
      final undone = project.undo();

      expect(undone.effects, isEmpty);
      expect(undone.canRedo, isTrue);
    });

    test('redo re-applies effect after undo', () {
      final project = _baseProject()
          .withEffect(AudioEffect.defaultReverb())
          .undo()
          .redo();

      expect(project.effects, hasLength(1));
      expect(project.effects.first.type, EffectType.reverb);
    });

    test('undo is capped at 50 entries', () {
      var project = _baseProject();
      for (var i = 0; i < 55; i++) {
        project = project.withEffect(AudioEffect.defaultDelay());
      }
      expect(project.undoStack.length, lessThanOrEqualTo(50));
    });

    test('removeEffect removes at correct index', () {
      var project = _baseProject()
          .withEffect(AudioEffect.defaultReverb())
          .withEffect(AudioEffect.defaultDelay());
      project = project.removeEffect(0);

      expect(project.effects, hasLength(1));
      expect(project.effects.first.type, EffectType.delay);
    });

    test('updateEffect replaces effect at index', () {
      var project = _baseProject()
          .withEffect(AudioEffect.defaultReverb());
      final updated = project.updateEffect(
        0,
        AudioEffect.defaultReverb().withParam('roomSize', 0.99),
      );

      expect(updated.effects.first.parameters['roomSize'], 0.99);
    });

    test('enabledEffects returns only enabled effects', () {
      var project = _baseProject()
          .withEffect(AudioEffect.defaultReverb())
          .withEffect(AudioEffect.defaultDelay());

      // disable second effect
      project = project.updateEffect(1, project.effects[1].toggled());

      expect(project.enabledEffects, hasLength(1));
      expect(project.enabledEffects.first.type, EffectType.reverb);
    });

    test('speed/pitch/volume clamped by AudioPlayerService (validated in range)', () {
      final project = _baseProject().copyWith(speed: 2.0, pitch: 1.5, volume: 0.8);
      expect(project.speed, 2.0);
      expect(project.pitch, 1.5);
      expect(project.volume, 0.8);
    });

    test('toJson / fromJson round-trip', () {
      final original = _baseProject()
          .withEffect(AudioEffect.defaultChorus());
      final json = original.toJson();
      final restored = AudioProject.fromJson(json);

      expect(restored.filePath, original.filePath);
      expect(restored.effects, hasLength(1));
    });
  });
}
