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
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildFintechHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
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
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFintechHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          const CupertinoDynamicColor.withBrightness(
            color: Color(0xF2F8FAF8),
            darkColor: Color(0xF2161718),
          ),
          context,
        ),
        border: Border(
          bottom: BorderSide(
            color: CupertinoDynamicColor.resolve(
              const CupertinoDynamicColor.withBrightness(
                color: Color(0x18000000),
                darkColor: Color(0x28FFFFFF),
              ),
              context,
            ),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Top Left: NELFUND icon
          Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: NelfundColors.emerald.withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: NelfundColors.emerald.withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/nelfund_logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Title & Sub-tagline
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'My NELFund',
                  style: NelfundTypography.title2.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Student Loan Guide',
                  style: NelfundTypography.footnote.copyWith(
                    color: CupertinoDynamicColor.resolve(
                      NelfundColors.secondaryLabel,
                      context,
                    ),
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Top Right: Notification Bell Button
          _buildNotificationButton(context),
        ],
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => _showNotificationsSheet(context),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CupertinoDynamicColor.resolve(
                const CupertinoDynamicColor.withBrightness(
                  color: Color(0xFFF0F4F1),
                  darkColor: Color(0xFF242C26),
                ),
                context,
              ),
              border: Border.all(
                color: NelfundColors.emerald.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: const Center(
              child: Icon(
                CupertinoIcons.bell_fill,
                size: 20,
                color: NelfundColors.emerald,
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: const Color(0xFFE53935),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFF161718) : CupertinoColors.white,
                  width: 1.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext modalContext) {
        return Container(
          height: MediaQuery.of(modalContext).size.height * 0.65,
          padding: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            color: CupertinoDynamicColor.resolve(
              const CupertinoDynamicColor.withBrightness(
                color: Color(0xFFFAFCFA),
                darkColor: Color(0xFF161A17),
              ),
              modalContext,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            CupertinoIcons.bell_fill,
                            color: NelfundColors.emerald,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Official Bulletins',
                            style: NelfundTypography.title3.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(modalContext).pop(),
                        child: Text(
                          'Done',
                          style: NelfundTypography.headline.copyWith(
                            color: NelfundColors.emerald,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    children: [
                      _buildNotificationItem(
                        context: modalContext,
                        title: '2024/2025 Application Window Open',
                        body:
                            'Applications for public tertiary institutions are actively underway. Full-time students can submit their requests on nelf.gov.ng without any charges.',
                        timestamp: 'Active Now • 2024/2025 Session',
                        badge: 'Portal Open',
                        badgeColor: CupertinoColors.systemGreen,
                      ),
                      const SizedBox(height: 12),
                      _buildNotificationItem(
                        context: modalContext,
                        title: '0% Zero-Interest Protection',
                        body:
                            'Under Section 15 of the Students Loans Act 2024, all approved loan facilities carry zero interest rate with no hidden bank charges.',
                        timestamp: 'Statutory Act 2024',
                        badge: 'Guaranteed',
                        badgeColor: NelfundColors.emerald,
                      ),
                      const SizedBox(height: 12),
                      _buildNotificationItem(
                        context: modalContext,
                        title: 'Mandatory SVS Profile Upload',
                        body:
                            'Your institution must upload your complete verified matriculation data to the Student Verification System (SVS) before your application can clear verification.',
                        timestamp: 'Guidelines S. 4.2',
                        badge: 'Advisory',
                        badgeColor: const Color(0xFFE67E22),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem({
    required BuildContext context,
    required String title,
    required String body,
    required String timestamp,
    required String badge,
    required Color badgeColor,
  }) {
    return AppleFrostedCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(14),
      borderColor: NelfundColors.emerald.withValues(alpha: 0.18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: NelfundTypography.captionBold.copyWith(
                    color: badgeColor,
                    fontSize: 11,
                  ),
                ),
              ),
              Text(
                timestamp,
                style: NelfundTypography.caption.copyWith(
                  color: CupertinoDynamicColor.resolve(
                    NelfundColors.secondaryLabel,
                    context,
                  ),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: NelfundTypography.headline.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: NelfundTypography.footnote.copyWith(
              color: CupertinoDynamicColor.resolve(
                NelfundColors.secondaryLabel,
                context,
              ),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AppleFrostedCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(16),
        borderColor: NelfundColors.emerald.withValues(alpha: 0.25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: NelfundColors.emerald.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: NelfundColors.emerald.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: NelfundColors.emerald,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Federal Republic of Nigeria',
                        style: NelfundTypography.captionBold.copyWith(
                          color: NelfundColors.emerald,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  'Act 2024',
                  style: NelfundTypography.caption.copyWith(
                    color: CupertinoDynamicColor.resolve(
                      NelfundColors.secondaryLabel,
                      context,
                    ),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Understand your eligibility, calculate statutory repayments, track turnaround SLAs, and explore verified guidelines for the zero-interest student loan program.',
              style: NelfundTypography.body.copyWith(
                color: CupertinoDynamicColor.resolve(
                  NelfundColors.label,
                  context,
                ),
                fontSize: 14.5,
                height: 1.4,
              ),
            ),
          ],
        ),
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
