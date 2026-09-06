import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/nelfund_colors.dart';
import '../../core/theme/nelfund_typography.dart';
import '../../models/repayment_model.dart';
import '../../providers/repayment_provider.dart';
import '../../widgets/apple_frosted_card.dart';

class CalculatorView extends StatelessWidget {
  const CalculatorView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RepaymentProvider(),
      child: const _CalculatorContent(),
    );
  }
}

class _CalculatorContent extends StatelessWidget {
  const _CalculatorContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RepaymentProvider>();
    final proj = provider.projection;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Repayment Calculator'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: provider.reset,
          child: const Text('Reset'),
        ),
        backgroundColor: CupertinoDynamicColor.resolve(
          const CupertinoDynamicColor.withBrightness(
            color: Color(0xCCF8FAF8),
            darkColor: Color(0xCC161718),
          ),
          context,
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            _buildIntroHeader(context),
            const SizedBox(height: 12),
            _buildEmploymentModeSelector(context, provider),
            const SizedBox(height: 16),
            _buildSummaryHeroCard(context, proj),
            const SizedBox(height: 16),
            _buildSectionHeader('Adjust Loan & Income Parameters'),
            _buildLoanAmountSlider(context, provider, proj),
            _buildIncomeSlider(context, provider, proj),
            _buildPrepaymentSlider(context, provider, proj),
            const SizedBox(height: 16),
            _buildSectionHeader('Post-NYSC Moratorium (2-Year Grace)'),
            _buildMoratoriumCard(context, provider, proj),
            const SizedBox(height: 16),
            _buildSectionHeader('Statutory Default Escalation (Section 5.3)'),
            _buildDefaultEscalationCard(context),
            const SizedBox(height: 16),
            _buildStatutoryNotice(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statutory 10% Repayment Model',
            style: NelfundTypography.title2.copyWith(
              color: NelfundColors.emeraldTint,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Simulate your monthly deductions under Section 5.0 of the 2024 Act. 100% interest-free. Repayment begins exactly 2 years after completing NYSC.',
            style: NelfundTypography.body.copyWith(
              color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel, context),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmploymentModeSelector(
      BuildContext context, RepaymentProvider provider) {
    return AppleFrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Employment Category',
            style: NelfundTypography.headline.copyWith(fontSize: 15),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: CupertinoSlidingSegmentedControl<RepaymentMode>(
              groupValue: provider.mode,
              children: {
                RepaymentMode.employedPaye: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text('Employed (PAYE)',
                      style: NelfundTypography.footnote),
                ),
                RepaymentMode.selfEmployedIbr: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text('Self-Employed (Direct)',
                      style: NelfundTypography.footnote),
                ),
              },
              onValueChanged: (val) {
                if (val != null) {
                  provider.setMode(val);
                }
              },
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: CupertinoDynamicColor.resolve(
                const CupertinoDynamicColor.withBrightness(
                  color: Color(0x0C008751),
                  darkColor: Color(0x1F008751),
                ),
                context,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              provider.mode.description,
              style: NelfundTypography.footnote.copyWith(
                color: NelfundColors.emerald,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeroCard(
      BuildContext context, RepaymentProjection proj) {
    final bool hasExtra = proj.extraMonthlyPayment > 0;

    return AppleFrostedCard(
      backgroundColor: CupertinoDynamicColor.resolve(
        const CupertinoDynamicColor.withBrightness(
          color: Color(0xF2F0FBF5),
          darkColor: Color(0xD0132B1D),
        ),
        context,
      ),
      borderColor: NelfundColors.emerald.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STATUTORY MONTHLY DEDUCTION',
                style: NelfundTypography.captionBold.copyWith(
                  color: NelfundColors.emerald,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: NelfundColors.emerald.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '10% OF INCOME',
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
            proj.formattedStatutoryDeduction,
            style: NelfundTypography.largeTitle.copyWith(
              fontWeight: FontWeight.w800,
              color: NelfundColors.emerald,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CupertinoDynamicColor.resolve(
                const CupertinoDynamicColor.withBrightness(
                  color: CupertinoColors.white,
                  darkColor: Color(0xFF1E1E20),
                ),
                context,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estimated Payoff Time',
                        style: NelfundTypography.captionBold.copyWith(
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        proj.formattedBaselineDuration,
                        style: NelfundTypography.headline.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: const Color(0x1F000000),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Interest',
                        style: NelfundTypography.captionBold.copyWith(
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₦0 (0% Free)',
                        style: NelfundTypography.headline.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: CupertinoColors.systemGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (hasExtra) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: CupertinoColors.systemIndigo.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.bolt_fill,
                    size: 16,
                    color: CupertinoColors.systemIndigo,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'With voluntary extra +${proj.formattedExtraPayment}/mo: You finish in ${proj.formattedAcceleratedDuration} (saving ${proj.formattedTimeSaved})!',
                      style: NelfundTypography.footnote.copyWith(
                        color: CupertinoColors.systemIndigo,
                        fontWeight: FontWeight.w600,
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Text(
        title,
        style: NelfundTypography.title3.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLoanAmountSlider(
      BuildContext context, RepaymentProvider provider, RepaymentProjection proj) {
    return AppleFrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Loan Disbursed', style: NelfundTypography.headline.copyWith(fontSize: 15)),
              Text(
                proj.formattedLoanAmount,
                style: NelfundTypography.headline.copyWith(
                  color: NelfundColors.emerald,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CupertinoSlider(
            min: 100000,
            max: 5000000,
            divisions: 98,
            activeColor: NelfundColors.emerald,
            value: provider.loanAmount.clamp(100000, 5000000),
            onChanged: provider.setLoanAmount,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPresetChip('₦600k (Tuition)', () => provider.setLoanAmount(600000)),
              _buildPresetChip('₦1.2M (Avg Total)', () => provider.setLoanAmount(1200000)),
              _buildPresetChip('₦2.5M (5-Yr Degree)', () => provider.setLoanAmount(2500000)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeSlider(
      BuildContext context, RepaymentProvider provider, RepaymentProjection proj) {
    return AppleFrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                provider.mode == RepaymentMode.employedPaye
                    ? 'Monthly Gross Salary'
                    : 'Monthly Business Profit',
                style: NelfundTypography.headline.copyWith(fontSize: 15),
              ),
              Text(
                proj.formattedMonthlyIncome,
                style: NelfundTypography.headline.copyWith(
                  color: NelfundColors.emerald,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CupertinoSlider(
            min: 50000,
            max: 1000000,
            divisions: 95,
            activeColor: NelfundColors.emerald,
            value: provider.monthlyIncome.clamp(50000, 1000000),
            onChanged: provider.setMonthlyIncome,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPresetChip('₦70k (Min Wage)', () => provider.setMonthlyIncome(70000)),
              _buildPresetChip('₦150k (Entry Level)', () => provider.setMonthlyIncome(150000)),
              _buildPresetChip('₦350k (Mid Level)', () => provider.setMonthlyIncome(350000)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrepaymentSlider(
      BuildContext context, RepaymentProvider provider, RepaymentProjection proj) {
    return AppleFrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Voluntary Extra Prepayment', style: NelfundTypography.headline.copyWith(fontSize: 15)),
              Text(
                proj.formattedExtraPayment,
                style: NelfundTypography.headline.copyWith(
                  color: CupertinoColors.systemIndigo,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Accelerate payoff by contributing more than the statutory 10% deduction.',
            style: NelfundTypography.footnote.copyWith(
              color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel, context),
            ),
          ),
          const SizedBox(height: 8),
          CupertinoSlider(
            min: 0,
            max: 100000,
            divisions: 20,
            activeColor: CupertinoColors.systemIndigo,
            value: provider.extraPrepayment.clamp(0, 100000),
            onChanged: provider.setExtraPrepayment,
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(String label, VoidCallback onTap) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0x0F000000),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: NelfundTypography.captionBold.copyWith(fontSize: 11),
        ),
      ),
    );
  }

  Widget _buildMoratoriumCard(
      BuildContext context, RepaymentProvider provider, RepaymentProjection proj) {
    final dateFormat = DateFormat('MMMM yyyy');
    final startStr = dateFormat.format(proj.repaymentStartDate);
    final popStr = dateFormat.format(proj.nyscCompletionDate);

    return AppleFrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.hourglass, color: NelfundColors.emerald, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '2-Year Post-NYSC Grace Period',
                  style: NelfundTypography.headline.copyWith(fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'By law (Section 5.1), no deductions can occur during your studies or within the first 24 months following your NYSC completion (or formal exemption).',
            style: NelfundTypography.footnote.copyWith(
              color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel, context),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('NYSC Completion Year:', style: NelfundTypography.footnote),
              Row(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    onPressed: () {
                      provider.setNyscGraduationYear(provider.nyscGraduationYear - 1);
                    },
                    child: const Icon(CupertinoIcons.minus_circle, size: 22),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '${provider.nyscGraduationYear}',
                      style: NelfundTypography.headline.copyWith(fontSize: 16),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    onPressed: () {
                      provider.setNyscGraduationYear(provider.nyscGraduationYear + 1);
                    },
                    child: const Icon(CupertinoIcons.plus_circle, size: 22),
                  ),
                ],
              ),
            ],
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
                _buildTimelineStep(
                  dotColor: CupertinoColors.systemBlue,
                  label: 'NYSC Passing Out Parade (POP)',
                  date: popStr,
                  isFirst: true,
                ),
                _buildTimelineStep(
                  dotColor: CupertinoColors.systemOrange,
                  label: '24-Month Statutory Grace Period (0 Deductions)',
                  date: '2 Full Years Protected',
                ),
                _buildTimelineStep(
                  dotColor: NelfundColors.emerald,
                  label: 'Mandatory Repayment Begins',
                  date: startStr,
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0x0A000000),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Unemployment Clause (Sec. 5.1c): If unemployed after 2 years, submit a periodic sworn affidavit of unemployment to pause recovery.',
              style: NelfundTypography.caption.copyWith(
                color: CupertinoDynamicColor.resolve(
                    NelfundColors.secondaryLabel, context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required Color dotColor,
    required String label,
    required String date,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: NelfundTypography.footnote.copyWith(fontSize: 13)),
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

  Widget _buildDefaultEscalationCard(BuildContext context) {
    return AppleFrostedCard(
      borderColor: CupertinoColors.systemRed.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.shield_slash_fill,
                color: CupertinoColors.systemRed,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Default Escalation Timeline (Section 5.3)',
                  style: NelfundTypography.headline.copyWith(
                    color: CupertinoColors.systemRed,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'The 2024 Act defines strict progressive recovery mechanisms for willful default after the 2-year post-NYSC grace period:',
            style: NelfundTypography.footnote.copyWith(
              color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel, context),
            ),
          ),
          const SizedBox(height: 12),
          _buildEscalationStage(
            stageNumber: '1',
            title: 'Formal Demand & Warning Notices',
            detail: 'Initial written demand notices served to the beneficiary and employer.',
            color: CupertinoColors.systemOrange,
          ),
          _buildEscalationStage(
            stageNumber: '2',
            title: 'CRMS & Credit Bureau Blacklisting',
            detail: 'Reported to Central Bank Credit Risk Management System & Credit Bureaus. Blocks commercial bank loans, mortgages, and credit cards.',
            color: CupertinoColors.systemOrange,
          ),
          _buildEscalationStage(
            stageNumber: '3',
            title: 'Publication in National Defaulters List',
            detail: 'Identity, photo, institution, and debt published in national daily newspapers and public registries.',
            color: CupertinoColors.systemRed,
          ),
          _buildEscalationStage(
            stageNumber: '4',
            title: 'Global Standing Instruction (GSI) Auto-Debit',
            detail: 'Direct debit swept automatically from all commercial bank accounts linked to your BVN and NIN nationwide.',
            color: CupertinoColors.systemRed,
          ),
          _buildEscalationStage(
            stageNumber: '5',
            title: 'Legal Action & Court Prosecution',
            detail: 'Legal proceedings initiated in Federal High Court to recover outstanding principal plus statutory recovery costs.',
            color: const Color(0xFF8B0000),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildEscalationStage({
    required String stageNumber,
    required String title,
    required String detail,
    required Color color,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                stageNumber,
                style: NelfundTypography.captionBold.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
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
                  title,
                  style: NelfundTypography.headline.copyWith(
                    fontSize: 14,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: NelfundTypography.footnote.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatutoryNotice(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        'Legal Note: All figures are calculated strictly at 0% interest as mandated by the Students Loans Act 2024. Early voluntary repayments are permitted without penalties or prepayment fees.',
        style: NelfundTypography.caption.copyWith(
          color: CupertinoDynamicColor.resolve(
              NelfundColors.tertiaryLabel, context),
        ),
      ),
    );
  }
}
