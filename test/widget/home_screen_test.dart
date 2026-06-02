import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onda_sonora/app.dart';
import 'package:onda_sonora/l10n/app_strings.dart';

void main() {
  setUp(() => AppStrings.setLocale(AppLocale.pt));

  group('HomeScreen', () {
    testWidgets('shows app name and tagline', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: OndaSonoraApp()),
      );
      await tester.pump();

      expect(find.text('Onda Sonora'), findsWidgets);
      expect(find.text('Editor de Áudio'), findsOneWidget);
    });

    testWidgets('shows import card with correct label', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: OndaSonoraApp()),
      );
      await tester.pump();

      expect(find.text(AppStrings.importAudio), findsOneWidget);
    });

    testWidgets('shows feature grid items', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: OndaSonoraApp()),
      );
      await tester.pump();

      expect(find.text(AppStrings.speed), findsOneWidget);
      expect(find.text(AppStrings.pitch), findsOneWidget);
    });

    testWidgets('bottom navigation has 4 tabs (Home, Mixer, Recorder, Settings)',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: OndaSonoraApp()),
      );
      await tester.pump();

      expect(find.byType(NavigationBar), findsOneWidget);
      // Phase 2: 4 tabs — Home, Mixer, Recorder, Settings
      expect(find.byType(NavigationDestination), findsNWidgets(4));
    });

    testWidgets('tapping Settings tab navigates to settings', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: OndaSonoraApp()),
      );
      await tester.pump();

      final settingsTab = find.text(AppStrings.settings);
      expect(settingsTab, findsOneWidget);

      await tester.tap(settingsTab);
      await tester.pumpAndSettle();

      // Settings screen header is uppercased
      expect(find.text(AppStrings.language.toUpperCase()), findsOneWidget);
    });

    testWidgets('tapping Mixer tab shows mixer screen', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: OndaSonoraApp()),
      );
      await tester.pump();

      await tester.tap(find.text(AppStrings.mixer));
      await tester.pumpAndSettle();

      // Mixer shows empty state message
      expect(find.text(AppStrings.noTracksYet), findsOneWidget);
    });

    testWidgets('supported formats text is shown', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: OndaSonoraApp()),
      );
      await tester.pump();

      expect(find.textContaining('MP3'), findsOneWidget);
    });
  });
}
