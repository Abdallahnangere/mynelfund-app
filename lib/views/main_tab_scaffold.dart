import 'package:flutter/cupertino.dart';
import '../core/theme/nelfund_colors.dart';
import '../core/theme/nelfund_typography.dart';
import '../widgets/apple_frosted_card.dart';
import 'home/home_view.dart';

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
            icon: Icon(CupertinoIcons.clock),
            activeIcon: Icon(CupertinoIcons.clock_fill),
            label: 'Timeline',
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
                return _buildPlaceholderView(
                  title: 'Eligibility Checker',
                  subtitle: 'Official 2024 Criteria & Disqualification Test',
                  icon: CupertinoIcons.checkmark_shield_fill,
                  tabName: 'Eligibility',
                  segmentBadge: 'Segment 3 Ready',
                );
              case 2:
                return _buildPlaceholderView(
                  title: 'Repayment Calculator',
                  subtitle: '10% PAYE/IBR & 2-Year Moratorium Simulator',
                  icon: CupertinoIcons.chart_pie_fill,
                  tabName: 'Calculator',
                  segmentBadge: 'Segment 4 Ready',
                );
              case 3:
                return _buildPlaceholderView(
                  title: 'Official FAQ',
                  subtitle: 'Applying, Disbursement, GSI & Recovery Rules',
                  icon: CupertinoIcons.question_circle_fill,
                  tabName: 'FAQ',
                  segmentBadge: 'Segment 5 Ready',
                );
              case 4:
                return _buildPlaceholderView(
                  title: 'SLA Timeline Tracker',
                  subtitle: 'Official Turnaround Times & Journey Map',
                  icon: CupertinoIcons.clock_fill,
                  tabName: 'Timeline',
                  segmentBadge: 'Segment 6 Ready',
                );
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

  Widget _buildPlaceholderView({
    required String title,
    required String subtitle,
    required IconData icon,
    required String tabName,
    required String segmentBadge,
  }) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(tabName),
        backgroundColor: CupertinoDynamicColor.resolve(
          CupertinoDynamicColor.withBrightness(
            color: const Color(0xCCF8FAF8),
            darkColor: const Color(0xCC161718),
          ),
          context,
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: NelfundTypography.largeTitle.copyWith(
                      color: NelfundColors.emeraldTint,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: NelfundTypography.subhead,
                  ),
                ],
              ),
            ),
            AppleFrostedCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: NelfundColors.emerald.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        size: 36,
                        color: NelfundColors.emerald,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: NelfundColors.emerald.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      segmentBadge,
                      style: NelfundTypography.captionBold.copyWith(
                        color: NelfundColors.emerald,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Cupertino HIG Layout Active',
                    style: NelfundTypography.headline,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'This tab will be fully populated in its designated segment.',
                    textAlign: TextAlign.center,
                    style: NelfundTypography.footnote,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
