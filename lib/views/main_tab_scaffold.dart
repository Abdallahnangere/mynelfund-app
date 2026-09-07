import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../core/services/analytics_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/review_service.dart';
import '../core/services/update_service.dart';
import '../core/theme/nelfund_colors.dart';
import 'calculator/calculator_view.dart';
import 'eligibility/eligibility_view.dart';
import 'faq/faq_view.dart';
import 'home/home_view.dart';
import 'about/about_view.dart';

class MainTabScaffold extends StatefulWidget {
  final int initialIndex;
  const MainTabScaffold({super.key, this.initialIndex = 0});

  static void switchTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_MainTabScaffoldState>();
    state?.setTab(index);
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

  late final CupertinoTabController _tabController;
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
    _tabController = CupertinoTabController(initialIndex: widget.initialIndex);
    _tabController.addListener(_onTabChanged);
    _initAppServices();
  }

  void _onTabChanged() {
    final index = _tabController.index;
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
    setState(() {
      _tabController.index = index;
    });
  }

  void _handleBackPress() {
    // 1. Check if the current tab's nested navigator can pop
    final currentNavState = _tabNavKeys[_tabController.index].currentState;
    if (currentNavState != null && currentNavState.canPop()) {
      currentNavState.pop();
      return;
    }

    // 2. If on any bottom navigation tab other than Home, return to Home
    if (_tabController.index != 0) {
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
        bottom: 80,
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
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.info_circle_fill,
                  color: Color(0xFF68D391),
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  'Press back again to exit',
                  style: TextStyle(
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
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPress();
      },
      child: CupertinoTabScaffold(
        controller: _tabController,
        tabBar: CupertinoTabBar(
          height: 56,
          activeColor: NelfundColors.emeraldTint,
          inactiveColor: CupertinoColors.secondaryLabel,
          backgroundColor: CupertinoDynamicColor.resolve(
            CupertinoDynamicColor.withBrightness(
              color: const Color(0xEBF8FAF8),
              darkColor: const Color(0xE8181A18),
            ),
            context,
          ),
          border: const Border(
            top: BorderSide(
              color: Color(0x1F000000),
              width: 0.5,
            ),
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.house),
              activeIcon: Icon(CupertinoIcons.house_fill),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.checkmark_shield),
              activeIcon: Icon(CupertinoIcons.checkmark_shield_fill),
              label: 'Eligibility',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chart_pie),
              activeIcon: Icon(CupertinoIcons.chart_pie_fill),
              label: 'Calculator',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.question_circle),
              activeIcon: Icon(CupertinoIcons.question_circle_fill),
              label: 'FAQ',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.info_circle),
              activeIcon: Icon(CupertinoIcons.info_circle_fill),
              label: 'About',
            ),
          ],
        ),
        tabBuilder: (context, index) {
          return CupertinoTabView(
            navigatorKey: _tabNavKeys[index],
            builder: (context) {
              switch (index) {
                case 0:
                  return const HomeView();
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
            },
          );
        },
      ),
    );
  }
}
