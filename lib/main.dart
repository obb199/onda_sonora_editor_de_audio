import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  // Run inside a guarded zone so that any uncaught async error (e.g. a native
  // plugin throwing on a real device) is logged instead of crashing the app
  // with the system "app keeps stopping" dialog.
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Route framework errors to console; never let them tear down the app.
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      debugPrint('FlutterError: ${details.exceptionAsString()}');
    };

    // Replace the red/grey crash widget with a quiet placeholder in release.
    if (!kDebugMode) {
      ErrorWidget.builder = (details) => const SizedBox.shrink();
    }

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    runApp(
      const ProviderScope(
        child: OndaSonoraApp(),
      ),
    );
  }, (error, stack) {
    debugPrint('Uncaught zone error: $error\n$stack');
  });
}
