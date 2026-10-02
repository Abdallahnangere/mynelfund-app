import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/nelfund_data.dart';
import '../../core/localization/app_locale.dart';
import '../../core/localization/app_translations.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/nelfund_colors.dart';
import '../../core/theme/nelfund_typography.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/apple_frosted_card.dart';
import '../../widgets/liquid_glass_header.dart';
import '../main_tab_scaffold.dart';
import '../notifications/notifications_view.dart';
import '../timeline/timeline_view.dart';

class HomeView extends StatelessWidget {
  final bool showLanguageOnboarding;
  const HomeView({super.key, this.showLanguageOnboarding = false});

  @override
  Widget build(BuildContext context) {
    LocaleProvider? localeProv;
    try {
      localeProv = Provider.of<LocaleProvider?>(context, listen: false);
    } catch (_) {}

    final content = _HomeViewContent(
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

class _HomeViewContent extends StatefulWidget {
  final bool showLanguageOnboarding;
  const _HomeViewContent({this.showLanguageOnboarding = false});

  @override
  State<_HomeViewContent> createState() => _HomeViewContentState();
}

class _HomeViewContentState extends State<_HomeViewContent> {
  @override
  void initState() {
    super.initState();
    if (widget.showLanguageOnboarding) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkFirstTimeLanguageModal();
      });
    }
  }

  Future<void> _checkFirstTimeLanguageModal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeen = prefs.getBool('has_seen_language_modal_v2') ?? false;
      if (!hasSeen && mounted) {
        await _showLanguageOnboardingDialog(context);
      }
    } catch (e) {
      debugPrint('[HomeView] Language onboarding check error: $e');
    }
  }

  Future<void> _showLanguageOnboardingDialog(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_language_modal_v2', true);
    } catch (_) {}

    if (!context.mounted) return;

    await showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => const _LanguageOnboardingDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppTranslations.of(context);

    return CupertinoPageScaffold(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildFintechHeader(context),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 88),
                children: [
                  _buildSectionHeader(tr.programOverviewTitle),
                  _buildActOverviewCard(context),
                  const SizedBox(height: 16),
                  _buildSectionHeader(tr.keyLoanPillarsTitle),
                  _buildCorePillars(context),
                  const SizedBox(height: 16),
                  _buildSectionHeader(tr.exploreToolsTitle),
                  _buildQuickAccessGrid(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFintechHeader(BuildContext context) {
    final tr = AppTranslations.of(context);

    return LiquidGlassHeader(
      title: tr.appTitle,
      subtitle: tr.appSubtitle,
      leading: Container(
        width: 42,
        height: 42,
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
      trailing: _buildNotificationButton(context),
      bottom: _buildHeaderLanguageToggle(context),
    );
  }

  Widget _buildHeaderLanguageToggle(BuildContext context) {
    LocaleProvider? localeProv;
    try {
      localeProv = Provider.of<LocaleProvider?>(context);
    } catch (_) {}
    final isHausa = localeProv?.isHausa ?? false;
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          const CupertinoDynamicColor.withBrightness(
            color: Color(0xFFE8EFE9),
            darkColor: Color(0xFF222824),
          ),
          context,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: NelfundColors.emerald.withValues(alpha: isDark ? 0.25 : 0.15),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          // English Segment
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (isHausa) {
                  HapticFeedback.selectionClick();
                  localeProv?.setLanguage(AppLanguage.english);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !isHausa
                      ? (isDark ? const Color(0xFF153822) : CupertinoColors.white)
                      : CupertinoColors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: !isHausa
                      ? [
                          BoxShadow(
                            color: CupertinoColors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 1.5),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🇬🇧', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      'English',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: !isHausa ? FontWeight.w700 : FontWeight.w500,
                        color: !isHausa
                            ? NelfundColors.emerald
                            : CupertinoDynamicColor.resolve(
                                NelfundColors.secondaryLabel,
                                context,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Hausa Segment
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (!isHausa) {
                  HapticFeedback.selectionClick();
                  localeProv?.setLanguage(AppLanguage.hausa);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isHausa
                      ? (isDark ? const Color(0xFF153822) : CupertinoColors.white)
                      : CupertinoColors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: isHausa
                      ? [
                          BoxShadow(
                            color: CupertinoColors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 1.5),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🇳🇬', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      'Harshen Hausa',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isHausa ? FontWeight.w700 : FontWeight.w500,
                        color: isHausa
                            ? NelfundColors.emerald
                            : CupertinoDynamicColor.resolve(
                                NelfundColors.secondaryLabel,
                                context,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    NotificationProvider? notifProv;
    try {
      notifProv = Provider.of<NotificationProvider>(context);
    } catch (_) {}
    final hasUnread = notifProv?.hasUnread ?? false;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => const NotificationsView(),
          ),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38,
            height: 38,
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
                size: 18,
                color: NelfundColors.emerald,
              ),
            ),
          ),
          if (hasUnread)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 10,
                height: 10,
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
    final localeProv = context.watch<LocaleProvider>();
    final pillars = NelfundData.getCorePillars(localeProv.currentLanguage);

    return Column(
      children: [
        _buildPillarTile(
          context: context,
          icon: CupertinoIcons.percent,
          title: pillars[0]['title']!,
          subtitle: pillars[0]['subtitle']!,
          tag: pillars[0]['highlight']!,
          tagColor: CupertinoColors.systemGreen,
        ),
        _buildPillarTile(
          context: context,
          icon: CupertinoIcons.building_2_fill,
          title: pillars[1]['title']!,
          subtitle: pillars[1]['subtitle']!,
          tag: pillars[1]['highlight']!,
          tagColor: NelfundColors.emerald,
        ),
        _buildPillarTile(
          context: context,
          icon: CupertinoIcons.money_dollar_circle_fill,
          title: pillars[2]['title']!,
          subtitle: pillars[2]['subtitle']!,
          tag: pillars[2]['highlight']!,
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
                        style: NelfundTypography.headline.copyWith(fontSize: 15.5),
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
    final tr = AppTranslations.of(context);

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
                  title: tr.cardEligibilityTitle,
                  description: tr.cardEligibilityDesc,
                  tabIndex: 1,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildActionCard(
                  context: context,
                  icon: CupertinoIcons.chart_pie_fill,
                  iconColor: CupertinoColors.systemIndigo,
                  title: tr.cardCalcTitle,
                  description: tr.cardCalcDesc,
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
                  title: tr.cardFaqTitle,
                  description: tr.cardFaqDesc,
                  tabIndex: 3,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildActionCard(
                  context: context,
                  icon: CupertinoIcons.info_circle_fill,
                  iconColor: CupertinoColors.systemOrange,
                  title: tr.cardAboutTitle,
                  description: tr.cardAboutDesc,
                  tabIndex: 4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildTimelineTrackerBanner(context, tr),
        ],
      ),
    );
  }

  Widget _buildTimelineTrackerBanner(BuildContext context, AppTranslations tr) {
    return AppleFrostedCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(14),
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => const TimelineView(),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: NelfundColors.emerald.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(
                CupertinoIcons.hourglass_bottomhalf_fill,
                color: NelfundColors.emerald,
                size: 21,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tr.timelineHeaderTitle,
                      style: NelfundTypography.headline.copyWith(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: NelfundColors.emerald.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tr.isHausa ? 'Wa\'adi' : 'Section 4.2',
                        style: NelfundTypography.captionBold.copyWith(
                          color: NelfundColors.emerald,
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  tr.isHausa
                      ? 'Duba wa\'adin matakai 5 na neman lamuni da duba korafe-korafe.'
                      : 'Track statutory 5-stage turnaround timelines & grievance directory.',
                  style: NelfundTypography.footnote.copyWith(
                    color: CupertinoDynamicColor.resolve(
                      NelfundColors.secondaryLabel,
                      context,
                    ),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            CupertinoIcons.chevron_right,
            size: 14,
            color: CupertinoDynamicColor.resolve(
              NelfundColors.tertiaryLabel,
              context,
            ),
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
    final localeProv = context.watch<LocaleProvider>();
    final tr = AppTranslations.of(context);
    final actTitle = NelfundData.getActTitle(localeProv.currentLanguage);
    final actSummary = NelfundData.getActSummary(localeProv.currentLanguage);

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
                  actTitle,
                  style: NelfundTypography.headline.copyWith(fontSize: 15.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            actSummary,
            style: NelfundTypography.body.copyWith(
              fontSize: 14,
              color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel, context),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            tr.primaryLegalProvisionsTitle,
            style: NelfundTypography.captionBold.copyWith(
              color: NelfundColors.label,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          _buildBulletItem(tr.provisionRepealedAct),
          _buildBulletItem(tr.provisionNoGuarantor),
          _buildBulletItem(tr.provisionTwoYearGrace),
          _buildBulletItem(tr.provisionUnemploymentForgiveness),
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
}

class _LanguageOnboardingDialog extends StatelessWidget {
  const _LanguageOnboardingDialog();

  @override
  Widget build(BuildContext context) {
    final tr = AppTranslations.of(context);
    LocaleProvider? localeProv;
    try {
      localeProv = Provider.of<LocaleProvider?>(context);
    } catch (_) {}
    final isHausa = localeProv?.isHausa ?? false;
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: CupertinoDynamicColor.resolve(
            const CupertinoDynamicColor.withBrightness(
              color: CupertinoColors.white,
              darkColor: Color(0xFF1C221E),
            ),
            context,
          ),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: NelfundColors.emerald.withValues(alpha: 0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withValues(alpha: isDark ? 0.5 : 0.18),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: CupertinoPopupSurface(
          isSurfacePainted: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top Dismiss Button Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: NelfundColors.emerald.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: NelfundColors.emerald.withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            CupertinoIcons.globe,
                            size: 13,
                            color: NelfundColors.emerald,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            tr.modalLanguageBadge,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: NelfundColors.emerald,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Close 'X' Button
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: CupertinoDynamicColor.resolve(
                            const CupertinoDynamicColor.withBrightness(
                              color: Color(0xFFF0F3F1),
                              darkColor: Color(0xFF2B332E),
                            ),
                            context,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.xmark,
                          size: 14,
                          color: CupertinoDynamicColor.resolve(
                            NelfundColors.secondaryLabel,
                            context,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Icon / Graphic
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        NelfundColors.emerald.withValues(alpha: 0.2),
                        NelfundColors.emeraldLight.withValues(alpha: 0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: NelfundColors.emerald.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      CupertinoIcons.chat_bubble_2_fill,
                      color: NelfundColors.emerald,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Modal Title
                Text(
                  tr.modalLanguageTitle,
                  textAlign: TextAlign.center,
                  style: NelfundTypography.title2.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),

                // Formal & Professional Description
                Text(
                  tr.modalLanguageDesc,
                  textAlign: TextAlign.center,
                  style: NelfundTypography.footnote.copyWith(
                    color: CupertinoDynamicColor.resolve(
                      NelfundColors.secondaryLabel,
                      context,
                    ),
                    height: 1.4,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),

                // Language Option Cards
                _buildOptionCard(
                  context: context,
                  flag: '🇬🇧',
                  title: tr.modalOptionEnglishTitle,
                  desc: tr.modalOptionEnglishDesc,
                  isSelected: !isHausa,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    localeProv?.setLanguage(AppLanguage.english);
                  },
                ),
                const SizedBox(height: 10),
                _buildOptionCard(
                  context: context,
                  flag: '🇳🇬',
                  title: tr.modalOptionHausaTitle,
                  desc: tr.modalOptionHausaDesc,
                  isSelected: isHausa,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    localeProv?.setLanguage(AppLanguage.hausa);
                  },
                ),
                const SizedBox(height: 22),

                // Primary Confirm Button
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    color: NelfundColors.emerald,
                    borderRadius: BorderRadius.circular(16),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      tr.modalConfirmButton,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: CupertinoColors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required String flag,
    required String title,
    required String desc,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF173724) : const Color(0xFFEBF6EF))
              : (isDark ? const Color(0xFF222824) : const Color(0xFFF7FAF8)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? NelfundColors.emerald
                : (isDark ? const Color(0xFF323B35) : const Color(0xFFE2E7E3)),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // Flag
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),

            // Title and Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected
                          ? NelfundColors.emerald
                          : CupertinoDynamicColor.resolve(
                              NelfundColors.label,
                              context,
                            ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: CupertinoDynamicColor.resolve(
                        NelfundColors.secondaryLabel,
                        context,
                      ),
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Radio Circle / Checkmark
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? NelfundColors.emerald : CupertinoColors.transparent,
                border: Border.all(
                  color: isSelected
                      ? NelfundColors.emerald
                      : CupertinoDynamicColor.resolve(
                          CupertinoColors.systemGrey3,
                          context,
                        ),
                  width: 1.8,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      CupertinoIcons.checkmark,
                      size: 13,
                      color: CupertinoColors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

