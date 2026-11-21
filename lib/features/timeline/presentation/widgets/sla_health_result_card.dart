import 'package:flutter/cupertino.dart';

import '../../../../core/localization/app_locale.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/theme/nelfund_colors.dart';
import '../../../../core/theme/nelfund_typography.dart';
import '../../../../shared/widgets/apple_frosted_card.dart';
import '../../domain/timeline_model.dart';

/// Displays real-time statutory SLA health status, elapsed working days vs.
/// guideline limits, and actionable guidance for the active stage.
class SlaHealthResultCard extends StatelessWidget {
  /// Creates an [SlaHealthResultCard].
  const SlaHealthResultCard({
    super.key,
    required this.evaluation,
    required this.language,
    required this.tr,
  });

  /// Computed SLA evaluation output.
  final SlaEvaluationResult evaluation;

  /// Active language.
  final AppLanguage language;

  /// Translation bundle.
  final AppTranslations tr;

  Color _statusColor() {
    switch (evaluation.healthStatus) {
      case SlaHealthStatus.onTrack:
        return NelfundColors.emerald;
      case SlaHealthStatus.approachingDeadline:
        return CupertinoColors.systemOrange;
      case SlaHealthStatus.overdue:
        return CupertinoColors.systemRed;
    }
  }

  IconData _statusIcon() {
    switch (evaluation.healthStatus) {
      case SlaHealthStatus.onTrack:
        return CupertinoIcons.checkmark_seal_fill;
      case SlaHealthStatus.approachingDeadline:
        return CupertinoIcons.exclamationmark_triangle_fill;
      case SlaHealthStatus.overdue:
        return CupertinoIcons.xmark_octagon_fill;
    }
  }

  String _statusLabel() {
    switch (evaluation.healthStatus) {
      case SlaHealthStatus.onTrack:
        return tr.statusOnTrack;
      case SlaHealthStatus.approachingDeadline:
        return tr.statusApproachingDeadline;
      case SlaHealthStatus.overdue:
        return tr.statusOverdue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHa = tr.isHausa;
    final statusColor = _statusColor();
    final secondaryColor = CupertinoDynamicColor.resolve(
      NelfundColors.secondaryLabel,
      context,
    );

    return AppleFrostedCard(
      borderColor: statusColor.withValues(alpha: 0.45),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_statusIcon(), color: statusColor, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  evaluation.statusTitle,
                  style: NelfundTypography.headline.copyWith(fontSize: 15.5),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusLabel(),
                  style: NelfundTypography.captionBold.copyWith(
                    color: statusColor,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            evaluation.diagnosis,
            style: NelfundTypography.footnote.copyWith(
              fontSize: 12.5,
              height: 1.4,
              color: secondaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CupertinoDynamicColor.resolve(
                const CupertinoDynamicColor.withBrightness(
                  color: Color(0xFFF3F7F4),
                  darkColor: Color(0xFF1F2722),
                ),
                context,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHa
                            ? 'Kwanakin Aiki da Suka Wuce'
                            : 'Working Days Elapsed',
                        style: NelfundTypography.captionBold.copyWith(
                          color: CupertinoColors.secondaryLabel,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${evaluation.elapsedWorkingDays} ${isHa ? 'Kwanaki' : 'Days'}',
                        style: NelfundTypography.headline.copyWith(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 30, color: const Color(0x1F000000)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHa ? "Wa'adin Doka" : 'Statutory Limit',
                        style: NelfundTypography.captionBold.copyWith(
                          color: CupertinoColors.secondaryLabel,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        evaluation.stageInfo.getDurationLabel(language),
                        style: NelfundTypography.headline.copyWith(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                CupertinoIcons.arrow_right_circle_fill,
                size: 16,
                color: statusColor,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${isHa ? 'Shawarar Mataki: ' : 'Recommended Action: '}'
                  '${evaluation.actionableAdvice}',
                  style: NelfundTypography.footnote.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
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
