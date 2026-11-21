import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../core/localization/locale_provider.dart';
import '../core/services/analytics_service.dart';
import '../core/theme/nelfund_theme.dart';
import '../features/calculator/presentation/providers/repayment_provider.dart';
import '../features/eligibility/presentation/providers/eligibility_provider.dart';
import '../features/faq/presentation/providers/faq_provider.dart';
import '../features/notifications/presentation/providers/notification_provider.dart';
import '../features/promo/presentation/providers/promo_provider.dart';
import '../features/splash/presentation/views/splash_view.dart';
import '../features/timeline/presentation/providers/timeline_provider.dart';
import 'app_shell.dart';
import 'fallback_localizations.dart';

/// Root Cupertino application widget for **My NELFund**.
///
/// Configures the global [MultiProvider] dependency graph, bilingual
/// (`en` / `ha`) localization delegates, Firebase screen analytics observer,
/// and either the dual-crest [SplashView] or direct entry into
/// [MainTabScaffold] when [skipSplash] is true.
class MyNelfundApp extends StatelessWidget {
  /// Creates a [MyNelfundApp].
  ///
  /// [skipSplash] bypasses the splash screen in integration and widget tests.
  /// [showStartupPromo] overrides whether the Sauki Go startup card modal is
  /// eligible to appear upon reaching [MainTabScaffold].
  const MyNelfundApp({
    super.key,
    this.skipSplash = false,
    bool? showStartupPromo,
  }) : showStartupPromo = showStartupPromo ?? !skipSplash;

  /// When true, mounts [MainTabScaffold] directly as the initial route.
  final bool skipSplash;

  /// Controls whether startup promo evaluation runs once the tab shell mounts.
  final bool showStartupPromo;

  @override
  Widget build(BuildContext context) {
    final analyticsObserver = AnalyticsService.instance.observer;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LocaleProvider>(create: (_) => LocaleProvider()),
        ChangeNotifierProvider<EligibilityProvider>(
          create: (_) => EligibilityProvider(),
        ),
        ChangeNotifierProvider<RepaymentProvider>(
          create: (_) => RepaymentProvider(),
        ),
        ChangeNotifierProvider<FaqProvider>(create: (_) => FaqProvider()),
        ChangeNotifierProvider<TimelineProvider>(
          create: (_) => TimelineProvider(),
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => NotificationProvider(),
        ),
        ChangeNotifierProvider<PromoProvider>(create: (_) => PromoProvider()),
      ],
      child: Selector<LocaleProvider, Locale>(
        selector: (_, localeProv) => localeProv.locale,
        builder: (context, locale, _) {
          final isDark =
              MediaQuery.platformBrightnessOf(context) == Brightness.dark;
          return CupertinoApp(
            title: 'My NELFund',
            debugShowCheckedModeBanner: false,
            locale: locale,
            supportedLocales: const [Locale('en'), Locale('ha')],
            theme: isDark ? NelfundTheme.darkTheme : NelfundTheme.lightTheme,
            localizationsDelegates: const [
              FallbackCupertinoLocalizationsDelegate(),
              FallbackMaterialLocalizationsDelegate(),
              GlobalCupertinoLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            navigatorObservers: analyticsObserver != null
                ? [analyticsObserver]
                : const [],
            onGenerateRoute: (settings) {
              return CupertinoPageRoute<void>(
                builder: (_) => skipSplash
                    ? MainTabScaffold(showStartupPromo: showStartupPromo)
                    : SplashView(showStartupPromo: showStartupPromo),
              );
            },
            home: skipSplash
                ? MainTabScaffold(showStartupPromo: showStartupPromo)
                : SplashView(showStartupPromo: showStartupPromo),
          );
        },
      ),
    );
  }
}

/// Shared provider-scoping helper allowing standalone feature views to render
/// safely even when mounted directly inside isolated widget tests without an
/// ancestor [MultiProvider].
abstract final class AppProviders {
  /// Returns `T` if registered above [context], otherwise `null`.
  static T? maybeRead<T>(BuildContext context) {
    try {
      return Provider.of<T>(context, listen: false);
    } on ProviderNotFoundException {
      return null;
    }
  }

  /// Ensures a single provider `T` exists above [child], creating it via
  /// [create] only when absent from ancestor widget tree.
  static Widget ensure<T extends ChangeNotifier>(
    BuildContext context, {
    required T Function() create,
    required Widget child,
  }) {
    if (maybeRead<T>(context) != null) {
      return child;
    }
    return ChangeNotifierProvider<T>(create: (_) => create(), child: child);
  }
}
