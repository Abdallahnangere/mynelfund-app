import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../../app/app.dart';
import '../../../../core/constants/nelfund_data.dart';
import '../../../../core/localization/app_locale.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/theme/nelfund_colors.dart';
import '../../../../core/theme/nelfund_typography.dart';
import '../../../../shared/widgets/apple_frosted_card.dart';

/// Displays the three foundational NELFUND loan pillars defined in
/// [NelfundData.getCorePillars].
class CorePillarsSection extends StatelessWidget {
  /// Creates a [CorePillarsSection].
  const CorePillarsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLang = AppProviders.maybeRead<LocaleProvider>(context) != null
        ? context.select<LocaleProvider, AppLanguage>((p) => p.currentLanguage)
        : AppLanguage.english;
    final pillars = NelfundData.getCorePillars(currentLang);

    return Column(
      children: [
        _PillarTile(
          icon: CupertinoIcons.percent,
          title: pillars[0]['title']!,
          subtitle: pillars[0]['subtitle']!,
          tag: pillars[0]['highlight']!,
          tagColor: CupertinoColors.systemGreen,
        ),
        _PillarTile(
          icon: CupertinoIcons.building_2_fill,
          title: pillars[1]['title']!,
          subtitle: pillars[1]['subtitle']!,
          tag: pillars[1]['highlight']!,
          tagColor: NelfundColors.emerald,
        ),
        _PillarTile(
          icon: CupertinoIcons.money_dollar_circle_fill,
          title: pillars[2]['title']!,
          subtitle: pillars[2]['subtitle']!,
          tag: pillars[2]['highlight']!,
          tagColor: CupertinoColors.systemOrange,
        ),
      ],
    );
  }
}

class _PillarTile extends StatelessWidget {
  const _PillarTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.tagColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String tag;
  final Color tagColor;

  @override
  Widget build(BuildContext context) {
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
            child: Center(child: Icon(icon, color: tagColor, size: 22)),
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
                        style: NelfundTypography.headline.copyWith(
                          fontSize: 15,
                        ),
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
}
