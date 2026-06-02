import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_strings.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(AppStrings.settings)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SettingsSection(
              title: AppStrings.language,
              children: [
                _LanguageTile(
                  label: AppStrings.languagePortuguese,
                  locale: AppLocale.pt,
                  current: settings.locale,
                  onTap: () => ref.read(settingsProvider.notifier).setLocale(AppLocale.pt),
                ),
                _LanguageTile(
                  label: AppStrings.languageEnglish,
                  locale: AppLocale.en,
                  current: settings.locale,
                  onTap: () => ref.read(settingsProvider.notifier).setLocale(AppLocale.en),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SettingsSection(
              title: AppStrings.aboutApp,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const AppLogo(size: 72, showLabel: true),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.aboutText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border),
            ),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.label,
    required this.locale,
    required this.current,
    required this.onTap,
  });
  final String label;
  final AppLocale locale;
  final AppLocale current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = locale == current;
    return ListTile(
      title: Text(label, style: TextStyle(color: selected ? AppColors.primary : AppColors.textPrimary)),
      trailing: selected
          ? const Icon(Icons.check_rounded, color: AppColors.primary)
          : null,
      onTap: onTap,
    );
  }
}
