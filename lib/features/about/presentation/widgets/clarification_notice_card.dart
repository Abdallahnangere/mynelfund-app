import 'package:flutter/cupertino.dart';

import '../../../../core/localization/app_translations.dart';
import '../../../../core/theme/nelfund_typography.dart';
import '../../../../shared/widgets/apple_frosted_card.dart';

/// Statutory disclaimer card clarifying non-affiliation and zero-collection
/// privacy posture.
class ClarificationNoticeCard extends StatelessWidget {
  /// Creates a [ClarificationNoticeCard].
  const ClarificationNoticeCard({super.key, required this.tr});

  /// Active translation bundle.
  final AppTranslations tr;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppleFrostedCard(
        margin: EdgeInsets.zero,
        borderColor: CupertinoColors.systemOrange.withValues(alpha: 0.35),
        backgroundColor: CupertinoDynamicColor.resolve(
          const CupertinoDynamicColor.withBrightness(
            color: Color(0xFFFFFBF0),
            darkColor: Color(0xFF282010),
          ),
          context,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  CupertinoIcons.shield_slash_fill,
                  color: CupertinoColors.systemOrange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tr.clarificationTitle,
                    style: NelfundTypography.headline.copyWith(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.systemOrange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              tr.clarificationBody,
              style: NelfundTypography.footnote.copyWith(
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: CupertinoColors.systemOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    CupertinoIcons.lock_shield_fill,
                    size: 16,
                    color: CupertinoColors.systemOrange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tr.zeroDataCollectionDesc,
                      style: NelfundTypography.captionBold.copyWith(
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
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
