import 'package:flutter/cupertino.dart';
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
  late final CupertinoTabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = CupertinoTabController(initialIndex: widget.initialIndex);
  }

  void setTab(int index) {
    setState(() {
      _tabController.index = index;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
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
    );
  }
}
