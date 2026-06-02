import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/home/home_screen.dart';
import 'features/mixer/mixer_screen.dart';
import 'features/recorder/recorder_screen.dart';
import 'features/settings/settings_screen.dart';
import 'l10n/app_strings.dart';
import 'providers/settings_provider.dart';
import 'theme/app_theme.dart';

class OndaSonoraApp extends ConsumerWidget {
  const OndaSonoraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(settingsProvider);
    return MaterialApp(
      title: 'Onda Sonora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: _AppShell(),
    );
  }
}

class _AppShell extends ConsumerStatefulWidget {
  const _AppShell();

  @override
  ConsumerState<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<_AppShell> {
  int _selectedIndex = 0;

  static const _tabs = [
    HomeScreen(),
    MixerScreen(),
    RecorderScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(AppTheme.systemUiDark);
  }

  @override
  Widget build(BuildContext context) {
    // Watch locale so nav labels rebuild on language change
    ref.watch(settingsProvider);
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: AppStrings.homeTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.queue_music_outlined),
            selectedIcon: const Icon(Icons.queue_music_rounded),
            label: AppStrings.mixer,
          ),
          NavigationDestination(
            icon: const Icon(Icons.mic_none_rounded),
            selectedIcon: const Icon(Icons.mic_rounded),
            label: AppStrings.recorder,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings_rounded),
            label: AppStrings.settings,
          ),
        ],
      ),
    );
  }
}
