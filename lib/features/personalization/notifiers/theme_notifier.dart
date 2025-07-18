import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:varsight/core/utils/storage.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  static const _themeKey = 'themeMode';

  @override
  ThemeMode build() {
    return _loadTheme();
  }

  /// Loads the theme from local storage. Defaults to light mode.
  ThemeMode _loadTheme() {
    final themeString = JLocalStorage.instance().readData<String>(_themeKey);
    if (themeString == 'dark') {
      return ThemeMode.dark;
    }
    // Default to light theme if nothing is stored or if it's 'light'
    return ThemeMode.light;
  }

  /// Persists the theme to local storage.
  Future<void> _saveTheme(ThemeMode themeMode) async {
    await JLocalStorage.instance().saveData(
      _themeKey,
      themeMode == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  /// Toggles the theme between light and dark mode.
  void setTheme(bool isDarkMode) {
    final newThemeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    if (state != newThemeMode) {
      state = newThemeMode;
      _saveTheme(state);
    }
  }
}

/// Provider to expose the ThemeNotifier.
final themeNotifierProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);
