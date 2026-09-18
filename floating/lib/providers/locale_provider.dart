import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('ar');
  SharedPreferences? _prefs;

  Locale get locale => _locale;
  bool get isRTL => _locale.languageCode == 'ar';

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    _prefs = await SharedPreferences.getInstance();
    final code = _prefs?.getString('locale') ?? 'ar';
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString('locale', locale.languageCode);
    notifyListeners();
  }

  Future<void> toggleLocale() async {
    final next = _locale.languageCode == 'ar'
        ? const Locale('en')
        : const Locale('ar');
    await setLocale(next);
  }
}
