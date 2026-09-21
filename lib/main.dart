import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show DefaultMaterialLocalizations, MaterialLocalizations;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/localization/locale_provider.dart';
import 'core/services/analytics_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/nelfund_theme.dart';
import 'firebase_options.dart';
import 'views/main_tab_scaffold.dart';
import 'views/splash/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Paint the first frame immediately so the app opens in milliseconds
  // without waiting for network connections or third-party SDKs
  runApp(
    ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: const MyNelfundApp(),
    ),
  );

  // Asynchronously initialize Firebase, Analytics, and Notifications
  // in the background without blocking the UI rendering thread
  unawaited(_initializeBackgroundServices());
}

Future<void> _initializeBackgroundServices() async {
  if (kIsWeb) {
    debugPrint('[Main] Web environment: running in offline presentation mode.');
    return;
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 4));
  } catch (e) {
    debugPrint('[Main] Firebase initialization note: $e');
  }

  try {
    await AnalyticsService.instance.initialize();
    await NotificationService.instance.initialize();
  } catch (e) {
    debugPrint('[Main] Background services note: $e');
  }
}

class MyNelfundApp extends StatelessWidget {
  final bool skipSplash;
  final bool? showLanguageOnboarding;

  const MyNelfundApp({
    super.key,
    this.skipSplash = false,
    this.showLanguageOnboarding,
  });

  @override
  Widget build(BuildContext context) {
    LocaleProvider? existingProvider;
    try {
      existingProvider = Provider.of<LocaleProvider?>(context, listen: false);
    } catch (_) {}

    final bool shouldShowOnboarding = showLanguageOnboarding ?? !skipSplash;

    if (existingProvider == null) {
      return ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: _MyNelfundAppContent(
          skipSplash: skipSplash,
          showLanguageOnboarding: shouldShowOnboarding,
        ),
      );
    }

    return _MyNelfundAppContent(
      skipSplash: skipSplash,
      showLanguageOnboarding: shouldShowOnboarding,
    );
  }
}

class FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      DefaultCupertinoLocalizations.load(locale);

  @override
  bool shouldReload(FallbackCupertinoLocalizationsDelegate old) => false;
}

class FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      DefaultMaterialLocalizations.load(locale);

  @override
  bool shouldReload(FallbackMaterialLocalizationsDelegate old) => false;
}

class _MyNelfundAppContent extends StatelessWidget {
  final bool skipSplash;
  final bool showLanguageOnboarding;

  const _MyNelfundAppContent({
    required this.skipSplash,
    required this.showLanguageOnboarding,
  });

  @override
  Widget build(BuildContext context) {
    final observer = AnalyticsService.instance.observer;
    final localeProvider = context.watch<LocaleProvider>();

    return CupertinoApp(
      title: 'My NELFund',
      debugShowCheckedModeBanner: false,
      theme: NelfundTheme.lightTheme,
      locale: localeProvider.locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ha'),
      ],
      localizationsDelegates: const [
        FallbackCupertinoLocalizationsDelegate(),
        FallbackMaterialLocalizationsDelegate(),
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      navigatorObservers: observer != null ? [observer] : const [],
      onGenerateRoute: (settings) {
        return CupertinoPageRoute(
          builder: (context) => skipSplash
              ? MainTabScaffold(showLanguageOnboarding: showLanguageOnboarding)
              : const SplashView(),
        );
      },
      home: skipSplash
          ? MainTabScaffold(showLanguageOnboarding: showLanguageOnboarding)
          : const SplashView(),
    );
  }
}

