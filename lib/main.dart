import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'core/services/analytics_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/nelfund_theme.dart';
import 'firebase_options.dart';
import 'views/main_tab_scaffold.dart';
import 'views/splash/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize native Firebase Core SDK
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('[Main] Firebase initialization note: $e');
  }

  // Paint the first frame immediately so the native Android launch screen
  // dismisses in milliseconds instead of waiting for internet connections
  runApp(const MyNelfundApp());

  // Asynchronously initialize Analytics and Push Notification services
  // in the background without blocking the UI rendering thread
  unawaited(_initializeBackgroundServices());
}

Future<void> _initializeBackgroundServices() async {
  try {
    await AnalyticsService.instance.initialize();
    await NotificationService.instance.initialize();
  } catch (e) {
    debugPrint('[Main] Background services note: $e');
  }
}

class MyNelfundApp extends StatelessWidget {
  final bool skipSplash;

  const MyNelfundApp({
    super.key,
    this.skipSplash = false,
  });

  @override
  Widget build(BuildContext context) {
    final observer = AnalyticsService.instance.observer;

    return CupertinoApp(
      title: 'My NELFund',
      debugShowCheckedModeBanner: false,
      theme: NelfundTheme.lightTheme,
      navigatorObservers: observer != null ? [observer] : const [],
      home: skipSplash ? const MainTabScaffold() : const SplashView(),
    );
  }
}
