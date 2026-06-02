import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_strings.dart';

class AppSettings {
  const AppSettings({
    this.locale = AppLocale.pt,
    this.isDarkTheme = true,
  });

  final AppLocale locale;
  final bool isDarkTheme;

  AppSettings copyWith({AppLocale? locale, bool? isDarkTheme}) => AppSettings(
        locale: locale ?? this.locale,
        isDarkTheme: isDarkTheme ?? this.isDarkTheme,
      );
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    AppStrings.setLocale(state.locale);
  }

  void setLocale(AppLocale locale) {
    AppStrings.setLocale(locale);
    state = state.copyWith(locale: locale);
  }

  void toggleTheme() {
    state = state.copyWith(isDarkTheme: !state.isDarkTheme);
  }
}
