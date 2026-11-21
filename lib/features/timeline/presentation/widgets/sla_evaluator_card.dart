import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/app_locale.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/theme/nelfund_colors.dart';
import '../../../../core/theme/nelfund_typography.dart';
import '../../../../shared/widgets/apple_frosted_card.dart';
import '../../domain/timeline_model.dart';

/// Interactive evaluator card allowing students to choose their current
/// application stage and submission date for real-time SLA assessment.
class SlaEvaluatorCard extends StatelessWidget {
  /// Creates an [SlaEvaluatorCard].
  const SlaEvaluatorCard({
    super.key,
    required this.currentStage,
    required this.submissionDate,
    required this.language,
    required this.tr,
    required this.onStageSelected,
    required this.onSubmissionDateChanged,
  });

  /// Currently selected SLA stage.
  final SlaStage currentStage;

  /// Selected application submission date.
  final DateTime submissionDate;

  /// Active display language.
  final AppLanguage language;

  /// Active translation bundle.
  final AppTranslations tr;

  /// Invoked when the user selects a different stage.
  final ValueChanged<SlaStage> onStageSelected;

  /// Invoked when the user updates the submission date.
  final ValueChanged<DateTime> onSubmissionDateChanged;

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  void _showDatePickerModal(BuildContext context) {
    final now = DateTime.now();
    var tempDate = submissionDate.isAfter(now) ? now : submissionDate;

    showCupertinoModalPopup<void>(
      context: context,
      builder: (modalCtx) => Container(
        height: 290,
        color: CupertinoDynamicColor.resolve(
          NelfundColors.secondaryBackground,
          modalCtx,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.of(modalCtx).pop(),
                    child: Text(tr.isHausa ? 'Soke' : 'Cancel'),
                  ),
                  CupertinoButton(
                    onPressed: () {
                      onSubmissionDateChanged(tempDate);
                      Navigator.of(modalCtx).pop();
                    },
                    child: Text(
                      tr.buttonDone,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: tempDate,
                  minimumDate: DateTime(2024, 1, 1),
                  maximumDate: now,
                  onDateTimeChanged: (date) => tempDate = date,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final secondaryColor = CupertinoDynamicColor.resolve(
      NelfundColors.secondaryLabel,
      context,
    );

    return AppleFrostedCard(
      borderColor: NelfundColors.emerald.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.slider_horizontal_3,
                color: NelfundColors.emerald,
                size: 19,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tr.onTrackEvaluatorTitle,
                  style: NelfundTypography.headline.copyWith(fontSize: 15.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tr.currentStageLabel,
            style: NelfundTypography.captionBold.copyWith(
              color: secondaryColor,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SlaStageInfo.allStages.map((info) {
              final selected = info.stage == currentStage;
              return Semantics(
                button: true,
                selected: selected,
                label: info.getTitle(language),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onStageSelected(info.stage);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? NelfundColors.emerald
                          : (isDark
                                ? const Color(0xFF232B26)
                                : const Color(0xFFF1F5F2)),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? NelfundColors.emerald
                            : NelfundColors.emerald.withValues(alpha: 0.22),
                        width: 0.75,
                      ),
                    ),
                    child: Text(
                      '${info.stageNumber}. ${info.getTitle(language)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: selected
                            ? CupertinoColors.white
                            : CupertinoDynamicColor.resolve(
                                NelfundColors.label,
                                context,
                              ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Text(
            tr.submissionDateLabel,
            style: NelfundTypography.captionBold.copyWith(
              color: secondaryColor,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Semantics(
            button: true,
            label: tr.submissionDateLabel,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _showDatePickerModal(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF202823)
                      : const Color(0xFFF4F8F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: NelfundColors.emerald.withValues(alpha: 0.3),
                    width: 0.85,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.calendar,
                      size: 18,
                      color: NelfundColors.emerald,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _dateFormat.format(submissionDate),
                      style: NelfundTypography.headline.copyWith(fontSize: 14),
                    ),
                    const Spacer(),
                    Text(
                      tr.isHausa ? 'Sauya' : 'Change',
                      style: NelfundTypography.captionBold.copyWith(
                        color: NelfundColors.emerald,
                        fontSize: 12,
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
}
