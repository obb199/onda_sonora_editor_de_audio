import 'package:flutter_test/flutter_test.dart';
import 'package:onda_sonora/core/ffmpeg_service.dart';
import 'package:onda_sonora/models/audio_effect.dart';

void main() {
  final svc = FfmpegService.instance;

  group('FfmpegService.filterForEffect', () {
    test('reverb produces aecho filter', () {
      final f = svc.filterForEffect(AudioEffect.defaultReverb());
      expect(f, isNotNull);
      expect(f, contains('aecho'));
    });

    test('delay produces aecho filter', () {
      final f = svc.filterForEffect(AudioEffect.defaultDelay());
      expect(f, isNotNull);
      expect(f, contains('aecho'));
    });

    test('equalizer returns filter when bass != 0', () {
      final effect = AudioEffect.defaultEqualizer().withParam('bass', 3.0);
      final f = svc.filterForEffect(effect);
      expect(f, isNotNull);
      expect(f, contains('equalizer'));
    });

    test('equalizer returns null when all gains are 0', () {
      final f = svc.filterForEffect(AudioEffect.defaultEqualizer());
      expect(f, isNull);
    });

    test('lowPass includes cutoff frequency', () {
      final effect = AudioEffect.defaultLowPass().withParam('cutoff', 1500.0);
      final f = svc.filterForEffect(effect);
      expect(f, contains('lowpass'));
      expect(f, contains('1500'));
    });

    test('highPass includes cutoff frequency', () {
      final effect = AudioEffect.defaultHighPass().withParam('cutoff', 400.0);
      final f = svc.filterForEffect(effect);
      expect(f, contains('highpass'));
      expect(f, contains('400'));
    });

    test('reverse returns areverse', () {
      final f = svc.filterForEffect(AudioEffect.defaultReverse());
      expect(f, 'areverse');
    });

    test('fadeIn contains t=in', () {
      final f = svc.filterForEffect(AudioEffect.defaultFadeIn());
      expect(f, contains('afade'));
      expect(f, contains('t=in'));
    });

    test('fadeOut contains t=out', () {
      final f = svc.filterForEffect(AudioEffect.defaultFadeOut());
      expect(f, contains('afade'));
      expect(f, contains('t=out'));
    });

    test('normalize uses loudnorm', () {
      final f = svc.filterForEffect(AudioEffect.defaultNormalize());
      expect(f, contains('loudnorm'));
    });

    test('bitcrusher contains bits value', () {
      final f = svc.filterForEffect(AudioEffect.defaultBitcrusher());
      expect(f, contains('acrusher'));
      expect(f, contains('bits=8'));
    });

    test('distortion uses acrusher', () {
      final f = svc.filterForEffect(AudioEffect.defaultDistortion());
      expect(f, contains('acrusher'));
    });

    test('chorus uses chorus filter', () {
      final f = svc.filterForEffect(AudioEffect.defaultChorus());
      expect(f, contains('chorus'));
    });

    test('flanger uses flanger filter', () {
      final f = svc.filterForEffect(AudioEffect.defaultFlanger());
      expect(f, contains('flanger'));
    });

    test('phaser uses aphaser filter', () {
      final f = svc.filterForEffect(AudioEffect.defaultPhaser());
      expect(f, contains('aphaser'));
    });

    test('compressor uses acompressor filter', () {
      final f = svc.filterForEffect(AudioEffect.defaultCompressor());
      expect(f, contains('acompressor'));
    });
  });
}
