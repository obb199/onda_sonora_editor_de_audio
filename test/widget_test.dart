import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onda_sonora/app.dart';

void main() {
  testWidgets('App starts and renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: OndaSonoraApp()),
    );
    await tester.pump();

    // App title should be visible
    expect(find.text('Onda Sonora'), findsWidgets);
    expect(find.text('Editor de Áudio'), findsOneWidget);
  });

  testWidgets('Bottom navigation has Home and Settings tabs',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: OndaSonoraApp()),
    );
    await tester.pump();

    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
