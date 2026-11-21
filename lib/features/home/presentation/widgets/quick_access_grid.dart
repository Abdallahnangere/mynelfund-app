import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../../app/app_shell.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/theme/nelfund_colors.dart';
import '../../../../core/theme/nelfund_typography.dart';
import '../../../../shared/widgets/apple_frosted_card.dart';
import '../../../timeline/presentation/views/timeline_view.dart';

/// Quick-access 2x2 action grid and 5-stage SLA Timeline shortcut banner on
/// [HomeView].
class QuickAccessGrid extends StatelessWidget {
  /// Creates a [QuickAccessGrid].
  const QuickAccessGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = AppTranslations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: CupertinoIcons.checkmark_shield_fill,
                  iconColor: NelfundColors.emerald,
                  title: tr.cardEligibilityTitle,
                  description: tr.cardEligibilityDesc,
                  tabIndex: 1,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionCard(
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
                child: _QuickActionCard(
                  icon: CupertinoIcons.question_circle_fill,
                  iconColor: CupertinoColors.systemTeal,
                  title: tr.cardFaqTitle,
                  description: tr.cardFaqDesc,
                  tabIndex: 3,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionCard(
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
          _TimelineTrackerBanner(tr: tr),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.tabIndex,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final int tabIndex;

  @override
  Widget build(BuildContext context) {
    return AppleFrostedCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(14),
      semanticLabel: title,
      onTap: () => MainTabScaffold.switchTab(context, tabIndex),
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
                child: Center(child: Icon(icon, color: iconColor, size: 20)),
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
}

class _TimelineTrackerBanner extends StatelessWidget {
  const _TimelineTrackerBanner({required this.tr});

  final AppTranslations tr;

  @override
  Widget build(BuildContext context) {
    return AppleFrostedCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(14),
      semanticLabel: tr.timelineHeaderTitle,
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(
          context,
        ).push(CupertinoPageRoute<void>(builder: (_) => const TimelineView()));
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
                        tr.isHausa ? "Wa'adi" : 'Section 4.2',
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
                      ? "Duba wa'adin matakai 5 na neman lamuni da duba korafe-korafe."
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
}
