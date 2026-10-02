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
import '../widgets/liquid_glass_nav_bar.dart';
import 'about/about_view.dart';
import 'calculator/calculator_view.dart';
import 'eligibility/eligibility_view.dart';
import 'faq/faq_view.dart';
import 'home/home_view.dart';

class MainTabScaffold extends StatelessWidget {
  final int initialIndex;
  final bool showLanguageOnboarding;
  const MainTabScaffold({
    super.key,
    this.initialIndex = 0,
    this.showLanguageOnboarding = false,
  });

  static void switchTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_MainTabScaffoldContentState>();
    state?.setTab(index);
  }

  @override
  Widget build(BuildContext context) {
    LocaleProvider? localeProv;
    try {
      localeProv = Provider.of<LocaleProvider?>(context, listen: false);
    } catch (_) {}

    final content = _MainTabScaffoldContent(
      initialIndex: initialIndex,
      showLanguageOnboarding: showLanguageOnboarding,
    );
    if (localeProv == null) {
      return ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: content,
      );
    }
    return content;
  }
}

class _MainTabScaffoldContent extends StatefulWidget {
  final int initialIndex;
  final bool showLanguageOnboarding;
  const _MainTabScaffoldContent({
    this.initialIndex = 0,
    this.showLanguageOnboarding = false,
  });

  @override
  State<_MainTabScaffoldContent> createState() => _MainTabScaffoldContentState();
}

class _MainTabScaffoldContentState extends State<_MainTabScaffoldContent> {
  static const List<String> _tabNames = [
    'Home',
    'Eligibility',
    'Calculator',
    'FAQ',
    'About',
  ];

  late int _currentIndex;
  DateTime? _lastBackPressTime;
  OverlayEntry? _toastEntry;
  Timer? _toastTimer;
  StreamSubscription? _foregroundNotificationSub;

  final List<GlobalKey<NavigatorState>> _tabNavKeys = [
    GlobalKey<NavigatorState>(debugLabel: 'HomeNav'),
    GlobalKey<NavigatorState>(debugLabel: 'EligibilityNav'),
    GlobalKey<NavigatorState>(debugLabel: 'CalculatorNav'),
    GlobalKey<NavigatorState>(debugLabel: 'FaqNav'),
    GlobalKey<NavigatorState>(debugLabel: 'AboutNav'),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _logCurrentTab(_currentIndex);
    _initAppServices();
  }

  void _logCurrentTab(int index) {
    if (index >= 0 && index < _tabNames.length) {
      AnalyticsService.instance.logTabSelected(index, _tabNames[index]);
      AnalyticsService.instance.logScreenView(_tabNames[index]);
    }
  }

  void _initAppServices() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _foregroundNotificationSub = NotificationService.instance
          .attachForegroundListener(context);
      await ReviewService.instance.recordAppLaunch();
      if (!mounted) return;
      await UpdateService.instance.checkForUpdates(context);
      if (!mounted) return;
      if (await ReviewService.instance.shouldPromptReview()) {
        if (!mounted) return;
        await ReviewService.instance.showRatingDialog(context);
      }
    });
  }

  void setTab(int index) {
    if (_currentIndex == index) {
      // Pop to root if tapping active tab again
      final navState = _tabNavKeys[index].currentState;
      if (navState != null && navState.canPop()) {
        navState.popUntil((route) => route.isFirst);
      }
      return;
    }

    setState(() {
      _currentIndex = index;
    });
    _logCurrentTab(index);
  }

  void _handleBackPress() {
    // 1. Check if the current tab's nested navigator can pop
    final currentNavState = _tabNavKeys[_currentIndex].currentState;
    if (currentNavState != null && currentNavState.canPop()) {
      currentNavState.pop();
      return;
    }

    // 2. If on any bottom navigation tab other than Home, return to Home
    if (_currentIndex != 0) {
      setTab(0);
      return;
    }

    // 3. If on Home at root, require double-tap back within 2 seconds to exit
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      _showExitToast();
      return;
    }

    // Double back pressed on Home -> Clean application exit
    _toastEntry?.remove();
    _toastEntry = null;
    SystemNavigator.pop();
  }

  void _showExitToast() {
    _toastEntry?.remove();
    _toastEntry = OverlayEntry(
      builder: (ctx) => Positioned(
        bottom: 92,
        left: 24,
        right: 24,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xE61A202C),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  CupertinoIcons.info_circle_fill,
                  color: Color(0xFF68D391),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  AppTranslations.of(context).backToExitToast,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final overlay = Overlay.maybeOf(context);
    if (overlay != null) {
      overlay.insert(_toastEntry!);
      _toastTimer?.cancel();
      _toastTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          _toastEntry?.remove();
          _toastEntry = null;
        }
      });
    }
  }

  @override
  void dispose() {
    _foregroundNotificationSub?.cancel();
    _toastTimer?.cancel();
    _toastTimer = null;
    _toastEntry?.remove();
    _toastEntry = null;
    super.dispose();
  }

  Widget _buildTabView(int index) {
    switch (index) {
      case 0:
        return HomeView(showLanguageOnboarding: widget.showLanguageOnboarding);
      case 1:
        return const EligibilityView();
      case 2:
        return const CalculatorView();
      case 3:
        return const FaqView();
      case 4:
        return const AboutView();
      default:
        return const CupertinoPageScaffold(
          child: Center(child: Text('Unknown')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppTranslations.of(context);

    final navItems = [
      LiquidGlassNavItem(
        icon: CupertinoIcons.house_alt,
        activeIcon: CupertinoIcons.house_alt_fill,
        label: tr.tabHome,
      ),
      LiquidGlassNavItem(
        icon: CupertinoIcons.checkmark_seal,
        activeIcon: CupertinoIcons.checkmark_seal_fill,
        label: tr.tabEligibility,
      ),
      LiquidGlassNavItem(
        icon: CupertinoIcons.creditcard,
        activeIcon: CupertinoIcons.creditcard_fill,
        label: tr.tabCalculator,
      ),
      LiquidGlassNavItem(
        icon: CupertinoIcons.bubble_left_bubble_right,
        activeIcon: CupertinoIcons.bubble_left_bubble_right_fill,
        label: tr.tabFaq,
      ),
      LiquidGlassNavItem(
        icon: CupertinoIcons.person_crop_circle,
        activeIcon: CupertinoIcons.person_crop_circle_fill,
        label: tr.tabAbout,
      ),
    ];

    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPress();
      },
      child: CupertinoPageScaffold(
        resizeToAvoidBottomInset: false,
        child: Stack(
          children: [
            // Ambient Chromatic Canvas
            _buildAmbientBackground(context, isDark),

            // Active Tab Page View
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusScope.of(context).unfocus(),
              child: IndexedStack(
                index: _currentIndex,
                children: List.generate(5, (index) {
                  return CupertinoTabView(
                    navigatorKey: _tabNavKeys[index],
                    builder: (context) => _buildTabView(index),
                  );
                }),
              ),
            ),

            // Floating Liquid Glass Navigation Dock
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                child: LiquidGlassNavBar(
                  selectedIndex: _currentIndex,
                  onTap: setTab,
                  items: navItems,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmbientBackground(BuildContext context, bool isDark) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: isDark ? const Color(0xFF111412) : const Color(0xFFF5F8F6),
          child: Stack(
            children: [
              // Top-right subtle emerald aura orb
              Positioned(
                top: -60,
                right: -60,
                width: 240,
                height: 240,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        NelfundColors.emerald.withValues(alpha: isDark ? 0.16 : 0.08),
                        CupertinoColors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Bottom-left subtle emerald aura orb
              Positioned(
                bottom: 20,
                left: -40,
                width: 260,
                height: 260,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        (isDark ? const Color(0xFF2FD18B) : NelfundColors.emerald)
                            .withValues(alpha: isDark ? 0.12 : 0.06),
                        CupertinoColors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
