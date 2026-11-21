import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/app_translations.dart';
import '../../../../core/theme/nelfund_colors.dart';
import '../../../../core/theme/nelfund_typography.dart';
import '../../../../shared/widgets/apple_frosted_card.dart';
import '../../domain/repayment_model.dart';

/// Displays the statutory 2-year post-NYSC moratorium timeline and involuntary
/// unemployment grace protections under the Students Loans Act 2024.
class NyscGracePeriodCard extends StatelessWidget {
  /// Creates a [NyscGracePeriodCard].
  const NyscGracePeriodCard({
    super.key,
    required this.projection,
    required this.tr,
  });

  /// Active repayment projection.
  final RepaymentProjection projection;

  /// Active translation bundle.
  final AppTranslations tr;

  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');

  @override
  Widget build(BuildContext context) {
    final isHa = tr.isHausa;
    final popStr = _monthYearFormat.format(projection.nyscCompletionDate);
    final startStr = _monthYearFormat.format(projection.repaymentStartDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppleFrostedCard(
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  CupertinoIcons.calendar,
                  color: NelfundColors.emerald,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tr.postNyscGraceCardTitle,
                    style: NelfundTypography.headline.copyWith(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              tr.postNyscGraceCardDesc,
              style: NelfundTypography.footnote.copyWith(
                color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel,
                  context,
                ),
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
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
              child: Column(
                children: [
                  _TimelineStepRow(
                    dotColor: CupertinoColors.systemBlue,
                    label: tr.popTimelineLabel,
                    date: popStr,
                  ),
                  _TimelineStepRow(
                    dotColor: CupertinoColors.systemOrange,
                    label: tr.graceTimelineLabel,
                    date: isHa
                        ? 'Cikakkun Shekaru 2 da Kariya'
                        : '2 Full Years Protected',
                  ),
                  _TimelineStepRow(
                    dotColor: NelfundColors.emerald,
                    label: tr.repaymentTimelineLabel,
                    date: startStr,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: CupertinoDynamicColor.resolve(
                  CupertinoColors.systemGrey6,
                  context,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.checkmark_shield_fill,
                        color: NelfundColors.emerald,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tr.unemploymentProtectionTitle,
                        style: NelfundTypography.captionBold.copyWith(
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tr.unemploymentProtectionDesc,
                    style: NelfundTypography.footnote.copyWith(
                      color: CupertinoDynamicColor.resolve(
                        NelfundColors.secondaryLabel,
                        context,
                      ),
                      fontSize: 12,
                      height: 1.35,
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

class _TimelineStepRow extends StatelessWidget {
  const _TimelineStepRow({
    required this.dotColor,
    required this.label,
    required this.date,
  });

  final Color dotColor;
  final String label;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: NelfundTypography.footnote.copyWith(fontSize: 13),
                ),
                Text(
                  date,
                  style: NelfundTypography.captionBold.copyWith(
                    color: dotColor,
                    fontSize: 12,
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
