import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';

import 'config/app_theme.dart';
import 'config/routes.dart';
import 'l10n/app_localizations.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase مع دعم بيئة الويب (المعاينة)
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "preview-mode-key-123456789",
          appId: "1:123456789:web:preview",
          messagingSenderId: "123456789",
          projectId: "binaflow-preview",
        ),
      );
    } else {
      // تهيئة الفايربيز الأساسية لأندرويد
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint("Firebase initialization warning: $e");
  }

  // تهيئة Hive
  // تهيئة Hive
  await Hive.initFlutter();
  await Hive.openBox('cart_box');
  await Hive.openBox('favorites_box');
  await Hive.openBox('user_box');
  await Hive.openBox('search_box');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: const BinaFlowApp(),
    ),
  );
}

class BinaFlowApp extends StatelessWidget {
  const BinaFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp(
      title: 'BinaFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.flutterThemeMode,
      locale: localeProvider.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}