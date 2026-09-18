import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeModeOption { light, dark, system }

class ThemeProvider extends ChangeNotifier {
  ThemeModeOption _themeMode = ThemeModeOption.system;
  SharedPreferences? _prefs;

  ThemeModeOption get themeMode => _themeMode;

  ThemeMode get flutterThemeMode {
    switch (_themeMode) {
      case ThemeModeOption.light:
        return ThemeMode.light;
      case ThemeModeOption.dark:
        return ThemeMode.dark;
      case ThemeModeOption.system:
        return ThemeMode.system;
    }
  }

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _prefs = await SharedPreferences.getInstance();
    final index = _prefs?.getInt('theme_mode') ?? 2;
    _themeMode = ThemeModeOption.values[index];
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeModeOption mode) async {
    _themeMode = mode;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setInt('theme_mode', mode.index);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final next = _themeMode == ThemeModeOption.light
        ? ThemeModeOption.dark
        : ThemeModeOption.light;
    await setThemeMode(next);
  }
}
