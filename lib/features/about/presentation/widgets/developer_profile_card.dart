import 'package:flutter/cupertino.dart';

import '../../../../core/localization/app_translations.dart';
import '../../../../core/theme/nelfund_colors.dart';
import '../../../../core/theme/nelfund_typography.dart';
import '../../../../shared/widgets/apple_frosted_card.dart';

/// Developer academic profile card identifying the ABU Zaria student creator.
class DeveloperProfileCard extends StatelessWidget {
  /// Creates a [DeveloperProfileCard].
  const DeveloperProfileCard({super.key, required this.tr});

  /// Active translation bundle.
  final AppTranslations tr;

  @override
  Widget build(BuildContext context) {
    final isHa = tr.isHausa;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppleFrostedCard(
        margin: EdgeInsets.zero,
        borderColor: NelfundColors.emerald.withValues(alpha: 0.35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: NelfundColors.emerald.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: NelfundColors.emerald.withValues(alpha: 0.25),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    CupertinoIcons.person_badge_plus_fill,
                    size: 13,
                    color: NelfundColors.emerald,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    tr.developerBadge,
                    style: NelfundTypography.captionBold.copyWith(
                      color: NelfundColors.emerald,
                      fontSize: 11,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              tr.developerIntro,
              style: NelfundTypography.footnote.copyWith(
                color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel,
                  context,
                ),
                fontSize: 13,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [NelfundColors.emerald, Color(0xFF68D391)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: NelfundColors.emerald.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'AU',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr.developerName,
                        style: NelfundTypography.title2.copyWith(
                          fontSize: 17.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: NelfundColors.emerald.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: NelfundColors.emerald.withValues(alpha: 0.3),
                            width: 0.6,
                          ),
                        ),
                        child: Text(
                          tr.developerRole,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: CupertinoDynamicColor.resolve(
                              const CupertinoDynamicColor.withBrightness(
                                color: Color(0xFF007A48),
                                darkColor: Color(0xFF68D391),
                              ),
                              context,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              height: 0.8,
              color: CupertinoDynamicColor.resolve(
                CupertinoColors.systemGrey5,
                context,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  CupertinoIcons.book_fill,
                  size: 16,
                  color: NelfundColors.emerald,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isHa
                        ? 'Ɗalibi mai karatu a aji na 300 a Sashen Nazarin Harkokin Ƙasashen Duniya.'
                        : '300 Level Student of International Studies.',
                    style: NelfundTypography.footnote.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  CupertinoIcons.building_2_fill,
                  size: 16,
                  color: NelfundColors.emerald,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isHa
                        ? "Jami'ar Ahmadu Bello (ABU), Zaria."
                        : 'Ahmadu Bello University (ABU), Zaria.',
                    style: NelfundTypography.footnote.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      color: CupertinoDynamicColor.resolve(
                        NelfundColors.secondaryLabel,
                        context,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
