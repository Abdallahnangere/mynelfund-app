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

class _CalculatorContent extends StatefulWidget {
  const _CalculatorContent();

  @override
  State<_CalculatorContent> createState() => _CalculatorContentState();
}

class _CalculatorContentState extends State<_CalculatorContent> {
  late TextEditingController _incomeController;

  @override
  void initState() {
    super.initState();
    _incomeController = TextEditingController();
  }

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }

  void _syncIncomeText(double income) {
    final formatted = income.toInt().toString();
    if (_incomeController.text != formatted) {
      _incomeController.text = formatted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RepaymentProvider>();
    final proj = provider.projection;

    _syncIncomeText(provider.monthlyIncome);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Payment Calculator',
          style: NelfundTypography.headline.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            letterSpacing: -0.4,
          ),
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
            _buildTipBanner(context),
            const SizedBox(height: 16),
            _buildFintechWalletCard(context, provider, proj),
            const SizedBox(height: 14),
            _buildSessionLoansBreakdown(context, provider),
            const SizedBox(height: 20),
            _buildEmploymentConfigurator(context, provider, proj),
            const SizedBox(height: 18),
            _buildPostNyscGracePeriodCard(context, provider, proj),
            const SizedBox(height: 18),
            _buildFriendlyComplianceCard(context),
            const SizedBox(height: 16),
            _buildStatutoryNotice(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTipBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AppleFrostedCard(
        borderColor: NelfundColors.emerald.withValues(alpha: 0.35),
        backgroundColor: CupertinoDynamicColor.resolve(
          const CupertinoDynamicColor.withBrightness(
            color: Color(0xF2F0FBF5),
            darkColor: Color(0xD0132B1D),
          ),
          context,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(
                CupertinoIcons.lightbulb_fill,
                color: NelfundColors.emerald,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Tap below to add your loans and select your expected income after graduation to simulate your monthly deduction and repayment timeline.',
                style: NelfundTypography.footnote.copyWith(
                  fontSize: 13,
                  height: 1.35,
                  color: CupertinoDynamicColor.resolve(
                    NelfundColors.label,
                    context,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFintechWalletCard(
    BuildContext context,
    RepaymentProvider provider,
    RepaymentProjection proj,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0C2B1C),
              Color(0xFF06180E),
            ],
          ),
          border: Border.all(
            color: const Color(0x4D48BB78),
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x38004D25),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x3348BB78),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0x5548BB78),
                          width: 0.8,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            CupertinoIcons.creditcard_fill,
                            size: 13,
                            color: Color(0xFF68D391),
                          ),
                          SizedBox(width: 5),
                          Text(
                            'NELFUND WALLET',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: Color(0xFF68D391),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  color: NelfundColors.emerald,
                  borderRadius: BorderRadius.circular(20),
                  minimumSize: Size.zero,
                  onPressed: () => _showAddOrEditLoanDialog(context, provider),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.plus_circle_fill,
                        size: 15,
                        color: CupertinoColors.white,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Add Loan Year',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'TOTAL LOAN PORTFOLIO',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
                color: Color(0xA0CBD5E0),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              proj.formattedLoanAmount,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
                color: CupertinoColors.white,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              height: 0.8,
              color: const Color(0x28FFFFFF),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'STATUTORY MONTHLY DEDUCTION',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: Color(0xA0CBD5E0),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${proj.formattedStatutoryDeduction} / mo',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF68D391),
                        ),
                      ),
                      const SizedBox(height: 1),
                      const Text(
                        '10% Statutory Rate',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0x80CBD5E0),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 0.8,
                  height: 40,
                  color: const Color(0x28FFFFFF),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'EXPECTED PAYOFF TIME',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: Color(0xA0CBD5E0),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        proj.formattedPayoffTimeline,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: CupertinoColors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      const Text(
                        '0% Zero Interest',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0x80CBD5E0),
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

  Widget _buildSessionLoansBreakdown(
    BuildContext context,
    RepaymentProvider provider,
  ) {
    if (provider.sessionLoans.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: AppleFrostedCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(
                CupertinoIcons.info,
                color: CupertinoColors.systemOrange,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'No academic session loans added. Tap "Add Loan Year" on the wallet card above to onboard your loans.',
                  style: NelfundTypography.footnote.copyWith(
                    color: CupertinoDynamicColor.resolve(
                      NelfundColors.secondaryLabel,
                      context,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Configured Academic Sessions (${provider.sessionLoans.length})',
                style: NelfundTypography.captionBold.copyWith(
                  color: CupertinoDynamicColor.resolve(
                    NelfundColors.secondaryLabel,
                    context,
                  ),
                  fontSize: 12.5,
                ),
              ),
              Text(
                'Tap to edit',
                style: NelfundTypography.caption.copyWith(
                  color: CupertinoDynamicColor.resolve(
                    NelfundColors.tertiaryLabel,
                    context,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...provider.sessionLoans.map(
            (session) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _showAddOrEditLoanDialog(
                  context,
                  provider,
                  existingLoan: session,
                ),
                child: AppleFrostedCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: NelfundColors.emerald.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          session.levelLabel,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: NelfundColors.emerald,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.formattedTotal,
                              style: NelfundTypography.headline.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tuition: ${session.formattedTuition}${session.includeUpkeep ? ' + Upkeep: ${session.formattedUpkeep}' : ' (No Upkeep)'}',
                              style: NelfundTypography.caption.copyWith(
                                color: CupertinoDynamicColor.resolve(
                                  NelfundColors.secondaryLabel,
                                  context,
                                ),
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        onPressed: () => provider.removeSessionLoan(session.level),
                        child: const Icon(
                          CupertinoIcons.xmark_circle_fill,
                          color: CupertinoColors.systemGrey3,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddOrEditLoanDialog(
    BuildContext context,
    RepaymentProvider provider, {
    AcademicSessionLoan? existingLoan,
  }) {
    int selectedLevel = existingLoan?.level ?? 100;
    if (existingLoan == null) {
      final existingLevels = provider.sessionLoans.map((s) => s.level).toSet();
      for (final lvl in [100, 200, 300, 400, 500, 600]) {
        if (!existingLevels.contains(lvl)) {
          selectedLevel = lvl;
          break;
        }
      }
    }

    double tuition = existingLoan?.tuitionFee ?? 120000.0;
    bool includeUpkeep = existingLoan?.includeUpkeep ?? true;
    final tuitionCtrl = TextEditingController(text: tuition.toInt().toString());

    showCupertinoModalPopup<void>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (builderCtx, setDialogState) {
            final double currentUpkeep = includeUpkeep ? 240000.0 : 0.0;
            final double currentTotal = tuition + currentUpkeep;
            final totalFormatted = NumberFormat.currency(
              symbol: '₦',
              decimalDigits: 0,
            ).format(currentTotal);

            return Container(
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(builderCtx).viewInsets.bottom,
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: CupertinoDynamicColor.resolve(
                  CupertinoColors.systemBackground,
                  builderCtx,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey4,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          existingLoan != null
                              ? 'Edit Academic Year Loan'
                              : 'Add Academic Year Loan',
                          style: NelfundTypography.headline.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          onPressed: () => Navigator.of(builderCtx).pop(),
                          child: const Icon(
                            CupertinoIcons.xmark_circle_fill,
                            color: CupertinoColors.systemGrey3,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Select Academic Level:',
                      style: NelfundTypography.captionBold,
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoSlidingSegmentedControl<int>(
                        groupValue: selectedLevel,
                        children: const {
                          100: Text('100L'),
                          200: Text('200L'),
                          300: Text('300L'),
                          400: Text('400L'),
                          500: Text('500L'),
                          600: Text('600L'),
                        },
                        onValueChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedLevel = val;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Institutional / Tuition Fee (₦):',
                      style: NelfundTypography.captionBold,
                    ),
                    const SizedBox(height: 6),
                    CupertinoTextField(
                      controller: tuitionCtrl,
                      keyboardType: TextInputType.number,
                      prefix: const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          '₦ ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: NelfundColors.emerald,
                          ),
                        ),
                      ),
                      placeholder: 'e.g. 150000',
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoDynamicColor.resolve(
                          CupertinoColors.systemGrey6,
                          builderCtx,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: CupertinoColors.systemGrey4,
                          width: 0.6,
                        ),
                      ),
                      onChanged: (val) {
                        setDialogState(() {
                          tuition = double.tryParse(val) ?? 0.0;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoDynamicColor.resolve(
                          CupertinoColors.systemGrey6,
                          builderCtx,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Include Upkeep Allowance',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Auto-calculated: ₦20,000 × 12 = ₦240,000 / yr',
                                  style: NelfundTypography.caption.copyWith(
                                    color: NelfundColors.emerald,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CupertinoSwitch(
                            value: includeUpkeep,
                            activeTrackColor: NelfundColors.emerald,
                            onChanged: (val) {
                              setDialogState(() {
                                includeUpkeep = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: NelfundColors.emerald.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Session Loan Total ($selectedLevel Level):',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            totalFormatted,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: NelfundColors.emerald,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        color: NelfundColors.emerald,
                        borderRadius: BorderRadius.circular(12),
                        onPressed: () {
                          provider.addOrUpdateSessionLoan(
                            AcademicSessionLoan(
                              level: selectedLevel,
                              tuitionFee: tuition,
                              includeUpkeep: includeUpkeep,
                              upkeepAmount: 240000.0,
                            ),
                          );
                          Navigator.of(builderCtx).pop();
                        },
                        child: Text(
                          existingLoan != null ? 'Update Loan' : 'Add to Wallet',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmploymentConfigurator(
    BuildContext context,
    RepaymentProvider provider,
    RepaymentProjection proj,
  ) {
    final startStr = DateFormat('MMMM yyyy').format(proj.repaymentStartDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AppleFrostedCard(
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
                    'Employment & Income Configurator',
                    style: NelfundTypography.headline.copyWith(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Input your NYSC graduation year and projected monthly income to configure your statutory grace period and deduction.',
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
                  'NYSC Graduation Year:',
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
                          fontWeight: FontWeight.w700,
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
                      '2-Year Grace Active: Repayment starts $startStr',
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
              'Repayment Stream:',
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
                      'Employed (PAYE)',
                      style: NelfundTypography.footnote,
                    ),
                  ),
                  RepaymentMode.selfEmployedIbr: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      'Self-Employed (Direct)',
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
              provider.mode.description,
              style: NelfundTypography.caption.copyWith(
                color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel,
                  context,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Expected Monthly Income (₦):',
              style: NelfundTypography.headline.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 6),
            CupertinoTextField(
              controller: _incomeController,
              keyboardType: TextInputType.number,
              prefix: const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  '₦ ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: NelfundColors.emerald,
                  ),
                ),
              ),
              placeholder: 'e.g. 150000',
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 12,
              ),
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
                final income = double.tryParse(val) ?? 0.0;
                provider.setMonthlyIncome(income);
              },
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildIncomeChip(provider, 70000, '₦70k (Min Wage)'),
                _buildIncomeChip(provider, 150000, '₦150k'),
                _buildIncomeChip(provider, 250000, '₦250k'),
                _buildIncomeChip(provider, 500000, '₦500k'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeChip(
    RepaymentProvider provider,
    double amount,
    String label,
  ) {
    final isSelected = provider.monthlyIncome == amount;
    return GestureDetector(
      onTap: () {
        provider.setMonthlyIncome(amount);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? NelfundColors.emerald
              : CupertinoDynamicColor.resolve(
                  CupertinoColors.systemGrey6,
                  context,
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? NelfundColors.emerald : CupertinoColors.systemGrey4,
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? CupertinoColors.white : null,
          ),
        ),
      ),
    );
  }

  Widget _buildPostNyscGracePeriodCard(
    BuildContext context,
    RepaymentProvider provider,
    RepaymentProjection proj,
  ) {
    final popStr = DateFormat('MMMM yyyy').format(proj.nyscCompletionDate);
    final startStr = DateFormat('MMMM yyyy').format(proj.repaymentStartDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AppleFrostedCard(
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
                    '2-Year Post-NYSC Grace Period',
                    style: NelfundTypography.headline.copyWith(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Under Section 5.0 of the Students Loans Act 2024, beneficiaries enjoy an automatic 24-month interest-free moratorium after completing national service:',
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
                        'Unemployment Protection (Sec. 5.1c)',
                        style: NelfundTypography.captionBold.copyWith(
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'If you are not yet gainfully employed at the end of your 2-year grace period, you are legally protected. Submitting a periodic statutory declaration or sworn affidavit pauses deductions until you secure employment.',
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

  Widget _buildFriendlyComplianceCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AppleFrostedCard(
        borderColor: NelfundColors.emerald.withValues(alpha: 0.3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  CupertinoIcons.shield_lefthalf_fill,
                  color: NelfundColors.emerald,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Repayment Support & Compliance Guidelines',
                    style: NelfundTypography.headline.copyWith(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'The Students Loans Act 2024 is built with student safeguards first. Here is how statutory compliance and protections work:',
              style: NelfundTypography.footnote.copyWith(
                color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel,
                  context,
                ),
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 14),
            _buildSupportPoint(
              icon: CupertinoIcons.person_crop_circle_badge_checkmark,
              iconColor: NelfundColors.emerald,
              title: 'Student Safety Nets & Hardship Deferrals',
              detail:
                  'Beneficiaries facing genuine unemployment or economic hardship can easily apply for formal repayment suspension. No interest or penalty ever accumulates during approved pauses.',
            ),
            _buildSupportPoint(
              icon: CupertinoIcons.chat_bubble_2_fill,
              iconColor: CupertinoColors.systemBlue,
              title: 'Stay Connected with NELFUND',
              detail:
                  'Maintaining your good standing is simple: keep your residential address, phone number, and employer status current on the official student portal.',
            ),
            _buildSupportPoint(
              icon: CupertinoIcons.bell_fill,
              iconColor: CupertinoColors.systemOrange,
              title: '30-Day Pre-Escalation Grace Windows',
              detail:
                  'Before any formal administrative escalation, NELFUND issues written reminder notices with 30-day resolution windows to allow beneficiaries to clarify status or set up payment plans.',
            ),
            _buildSupportPoint(
              icon: CupertinoIcons.arrow_2_circlepath_circle_fill,
              iconColor: NelfundColors.emerald,
              title: 'Global Standing Instruction (GSI) Clarification',
              detail:
                  'GSI is a standard interbank mechanism across Nigerian banking. For student loans, it is only invoked as a last-resort safeguard for extended unnotified non-remittance. Transparent communication protects your account automatically.',
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportPoint({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String detail,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: NelfundTypography.headline.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: NelfundTypography.footnote.copyWith(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                    height: 1.35,
                  ),
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
        'Legal Notice: All simulations are modeled strictly at 0% zero interest under the Students Loans (Access to Higher Education) Act 2024. Voluntary prepayments or accelerated installments incur zero penalty fees.',
        style: NelfundTypography.caption.copyWith(
          color: CupertinoDynamicColor.resolve(
            NelfundColors.tertiaryLabel,
            context,
          ),
        ),
      ),
    );
  }
}
