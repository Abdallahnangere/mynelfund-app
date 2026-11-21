import 'package:flutter/cupertino.dart';

import '../../../../core/localization/app_translations.dart';
import '../../../../core/theme/nelfund_colors.dart';
import '../../domain/repayment_model.dart';

/// Top portfolio summary card showcasing the total NELFUND wallet balance,
/// monthly statutory or voluntary deduction, and accelerated payoff horizon.
class WalletSummaryCard extends StatelessWidget {
  /// Creates a [WalletSummaryCard].
  const WalletSummaryCard({
    super.key,
    required this.projection,
    required this.tr,
    required this.onAddLoanYear,
  });

  /// Computed repayment projection for the configured loan years.
  final RepaymentProjection projection;

  /// Active translation bundle.
  final AppTranslations tr;

  /// Handler invoked when tapping `'Add Loan Year'`.
  final VoidCallback onAddLoanYear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoDynamicColor.resolve(
            const CupertinoDynamicColor.withBrightness(
              color: Color(0xF2F6FAF7),
              darkColor: Color(0xF214241B),
            ),
            context,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: NelfundColors.emerald.withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: NelfundColors.emerald.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: NelfundColors.emerald.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: NelfundColors.emerald.withValues(alpha: 0.25),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        CupertinoIcons.creditcard_fill,
                        size: 13,
                        color: NelfundColors.emerald,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        tr.walletBadge,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                          color: NelfundColors.emerald,
                        ),
                      ),
                    ],
                  ),
                ),
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  color: NelfundColors.emerald,
                  borderRadius: BorderRadius.circular(18),
                  minimumSize: Size.zero,
                  onPressed: onAddLoanYear,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        CupertinoIcons.plus_circle_fill,
                        size: 14,
                        color: CupertinoColors.white,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        tr.buttonAddLoanYear,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              tr.totalPortfolioLabel,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.9,
                color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel,
                  context,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              projection.formattedLoanAmount,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
                color: CupertinoDynamicColor.resolve(
                  NelfundColors.label,
                  context,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 0.8,
              color: NelfundColors.emerald.withValues(alpha: 0.18),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        projection.isVoluntaryAccelerated
                            ? (tr.isHausa
                                  ? 'BIYAN WATA (DA SON RAI)'
                                  : 'TOTAL MONTHLY PAYMENT')
                            : tr.statutoryMonthlyDeductionLabel,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.7,
                          color: CupertinoDynamicColor.resolve(
                            NelfundColors.secondaryLabel,
                            context,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        projection.isVoluntaryAccelerated
                            ? '${projection.formattedTotalMonthlyPayment} / mo'
                            : '${projection.formattedStatutoryDeduction} / mo',
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          color: NelfundColors.emerald,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        projection.isVoluntaryAccelerated
                            ? '${projection.formattedStatutoryDeduction} stat. + ${projection.formattedExtraPayment} vol.'
                            : tr.statutoryRateLabel,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: CupertinoDynamicColor.resolve(
                            NelfundColors.tertiaryLabel,
                            context,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 0.8,
                  height: 30,
                  color: NelfundColors.emerald.withValues(alpha: 0.18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr.expectedPayoffTimeLabel,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.7,
                          color: CupertinoDynamicColor.resolve(
                            NelfundColors.secondaryLabel,
                            context,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        projection.getFormattedPayoffTimeline(tr.language),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: CupertinoDynamicColor.resolve(
                            NelfundColors.label,
                            context,
                          ),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        projection.isVoluntaryAccelerated &&
                                projection.monthsSaved > 0
                            ? (tr.isHausa
                                  ? '${projection.monthsSaved} mos da wuri! ⚡'
                                  : '${projection.monthsSaved} mos earlier! ⚡')
                            : tr.zeroInterestTag,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: projection.isVoluntaryAccelerated
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: projection.isVoluntaryAccelerated
                              ? NelfundColors.emerald
                              : CupertinoDynamicColor.resolve(
                                  NelfundColors.tertiaryLabel,
                                  context,
                                ),
                        ),
                      ),
                    ],
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
