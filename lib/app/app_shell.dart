import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/localization/app_translations.dart';
import '../core/localization/locale_provider.dart';
import '../core/services/analytics_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/review_service.dart';
import '../core/services/update_service.dart';
import '../core/theme/nelfund_colors.dart';
import '../features/about/presentation/views/about_view.dart';
import '../features/calculator/presentation/views/calculator_view.dart';
import '../features/eligibility/presentation/views/eligibility_view.dart';
import '../features/faq/presentation/providers/faq_provider.dart';
import '../features/faq/presentation/views/faq_view.dart';
import '../features/home/presentation/views/home_view.dart';
import '../features/notifications/presentation/providers/notification_provider.dart';
import '../features/promo/presentation/providers/promo_provider.dart';
import '../shared/widgets/liquid_glass_nav_bar.dart';
import 'app.dart';

/// Root five-tab navigation container for **My NELFund** featuring nested
/// per-tab [Navigator] stacks, a floating translucent [LiquidGlassNavBar],
/// Android double-back-to-exit protection, and foreground notification hooks.
class MainTabScaffold extends StatefulWidget {
  /// Creates a [MainTabScaffold].
  const MainTabScaffold({
    super.key,
    this.initialIndex = 0,
    this.showStartupPromo = false,
  });

  /// Initial active bottom navigation index (`0..4`).
  final int initialIndex;

  /// Forwarded to [HomeView] so startup promo checks run once mounted.
  final bool showStartupPromo;

  /// Switches the active bottom navigation tab from any descendant subtree.
  static void switchTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_MainTabScaffoldState>();
    state?.selectTab(index);
  }

  @override
  State<MainTabScaffold> createState() => _MainTabScaffoldState();
}

class _MainTabScaffoldState extends State<MainTabScaffold> {
  static const List<String> _tabNames = [
    'Home',
    'Eligibility',
    'Calculator',
    'FAQ',
    'About',
  ];

  late int _currentIndex;
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(debugLabel: 'HomeNav'),
    GlobalKey<NavigatorState>(debugLabel: 'EligibilityNav'),
    GlobalKey<NavigatorState>(debugLabel: 'CalculatorNav'),
    GlobalKey<NavigatorState>(debugLabel: 'FaqNav'),
    GlobalKey<NavigatorState>(debugLabel: 'AboutNav'),
  ];

  DateTime? _lastBackPressedAt;
  OverlayEntry? _exitToastEntry;
  Timer? _exitToastTimer;
  StreamSubscription<dynamic>? _foregroundNotificationSub;
  bool _servicesInitialized = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 4);
    _logCurrentTab(_currentIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initAppServices());
  }

  void _logCurrentTab(int index) {
    if (index >= 0 && index < _tabNames.length) {
      AnalyticsService.instance.logTabSelected(index, _tabNames[index]);
      AnalyticsService.instance.logScreenView(_tabNames[index]);
    }
  }

  Future<void> _initAppServices() async {
    if (!mounted || _servicesInitialized) {
      return;
    }
    _servicesInitialized = true;

    _foregroundNotificationSub = NotificationService.instance
        .attachForegroundListener(context);
    await ReviewService.instance.recordAppLaunch();
    if (!mounted) {
      return;
    }
    await UpdateService.instance.checkForUpdates(context);
    if (!mounted) {
      return;
    }
    if (await ReviewService.instance.shouldPromptReview()) {
      if (!mounted) {
        return;
      }
      await ReviewService.instance.showRatingDialog(context);
    }
  }

  @override
  void dispose() {
    _exitToastTimer?.cancel();
    _foregroundNotificationSub?.cancel();
    if (_exitToastEntry?.mounted == true) {
      _exitToastEntry?.remove();
    }
    _exitToastEntry = null;
    super.dispose();
  }

  /// Switches to [index] or pops the active nested navigator to its root if
  /// the user taps the already-active tab.
  void selectTab(int index) {
    final safeIndex = index.clamp(0, 4);
    if (safeIndex == _currentIndex) {
      _navigatorKeys[safeIndex].currentState?.popUntil(
        (route) => route.isFirst,
      );
      return;
    }

    setState(() => _currentIndex = safeIndex);
    _logCurrentTab(safeIndex);
  }

  Future<void> _handleSystemBack() async {
    final currentNavigator = _navigatorKeys[_currentIndex].currentState;
    if (currentNavigator != null && currentNavigator.canPop()) {
      currentNavigator.pop();
      return;
    }

    if (_currentIndex != 0) {
      selectTab(0);
      return;
    }

    final now = DateTime.now();
    if (_lastBackPressedAt == null ||
        now.difference(_lastBackPressedAt!) > const Duration(seconds: 2)) {
      _lastBackPressedAt = now;
      _showExitConfirmationToast();
      return;
    }

    await SystemNavigator.pop();
  }

  void _showExitConfirmationToast() {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) {
      return;
    }

    _exitToastTimer?.cancel();
    if (_exitToastEntry?.mounted == true) {
      _exitToastEntry?.remove();
    }

    final tr = AppTranslations.of(context);

    final entry = OverlayEntry(
      builder: (ctx) => Positioned(
        left: 32,
        right: 32,
        bottom: 102 + MediaQuery.paddingOf(ctx).bottom,
        child: IgnorePointer(
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xE0141C18),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: NelfundColors.emerald.withValues(alpha: 0.4),
                  width: 0.75,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                tr.backToExitToast,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    _exitToastEntry = entry;
    overlay.insert(entry);
    _exitToastTimer = Timer(const Duration(seconds: 2), () {
      if (_exitToastEntry?.mounted == true) {
        _exitToastEntry?.remove();
      }
      _exitToastEntry = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasLocale = AppProviders.maybeRead<LocaleProvider>(context) != null;

    Widget content = Builder(
      builder: (innerContext) {
        final tr = AppTranslations.of(innerContext);
        final items = [
          LiquidGlassNavItem(icon: CupertinoIcons.house_alt, label: tr.tabHome),
          LiquidGlassNavItem(
            icon: CupertinoIcons.checkmark_seal,
            label: tr.tabEligibility,
          ),
          LiquidGlassNavItem(
            icon: CupertinoIcons.creditcard,
            label: tr.tabCalculator,
          ),
          LiquidGlassNavItem(
            icon: CupertinoIcons.bubble_left_bubble_right,
            label: tr.tabFaq,
          ),
          LiquidGlassNavItem(
            icon: CupertinoIcons.person_crop_circle,
            label: tr.tabAbout,
          ),
        ];

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              _handleSystemBack();
            }
          },
          child: CupertinoPageScaffold(
            child: Stack(
              children: [
                const RepaintBoundary(child: _AmbientAuraBackground()),
                IndexedStack(
                  index: _currentIndex,
                  children: [
                    _TabNavigator(
                      navigatorKey: _navigatorKeys[0],
                      root: HomeView(showStartupPromo: widget.showStartupPromo),
                    ),
                    _TabNavigator(
                      navigatorKey: _navigatorKeys[1],
                      root: const EligibilityView(),
                    ),
                    _TabNavigator(
                      navigatorKey: _navigatorKeys[2],
                      root: const CalculatorView(),
                    ),
                    _TabNavigator(
                      navigatorKey: _navigatorKeys[3],
                      root: const FaqView(),
                    ),
                    _TabNavigator(
                      navigatorKey: _navigatorKeys[4],
                      root: const AboutView(),
                    ),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: LiquidGlassNavBar(
                    currentIndex: _currentIndex,
                    items: items,
                    onTap: selectTab,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!hasLocale) {
      content = MultiProvider(
        providers: [
          ChangeNotifierProvider<LocaleProvider>(
            create: (_) => LocaleProvider(),
          ),
          ChangeNotifierProvider<FaqProvider>(create: (_) => FaqProvider()),
          ChangeNotifierProvider<NotificationProvider>(
            create: (_) => NotificationProvider(),
          ),
          ChangeNotifierProvider<PromoProvider>(create: (_) => PromoProvider()),
        ],
        child: content,
      );
    }

    return content;
  }
}

class _TabNavigator extends StatelessWidget {
  const _TabNavigator({required this.navigatorKey, required this.root});

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget root;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (_) => CupertinoPageRoute<void>(builder: (_) => root),
    );
  }
}

class _AmbientAuraBackground extends StatelessWidget {
  const _AmbientAuraBackground();

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final topOrbOpacity = isDark ? 0.14 : 0.08;
    final bottomOrbOpacity = isDark ? 0.10 : 0.06;

    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -110,
            right: -70,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    NelfundColors.emerald.withValues(alpha: topOrbOpacity),
                    NelfundColors.emerald.withValues(alpha: 0),
                  ],
                ),
              ),
              child: const SizedBox(width: 280, height: 280),
            ),
          ),
          Positioned(
            bottom: -90,
            left: -80,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    NelfundColors.emerald.withValues(alpha: bottomOrbOpacity),
                    NelfundColors.emerald.withValues(alpha: 0),
                  ],
                ),
              ),
              child: const SizedBox(width: 260, height: 260),
            ),
          ),
        ],
      ),
    );
  }
}
