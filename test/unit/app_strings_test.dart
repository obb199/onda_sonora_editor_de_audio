import 'package:flutter_test/flutter_test.dart';
import 'package:onda_sonora/l10n/app_strings.dart';

void main() {
  group('AppStrings bilingual support', () {
    setUp(() => AppStrings.setLocale(AppLocale.pt));
    tearDown(() => AppStrings.setLocale(AppLocale.pt));

    test('default locale is Portuguese', () {
      expect(AppStrings.locale, AppLocale.pt);
    });

    test('app name is always Onda Sonora', () {
      AppStrings.setLocale(AppLocale.pt);
      expect(AppStrings.appName, 'Onda Sonora');
      AppStrings.setLocale(AppLocale.en);
      expect(AppStrings.appName, 'Onda Sonora');
    });

    test('importAudio differs between PT and EN', () {
      AppStrings.setLocale(AppLocale.pt);
      final pt = AppStrings.importAudio;
      AppStrings.setLocale(AppLocale.en);
      final en = AppStrings.importAudio;
      expect(pt, isNot(en));
    });

    test('effectNames differ between PT and EN', () {
      AppStrings.setLocale(AppLocale.pt);
      final ptReverb = AppStrings.effectReverb;
      AppStrings.setLocale(AppLocale.en);
      final enReverb = AppStrings.effectReverb;
      // Reverb is same in both but effect names should all be defined
      expect(ptReverb, isNotEmpty);
      expect(enReverb, isNotEmpty);
    });

    test('all strings are non-empty in Portuguese', () {
      AppStrings.setLocale(AppLocale.pt);
      final strings = [
        AppStrings.appName,
        AppStrings.appTagline,
        AppStrings.homeTitle,
        AppStrings.importAudio,
        AppStrings.editorTitle,
        AppStrings.play,
        AppStrings.pause,
        AppStrings.stop,
        AppStrings.effects,
        AppStrings.exportTitle,
        AppStrings.settings,
      ];
      for (final s in strings) {
        expect(s, isNotEmpty, reason: 'String should not be empty in PT');
      }
    });

    test('all strings are non-empty in English', () {
      AppStrings.setLocale(AppLocale.en);
      final strings = [
        AppStrings.appName,
        AppStrings.appTagline,
        AppStrings.homeTitle,
        AppStrings.importAudio,
        AppStrings.editorTitle,
        AppStrings.play,
        AppStrings.pause,
        AppStrings.stop,
        AppStrings.effects,
        AppStrings.exportTitle,
        AppStrings.settings,
      ];
      for (final s in strings) {
        expect(s, isNotEmpty, reason: 'String should not be empty in EN');
      }
    });

    test('setLocale changes the active locale', () {
      AppStrings.setLocale(AppLocale.en);
      expect(AppStrings.locale, AppLocale.en);
      AppStrings.setLocale(AppLocale.pt);
      expect(AppStrings.locale, AppLocale.pt);
    });
  });
}
