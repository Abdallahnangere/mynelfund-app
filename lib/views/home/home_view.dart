import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/nelfund_data.dart';
import '../../core/localization/app_locale.dart';
import '../../core/localization/app_translations.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/nelfund_colors.dart';
import '../../core/theme/nelfund_typography.dart';
import '../../providers/notification_provider.dart';
import '../../providers/promo_provider.dart';
import '../../widgets/apple_frosted_card.dart';
import '../../widgets/liquid_glass_header.dart';
import '../../widgets/sauki_promo_widgets.dart';
import '../main_tab_scaffold.dart';
import '../notifications/notifications_view.dart';
import '../timeline/timeline_view.dart';

class HomeView extends StatelessWidget {
  final bool showStartupPromo;
  const HomeView({super.key, this.showStartupPromo = false});

  @override
  Widget build(BuildContext context) {
    LocaleProvider? localeProv;
    PromoProvider? promoProv;
    try {
      localeProv = Provider.of<LocaleProvider?>(context, listen: false);
    } catch (_) {}
    try {
      promoProv = Provider.of<PromoProvider?>(context, listen: false);
    } catch (_) {}

    final content = _HomeViewContent(
      showStartupPromo: showStartupPromo,
    );

    if (localeProv == null || promoProv == null) {
      return MultiProvider(
        providers: [
          if (localeProv == null)
            ChangeNotifierProvider(create: (_) => LocaleProvider()),
          if (promoProv == null)
            ChangeNotifierProvider(create: (_) => PromoProvider()),
        ],
        child: content,
      );
    }
    return content;
  }
}

class _HomeViewContent extends StatefulWidget {
  final bool showStartupPromo;
  const _HomeViewContent({this.showStartupPromo = false});

  @override
  State<_HomeViewContent> createState() => _HomeViewContentState();
}

class _HomeViewContentState extends State<_HomeViewContent> {
  @override
  void initState() {
    super.initState();
    if (widget.showStartupPromo) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkStartupPromoModal();
      });
    }
  }

  Future<void> _checkStartupPromoModal() async {
    try {
      PromoProvider? promoProv;
      try {
        promoProv = Provider.of<PromoProvider?>(context, listen: false);
      } catch (_) {}
      final shouldShow = await (promoProv?.shouldAutoShowModal() ??
          Future<bool>.value(false));
      if (shouldShow && mounted) {
        await SaukiPromoModal.show(context, trigger: 'startup');
      }
    } catch (e) {
      debugPrint('[HomeView] Startup promo modal check note: $e');
    }
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
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 88),
                children: [
                  _buildSectionHeader(tr.programOverviewTitle),
                  _buildActOverviewCard(context),
                  const SizedBox(height: 8),
                  const SaukiPromoHomeCard(),
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const GetDataHeaderButton(),
          const SizedBox(width: 8),
          _buildNotificationButton(context),
        ],
      ),
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
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🇬🇧', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        'English',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              !isHausa ? FontWeight.w600 : FontWeight.w400,
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
                padding: const EdgeInsets.symmetric(horizontal: 6),
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
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🇳🇬', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        'Harshen Hausa',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isHausa ? FontWeight.w600 : FontWeight.w400,
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
      minimumSize: Size.zero,
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
                    color: isDark
                        ? const Color(0xFF161718)
                        : CupertinoColors.white,
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
          fontSize: 17.5,
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
                        style: NelfundTypography.headline.copyWith(fontSize: 15),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
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
                      NelfundColors.secondaryLabel,
                      context,
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
                    Expanded(
                      child: Text(
                        tr.timelineHeaderTitle,
                        style: NelfundTypography.headline.copyWith(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
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
            style: NelfundTypography.headline.copyWith(fontSize: 14.5),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: NelfundTypography.footnote.copyWith(
              color: CupertinoDynamicColor.resolve(
                NelfundColors.secondaryLabel,
                context,
              ),
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
                  style: NelfundTypography.headline.copyWith(fontSize: 15),
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
                NelfundColors.secondaryLabel,
                context,
              ),
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
