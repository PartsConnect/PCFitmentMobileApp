import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pcfitment/component/language.dart';
import 'package:pcfitment/component/theme_provider.dart';
import 'package:pcfitment/component/themes.dart';
import 'package:pcfitment/database/database_helper.dart';
import 'package:pcfitment/screen/splash.dart';
import 'package:pcfitment/utils/preference_utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: false, ignoreSsl: true);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessBackgroundHandle);

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  //await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  //    alert: true, badge: true, sound: true);

  await DatabaseHelper.instance.database;
  await PreferenceUtils.init();

  String? strCountryCode =
      WidgetsBinding.instance.platformDispatcher.locale.countryCode;
  PreferenceUtils.setSystemCountryCode(strCountryCode!);
  String? strLanguageCode =
      WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  if (PreferenceUtils.getSystemLangCode().isEmpty) {
    PreferenceUtils.setSystemLangCode(strLanguageCode);
  }

  LanguageChange languageChange =
      LanguageChange();
  await languageChange.initLanguage();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

@pragma('vm:entry-point')
Future<void> _firebaseMessBackgroundHandle(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => LanguageChange())],
      child: Consumer<LanguageChange>(builder: (context, provider, child) {
        return MaterialApp(
          locale: Locale(PreferenceUtils.getSystemLangCode()),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          /*supportedLocales: const [
            Locale('en'), // English
            Locale('zh'), // Chinese
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            return locale;
          },*/

          //TODO : Light System Theme Change
          theme: ThemeClass.lightTheme,

          //TODO : Day Night System Theme Change
          //themeMode: ThemeMode.system,
          //theme: ThemeClass.lightTheme,
          //darkTheme: ThemeClass.darkTheme,

          //TODO : Day Night Manual Theme Change
          //theme: Provider.of<ThemeProvider>(context).selectedTheme,

          debugShowCheckedModeBanner: false,
          //home: PreferenceUtils.getIsLogin().toLowerCase() == 'true'
          //    ? const DashboardPage()
          //    : const LoginPage(),
          home: const SplashPage(),
        );
      }),
    );
  }
}
