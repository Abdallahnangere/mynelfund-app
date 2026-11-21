import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/formatters/currency_formatter.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/theme/nelfund_colors.dart';
import '../../../../core/theme/nelfund_typography.dart';
import '../../../../shared/widgets/apple_frosted_card.dart';
import '../../domain/repayment_model.dart';
import '../providers/repayment_provider.dart';

/// Configures post-NYSC graduation year, repayment stream (PAYE vs. IBR),
/// projected monthly income, and optional voluntary accelerated repayments.
class EmploymentConfiguratorCard extends StatelessWidget {
  /// Creates an [EmploymentConfiguratorCard].
  const EmploymentConfiguratorCard({
    super.key,
    required this.provider,
    required this.projection,
    required this.tr,
    required this.incomeController,
    required this.voluntaryController,
  });

  /// Repayment state owner.
  final RepaymentProvider provider;

  /// Latest computed projection.
  final RepaymentProjection projection;

  /// Active translation bundle.
  final AppTranslations tr;

  /// Controller for the monthly income input field.
  final TextEditingController incomeController;

  /// Controller for voluntary custom remittance input field.
  final TextEditingController voluntaryController;

  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');

  @override
  Widget build(BuildContext context) {
    final isHa = tr.isHausa;
    final startStr = _monthYearFormat.format(projection.repaymentStartDate);
    final statutory = projection.statutoryMonthlyDeduction;

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
                  CupertinoIcons.briefcase_fill,
                  color: NelfundColors.emerald,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isHa
                        ? 'Tsara Aiki da Kudin Shiga'
                        : 'Employment & Income Configurator',
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
              isHa
                  ? "Shigar da shekarar da ka kammala NYSC da kudin shigar da kake sa ran samu domin lissafin wa'adin sassauci da adadin da za a rinka ragewa."
                  : 'Input your NYSC graduation year and projected monthly income to configure your statutory grace period and deduction.',
              style: NelfundTypography.footnote.copyWith(
                color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel,
                  context,
                ),
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tr.nyscGraduationYearLabel,
                  style: NelfundTypography.headline.copyWith(fontSize: 14),
                ),
                Row(
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      onPressed: () {
                        provider.setNyscGraduationYear(
                          provider.nyscGraduationYear - 1,
                        );
                      },
                      child: const Icon(
                        CupertinoIcons.minus_circle_fill,
                        size: 24,
                        color: NelfundColors.emerald,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${provider.nyscGraduationYear}',
                        style: NelfundTypography.headline.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      onPressed: () {
                        provider.setNyscGraduationYear(
                          provider.nyscGraduationYear + 1,
                        );
                      },
                      child: const Icon(
                        CupertinoIcons.plus_circle_fill,
                        size: 24,
                        color: NelfundColors.emerald,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: NelfundColors.emerald.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: NelfundColors.emerald.withValues(alpha: 0.25),
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.clock_fill,
                    size: 16,
                    color: NelfundColors.emerald,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${tr.twoYearGraceActivePrefix}$startStr',
                      style: NelfundTypography.captionBold.copyWith(
                        color: NelfundColors.emerald,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              tr.repaymentStreamTitle,
              style: NelfundTypography.headline.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl<RepaymentMode>(
                groupValue: provider.mode,
                children: {
                  RepaymentMode.employedPaye: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      RepaymentMode.employedPaye.getTitle(tr.language),
                      style: NelfundTypography.footnote,
                    ),
                  ),
                  RepaymentMode.selfEmployedIbr: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      RepaymentMode.selfEmployedIbr.getTitle(tr.language),
                      style: NelfundTypography.footnote,
                    ),
                  ),
                },
                onValueChanged: (val) {
                  if (val != null) {
                    provider.setMode(val);
                  }
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.mode.getDescription(tr.language),
              style: NelfundTypography.caption.copyWith(
                color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel,
                  context,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              tr.expectedMonthlyIncomeLabel,
              style: NelfundTypography.headline.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 3),
            Text(
              tr.expectedSalaryDesc,
              style: NelfundTypography.caption.copyWith(
                color: CupertinoColors.systemGrey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            CupertinoTextField(
              controller: incomeController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                const ThousandsSeparatorInputFormatter(),
              ],
              prefix: const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  '₦ ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: NelfundColors.emerald,
                  ),
                ),
              ),
              placeholder: 'e.g. 70,000',
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                color: CupertinoDynamicColor.resolve(
                  CupertinoColors.systemGrey6,
                  context,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: CupertinoColors.systemGrey4,
                  width: 0.6,
                ),
              ),
              onChanged: (val) {
                provider.setMonthlyIncome(CurrencyFormatter.parseAmount(val));
              },
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: _IncomePresetChip(
                label: tr.minimumWageChip,
                isSelected: provider.monthlyIncome == 70000,
                onTap: () {
                  provider.setMonthlyIncome(70000);
                  incomeController.text = CurrencyFormatter.formatGrouped(
                    70000,
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            _VoluntaryRepaymentBox(
              provider: provider,
              projection: projection,
              tr: tr,
              statutory: statutory,
              voluntaryController: voluntaryController,
            ),
          ],
        ),
      ),
    );
  }
}

class _IncomePresetChip extends StatelessWidget {
  const _IncomePresetChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? NelfundColors.emerald
              : CupertinoDynamicColor.resolve(
                  CupertinoColors.systemGrey6,
                  context,
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? NelfundColors.emerald
                : CupertinoColors.systemGrey4,
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? CupertinoColors.white : null,
          ),
        ),
      ),
    );
  }
}

class _VoluntaryRepaymentBox extends StatelessWidget {
  const _VoluntaryRepaymentBox({
    required this.provider,
    required this.projection,
    required this.tr,
    required this.statutory,
    required this.voluntaryController,
  });

  final RepaymentProvider provider;
  final RepaymentProjection projection;
  final AppTranslations tr;
  final double statutory;
  final TextEditingController voluntaryController;

  @override
  Widget build(BuildContext context) {
    final isHa = tr.isHausa;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          const CupertinoDynamicColor.withBrightness(
            color: Color(0x0C008751),
            darkColor: Color(0x1F008751),
          ),
          context,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: NelfundColors.emerald.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.bolt_fill,
                color: NelfundColors.emerald,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  tr.voluntaryRepaymentTitle,
                  style: NelfundTypography.headline.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            tr.voluntaryRepaymentDesc,
            style: NelfundTypography.caption.copyWith(
              color: CupertinoDynamicColor.resolve(
                NelfundColors.secondaryLabel,
                context,
              ),
              fontSize: 11.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: CupertinoDynamicColor.resolve(
                CupertinoColors.systemBackground,
                context,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: CupertinoColors.systemGrey4,
                width: 0.6,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tr.statutoryBaselineLabel,
                  style: NelfundTypography.caption.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 11.5,
                  ),
                ),
                Text(
                  '${projection.formattedStatutoryDeduction} / mo',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: NelfundColors.emerald,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _VoluntaryPresetChip(
                  label: isHa ? 'Doka (10%)' : 'Statutory (10%)',
                  isSelected: provider.extraPrepayment == 0.0,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    provider.setExtraPrepayment(0.0);
                    voluntaryController.clear();
                  },
                ),
                const SizedBox(width: 6),
                _VoluntaryPresetChip(
                  label: '15%',
                  isSelected:
                      provider.extraPrepayment > 0 &&
                      (provider.monthlyIncome * 0.15 -
                                  projection.totalMonthlyPayment)
                              .abs() <
                          1.0,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    provider.setVoluntaryRatePercent(15.0);
                    voluntaryController.text = CurrencyFormatter.formatGrouped(
                      provider.monthlyIncome * 0.15,
                    );
                  },
                ),
                const SizedBox(width: 6),
                _VoluntaryPresetChip(
                  label: '20%',
                  isSelected:
                      provider.extraPrepayment > 0 &&
                      (provider.monthlyIncome * 0.20 -
                                  projection.totalMonthlyPayment)
                              .abs() <
                          1.0,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    provider.setVoluntaryRatePercent(20.0);
                    voluntaryController.text = CurrencyFormatter.formatGrouped(
                      provider.monthlyIncome * 0.20,
                    );
                  },
                ),
                const SizedBox(width: 6),
                _VoluntaryPresetChip(
                  label: '+₦10,000 ${isHa ? 'Kari' : 'Extra'}',
                  isSelected: (provider.extraPrepayment - 10000.0).abs() < 1.0,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    provider.setExtraPrepayment(10000.0);
                    voluntaryController.text = CurrencyFormatter.formatGrouped(
                      statutory + 10000.0,
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            tr.voluntaryCustomAmountLabel,
            style: NelfundTypography.captionBold.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 5),
          CupertinoTextField(
            controller: voluntaryController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              const ThousandsSeparatorInputFormatter(),
            ],
            prefix: const Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                '₦ ',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: NelfundColors.emerald,
                ),
              ),
            ),
            placeholder: tr.voluntaryCustomPlaceholder,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: CupertinoDynamicColor.resolve(
                CupertinoColors.systemBackground,
                context,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: projection.isVoluntaryAccelerated
                    ? NelfundColors.emerald
                    : CupertinoColors.systemGrey4,
                width: projection.isVoluntaryAccelerated ? 1.0 : 0.6,
              ),
            ),
            onChanged: (val) {
              provider.setVoluntaryTotalMonthlyPayment(
                CurrencyFormatter.parseAmount(val),
              );
            },
          ),
          if (projection.isVoluntaryAccelerated &&
              projection.monthsSaved > 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: NelfundColors.emerald.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: NelfundColors.emerald.withValues(alpha: 0.4),
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.rocket_fill,
                    size: 16,
                    color: NelfundColors.emerald,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tr.debtFreeEarlierBadge(projection.formattedTimeSaved),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: NelfundColors.emerald,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VoluntaryPresetChip extends StatelessWidget {
  const _VoluntaryPresetChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5.5),
        decoration: BoxDecoration(
          color: isSelected
              ? NelfundColors.emerald
              : CupertinoDynamicColor.resolve(
                  CupertinoColors.systemBackground,
                  context,
                ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? NelfundColors.emerald
                : CupertinoColors.systemGrey4,
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? CupertinoColors.white
                : CupertinoDynamicColor.resolve(NelfundColors.label, context),
          ),
        ),
      ),
    );
  }
}
