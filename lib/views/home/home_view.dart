import 'package:flutter/cupertino.dart';
import '../../core/constants/nelfund_data.dart';
import '../../core/theme/nelfund_colors.dart';
import '../../core/theme/nelfund_typography.dart';
import '../../widgets/apple_frosted_card.dart';
import '../main_tab_scaffold.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                'assets/images/nelfund_logo.png',
                width: 22,
                height: 22,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 8),
            const Text('My NELFund'),
          ],
        ),
        backgroundColor: CupertinoDynamicColor.resolve(
          const CupertinoDynamicColor.withBrightness(
            color: Color(0xCCF8FAF8),
            darkColor: Color(0xCC161718),
          ),
          context,
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            _buildHeroHeader(context),
            const SizedBox(height: 12),
            _buildWindowStatusCard(context),
            const SizedBox(height: 16),
            _buildSectionHeader('Key Loan Pillars (Act 2024)'),
            _buildCorePillars(context),
            const SizedBox(height: 16),
            _buildSectionHeader('Explore Tools & Guides'),
            _buildQuickAccessGrid(context),
            const SizedBox(height: 16),
            _buildSectionHeader('Program Overview'),
            _buildActOverviewCard(context),
            const SizedBox(height: 16),
            _buildDisclaimerCard(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 68,
                height: 68,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0x1F000000),
                    width: 0.8,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/nelfund_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: NelfundColors.emerald.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Federal Republic of Nigeria',
                        style: NelfundTypography.captionBold.copyWith(
                          color: NelfundColors.emerald,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'My NELFund',
                      style: NelfundTypography.title2.copyWith(
                        color: NelfundColors.label,
                      ),
                    ),
                    Text(
                      'Student Loan Program Guide',
                      style: NelfundTypography.subhead,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Understand your eligibility, calculate your statutory repayment, track official evaluation timelines, and learn how the zero-interest student loan works.',
            style: NelfundTypography.body.copyWith(
              color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel, context),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWindowStatusCard(BuildContext context) {
    return AppleFrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: CupertinoColors.systemGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    NelfundData.windowStatusText,
                    style: NelfundTypography.headline.copyWith(
                      color: CupertinoColors.systemGreen,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: NelfundColors.emerald.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  NelfundData.currentAcademicSession,
                  style: NelfundTypography.captionBold.copyWith(
                    color: NelfundColors.emerald,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            NelfundData.currentBatchName,
            style: NelfundTypography.headline.copyWith(fontSize: 17),
          ),
          const SizedBox(height: 6),
          Text(
            NelfundData.windowAdvisory,
            style: NelfundTypography.footnote.copyWith(
              color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel, context),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: CupertinoDynamicColor.resolve(
                const CupertinoDynamicColor.withBrightness(
                  color: Color(0x0C008751),
                  darkColor: Color(0x1F008751),
                ),
                context,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.info_circle_fill,
                  size: 16,
                  color: NelfundColors.emerald,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Official Portal: nelf.gov.ng • Free to apply (No fee)',
                    style: NelfundTypography.captionBold.copyWith(
                      color: NelfundColors.emerald,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Text(
        title,
        style: NelfundTypography.title3.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCorePillars(BuildContext context) {
    return Column(
      children: [
        _buildPillarTile(
          context: context,
          icon: CupertinoIcons.percent,
          title: '0% Zero Interest',
          subtitle:
              'No compounding fees or interest accumulation. You only repay the exact principal amount disbursed.',
          tag: '100% Interest-Free',
          tagColor: CupertinoColors.systemGreen,
        ),
        _buildPillarTile(
          context: context,
          icon: CupertinoIcons.building_2_fill,
          title: 'Direct Tuition Disbursement',
          subtitle:
              'Institutional fees are paid electronically and directly to your tertiary institution upon verification.',
          tag: '100% Institutional',
          tagColor: NelfundColors.emerald,
        ),
        _buildPillarTile(
          context: context,
          icon: CupertinoIcons.money_dollar_circle_fill,
          title: '₦20,000 Monthly Upkeep',
          subtitle:
              'Optional living stipend paid monthly directly into your personal bank account to support study costs.',
          tag: 'Direct to Student',
          tagColor: CupertinoColors.systemOrange,
        ),
      ],
    );
  }

  Widget _buildPillarTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String tag,
    required Color tagColor,
  }) {
    return AppleFrostedCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: tagColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(icon, color: tagColor, size: 22),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: NelfundTypography.headline.copyWith(fontSize: 16),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: tagColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: NelfundTypography.captionBold.copyWith(
                          color: tagColor,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: NelfundTypography.footnote.copyWith(
                    color: CupertinoDynamicColor.resolve(
                        NelfundColors.secondaryLabel, context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context: context,
                  icon: CupertinoIcons.checkmark_shield_fill,
                  iconColor: NelfundColors.emerald,
                  title: 'Eligibility Checker',
                  description: 'Interactive checklist & disqualification audit',
                  tabIndex: 1,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildActionCard(
                  context: context,
                  icon: CupertinoIcons.chart_pie_fill,
                  iconColor: CupertinoColors.systemIndigo,
                  title: 'Repayment Calc',
                  description: '10% PAYE/IBR & 2-year NYSC countdown',
                  tabIndex: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context: context,
                  icon: CupertinoIcons.question_circle_fill,
                  iconColor: CupertinoColors.systemTeal,
                  title: 'Official FAQ',
                  description: 'GSI mandate, quarterly reporting & recovery',
                  tabIndex: 3,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildActionCard(
                  context: context,
                  icon: CupertinoIcons.clock_fill,
                  iconColor: CupertinoColors.systemOrange,
                  title: 'SLA Timeline',
                  description: 'Journey map & check if your app is on-track',
                  tabIndex: 4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required int tabIndex,
  }) {
    return AppleFrostedCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(14),
      onTap: () {
        MainTabScaffold.switchTab(context, tabIndex);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(icon, color: iconColor, size: 20),
                ),
              ),
              const Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: CupertinoColors.tertiaryLabel,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: NelfundTypography.headline.copyWith(fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: NelfundTypography.footnote.copyWith(
              color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel, context),
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActOverviewCard(BuildContext context) {
    return AppleFrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.book_fill,
                color: NelfundColors.emerald,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  NelfundData.actTitle,
                  style: NelfundTypography.headline.copyWith(fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            NelfundData.actSummary,
            style: NelfundTypography.body.copyWith(
              fontSize: 14,
              color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel, context),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Primary Legal Provisions:',
            style: NelfundTypography.captionBold.copyWith(
              color: NelfundColors.label,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          _buildBulletItem(
              'Repealed the 2023 Student Loan Act to remove family income barriers.'),
          _buildBulletItem(
              'No guarantor or collateral requirement for eligible public students.'),
          _buildBulletItem(
              'Mandatory 2-year post-NYSC grace period before loan recovery begins.'),
          _buildBulletItem(
              'Forgiveness / extension provisions for beneficiaries facing documented unemployment.'),
        ],
      ),
    );
  }

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: NelfundColors.emerald)),
          Expanded(
            child: Text(
              text,
              style: NelfundTypography.footnote,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerCard(BuildContext context) {
    return AppleFrostedCard(
      backgroundColor: CupertinoDynamicColor.resolve(
        const CupertinoDynamicColor.withBrightness(
          color: Color(0xF2F5F5F7),
          darkColor: Color(0xF21C1C1E),
        ),
        context,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.shield_lefthalf_fill,
                size: 16,
                color: CupertinoColors.secondaryLabel,
              ),
              const SizedBox(width: 6),
              Text(
                'Transparency Notice',
                style: NelfundTypography.captionBold,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            NelfundData.independentDisclaimer,
            style: NelfundTypography.caption.copyWith(
              color: CupertinoDynamicColor.resolve(
                  NelfundColors.tertiaryLabel, context),
            ),
          ),
        ],
      ),
    );
  }
}
