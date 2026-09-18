/*import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_ar.dart';
import 'app_en.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('ar'),
    Locale('en'),
  ];

  // ==================== INSTANCE ====================
  static AppLocalizations? _instance;
  static AppLocalizations get instance => _instance!;

  // ==================== TRANSLATIONS ====================
  Map<String, String> get _strings =>
      locale.languageCode == 'ar' ? AppAr.strings : AppEn.strings;

  String translate(String key) {
    return _strings[key] ?? key;
  }

  // Shorthand
  String tr(String key) => translate(key);

  // ==================== HELPERS ====================
  bool get isArabic => locale.languageCode == 'ar';
  bool get isEnglish => locale.languageCode == 'en';

  TextAlign get textAlign =>
      isArabic ? TextAlign.right : TextAlign.left;

  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  Alignment get startAlignment =>
      isArabic ? Alignment.centerRight : Alignment.centerLeft;

  Alignment get endAlignment =>
      isArabic ? Alignment.centerLeft : Alignment.centerRight;

  EdgeInsets get paddingStart =>
      isArabic ? const EdgeInsets.only(right: 16) : const EdgeInsets.only(left: 16);

  EdgeInsets get paddingEnd =>
      isArabic ? const EdgeInsets.only(left: 16) : const EdgeInsets.only(right: 16);

  // ==================== LANGUAGE SWITCHING ====================
  static Future<void> setLanguage(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
  }

  static Future<Locale> getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('language_code') ?? 'ar';
    return Locale(code);
  }

  static Future<void> toggleLanguage() async {
    final current = await getSavedLanguage();
    final newLocale =
        current.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    await setLanguage(newLocale);
  }
}

// ==================== DELEGATE ====================
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final savedLocale = await AppLocalizations.getSavedLanguage();
    return AppLocalizations(savedLocale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
*/


import 'package:flutter/material.dart';

import 'app_ar.dart';
import 'app_en.dart';

class AppLocalizations {
final Locale locale;

AppLocalizations(this.locale);

// ==================== OF ====================

static AppLocalizations of(BuildContext context) {
return Localizations.of<AppLocalizations>(
context,
AppLocalizations,
)!;
}

// ==================== DELEGATE ====================

static const LocalizationsDelegate<AppLocalizations> delegate =
_AppLocalizationsDelegate();

// ==================== SUPPORTED LOCALES ====================

static const List<Locale> supportedLocales = [
Locale('ar'),
Locale('en'),
];

// ==================== TRANSLATIONS ====================

Map<String, String> get _strings {
return locale.languageCode == 'ar'
? AppAr.strings
    : AppEn.strings;
}

String translate(String key) {
return _strings[key] ?? key;
}

String tr(String key) {
return translate(key);
}

// ==================== LANGUAGE ====================

bool get isArabic => locale.languageCode == 'ar';

bool get isEnglish => locale.languageCode == 'en';

// ==================== TEXT ====================

TextAlign get textAlign {
return isArabic ? TextAlign.right : TextAlign.left;
}

TextDirection get textDirection {
return isArabic ? TextDirection.rtl : TextDirection.ltr;
}

// ==================== ALIGNMENT ====================

Alignment get startAlignment {
return isArabic
? Alignment.centerRight
    : Alignment.centerLeft;
}

Alignment get endAlignment {
return isArabic
? Alignment.centerLeft
    : Alignment.centerRight;
}

// ==================== PADDING ====================

EdgeInsets get paddingStart {
return isArabic
? const EdgeInsets.only(right: 16)
    : const EdgeInsets.only(left: 16);
}

EdgeInsets get paddingEnd {
return isArabic
? const EdgeInsets.only(left: 16)
    : const EdgeInsets.only(right: 16);
}
}

// ============================================================
// LOCALIZATIONS DELEGATE
// ============================================================

class _AppLocalizationsDelegate
extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return locale.languageCode == 'ar' ||
        locale.languageCode == 'en';
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
// مهم جدًا:
// نستخدم اللغة التي أرسلها Flutter مباشرة
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) {
    return false;
  }
}