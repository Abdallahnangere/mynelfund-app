import 'package:flutter/cupertino.dart';

import '../../../../core/localization/app_locale.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/theme/nelfund_colors.dart';
import '../../../../core/theme/nelfund_typography.dart';
import '../../../../shared/widgets/apple_frosted_card.dart';
import '../../domain/timeline_model.dart';

/// Displays one of the 5 statutory application & disbursement turnaround
/// stages defined under NELFUND guidelines.
class SlaStageCard extends StatelessWidget {
  /// Creates an [SlaStageCard].
  const SlaStageCard({
    super.key,
    required this.info,
    required this.language,
    required this.tr,
    this.isActive = false,
  });

  /// Stage metadata to display.
  final SlaStageInfo info;

  /// Active UI language.
  final AppLanguage language;

  /// Translation bundle.
  final AppTranslations tr;

  /// Highlights the border when this stage matches the user's active selection.
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AppleFrostedCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      borderColor: isActive
          ? NelfundColors.emerald.withValues(alpha: 0.48)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: NelfundColors.emerald.withValues(
                    alpha: isActive ? 0.24 : 0.15,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${info.stageNumber}',
                    style: NelfundTypography.captionBold.copyWith(
                      color: NelfundColors.emerald,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.getTitle(language),
                      style: NelfundTypography.headline.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      info.getActor(language),
                      style: NelfundTypography.captionBold.copyWith(
                        color: CupertinoColors.secondaryLabel,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: NelfundColors.emerald.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  info.getDurationLabel(language),
                  style: NelfundTypography.captionBold.copyWith(
                    color: NelfundColors.emerald,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            info.getDescription(language),
            style: NelfundTypography.footnote.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                CupertinoIcons.flag_fill,
                size: 12,
                color: NelfundColors.emerald,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${tr.isHausa ? 'Tabbataccen Sakamako' : 'Milestone'}: '
                  '${info.getMilestone(language)}',
                  style: NelfundTypography.captionBold.copyWith(
                    color: NelfundColors.emerald,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
