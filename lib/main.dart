import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'app/app.dart';
import 'core/services/analytics_service.dart';
import 'core/services/notification_service.dart';

export 'app/app.dart' show AppProviders, MyNelfundApp;
export 'app/app_shell.dart' show MainTabScaffold;
export 'app/fallback_localizations.dart'
    show
        FallbackCupertinoLocalizationsDelegate,
        FallbackMaterialLocalizationsDelegate;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  try {
    await Firebase.initializeApp();
    unawaited(_initializeBackgroundServices());
  } catch (error) {
    debugPrint('Firebase initialization skipped or offline: $error');
  }

  runApp(const MyNelfundApp());
}

Future<void> _initializeBackgroundServices() async {
  try {
    await AnalyticsService.instance.initialize();
  } catch (error) {
    debugPrint('AnalyticsService background init warning: $error');
  }

  try {
    await NotificationService.instance.initialize();
  } catch (error) {
    debugPrint('NotificationService background init warning: $error');
  }
}
