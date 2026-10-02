import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_translations.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/nelfund_colors.dart';
import '../../core/theme/nelfund_typography.dart';
import '../../models/repayment_model.dart';
import '../../providers/repayment_provider.dart';
import '../../widgets/apple_frosted_card.dart';
import '../../widgets/liquid_glass_header.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static final NumberFormat _formatter = NumberFormat('#,###');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue();
    }
    final number = int.tryParse(digitsOnly);
    if (number == null) {
      return oldValue;
    }
    final newString = _formatter.format(number);
    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}

class CalculatorView extends StatelessWidget {
  const CalculatorView({super.key});

  @override
  Widget build(BuildContext context) {
    LocaleProvider? localeProv;
    try {
      localeProv = Provider.of<LocaleProvider?>(context, listen: false);
    } catch (_) {}

    final content = ChangeNotifierProvider(
      create: (_) => RepaymentProvider(),
      child: const _CalculatorContent(),
    );

    if (localeProv == null) {
      return ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: content,
      );
    }
    return content;
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
    if (income <= 0) return;
    final formatted = NumberFormat('#,###').format(income.toInt());
    if (_incomeController.text.replaceAll(',', '') != income.toInt().toString()) {
      _incomeController.text = formatted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RepaymentProvider>();
    final proj = provider.projection;

    _syncIncomeText(provider.monthlyIncome);

    return CupertinoPageScaffold(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildFintechHeader(context),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 88),
                children: [
                  _buildTipBanner(context),
                  const SizedBox(height: 14),
                  _buildFintechWalletCard(context, provider, proj),
                  const SizedBox(height: 14),
                  _buildSessionLoansBreakdown(context, provider),
                  const SizedBox(height: 16),
                  _buildEmploymentConfigurator(context, provider, proj),
                  const SizedBox(height: 16),
                  _buildPostNyscGracePeriodCard(context, provider, proj),
                  const SizedBox(height: 16),
                  _buildFriendlyComplianceCard(context),
                  const SizedBox(height: 16),
                  _buildStatutoryNotice(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFintechHeader(BuildContext context) {
    final tr = AppTranslations.of(context);

    return LiquidGlassHeader(
      title: tr.calcHeaderTitle,
      subtitle: tr.isHausa ? 'Binciken Basussuka da Jadawalin Biya' : '10% Statutory Deduction Calculator',
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: NelfundColors.emerald.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          CupertinoIcons.creditcard_fill,
          color: NelfundColors.emerald,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildTipBanner(BuildContext context) {
    final tr = AppTranslations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppleFrostedCard(
        margin: EdgeInsets.zero,
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
                tr.calcTipBannerText,
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
                        AppTranslations.of(context).walletBadge,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
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
                  onPressed: () => _showAddOrEditLoanDialog(context, provider),
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
                        AppTranslations.of(context).buttonAddLoanYear,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
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
              AppTranslations.of(context).totalPortfolioLabel,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.9,
                color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel,
                  context,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              proj.formattedLoanAmount,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
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
                        AppTranslations.of(context).statutoryMonthlyDeductionLabel,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.7,
                          color: CupertinoDynamicColor.resolve(
                            NelfundColors.secondaryLabel,
                            context,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${proj.formattedStatutoryDeduction} / mo',
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: NelfundColors.emerald,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        AppTranslations.of(context).statutoryRateLabel,
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
                        AppTranslations.of(context).expectedPayoffTimeLabel,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.7,
                          color: CupertinoDynamicColor.resolve(
                            NelfundColors.secondaryLabel,
                            context,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        proj.getFormattedPayoffTimeline(
                          AppTranslations.of(context).language,
                        ),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
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
                        AppTranslations.of(context).zeroInterestTag,
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
    final tr = AppTranslations.of(context);

    if (provider.sessionLoans.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AppleFrostedCard(
          margin: EdgeInsets.zero,
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
                  tr.noSessionsAdded,
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${tr.configuredSessionsTitle} (${provider.sessionLoans.length})',
                style: NelfundTypography.captionBold.copyWith(
                  color: CupertinoDynamicColor.resolve(
                    NelfundColors.secondaryLabel,
                    context,
                  ),
                  fontSize: 12.5,
                ),
              ),
              Text(
                tr.tapToEdit,
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
                  margin: EdgeInsets.zero,
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
                          session.getLevelLabel(tr.language),
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
                              '${tr.isHausa ? 'Kudin Makaranta' : 'Tuition'}: ${session.formattedTuition}${session.includeUpkeep ? (tr.isHausa ? ' + Alawus: ${session.formattedUpkeep}' : ' + Upkeep: ${session.formattedUpkeep}') : (tr.isHausa ? ' (Babu Alawus)' : ' (No Upkeep)')}',
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
    final tr = AppTranslations.of(context);
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
    final tuitionCtrl = TextEditingController(
      text: NumberFormat('#,###').format(tuition.toInt()),
    );

    showCupertinoModalPopup<void>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (builderCtx, setDialogState) {
            final double currentUpkeep = includeUpkeep ? 240000.0 : 0.0;
            final double currentTotal = tuition + currentUpkeep;
            final totalFormatted = NumberFormat.currency(
              symbol: '₦',
              decimalDigits: 2,
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
                              ? tr.editLoanYearTitle
                              : tr.addLoanYearTitle,
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
                      tr.selectLevelLabel,
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
                      tr.institutionalFeeLabel,
                      style: NelfundTypography.captionBold,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tr.enterFeeDesc,
                      style: NelfundTypography.caption.copyWith(
                        color: CupertinoColors.systemGrey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    CupertinoTextField(
                      controller: tuitionCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        ThousandsSeparatorInputFormatter(),
                      ],
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
                      placeholder: 'e.g. 150,000',
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
                          final cleanVal = val.replaceAll(',', '');
                          tuition = double.tryParse(cleanVal) ?? 0.0;
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
                                Text(
                                  tr.includeUpkeepLabel,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  tr.upkeepAutoCalculated,
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
                            tr.sessionLoanTotalLabel(selectedLevel),
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
                          existingLoan != null ? tr.buttonUpdateLoan : tr.buttonAddToWallet,
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
    final tr = AppTranslations.of(context);
    final isHa = tr.isHausa;
    final startStr = DateFormat('MMMM yyyy').format(proj.repaymentStartDate);

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
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              isHa
                  ? 'Shigar da shekarar da ka kammala NYSC da kudin shigar da kake sa ran samu domin lissafin wa\'adin sassauci da adadin da za a rinka ragewa.'
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
              controller: _incomeController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandsSeparatorInputFormatter(),
              ],
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
              placeholder: 'e.g. 70,000',
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
                final clean = val.replaceAll(',', '');
                final income = double.tryParse(clean) ?? 0.0;
                provider.setMonthlyIncome(income);
              },
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: _buildIncomeChip(
                provider,
                70000,
                tr.minimumWageChip,
              ),
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
        _incomeController.text = NumberFormat('#,###').format(amount.toInt());
      },
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
            color: isSelected ? NelfundColors.emerald : CupertinoColors.systemGrey4,
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
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
    final tr = AppTranslations.of(context);
    final isHa = tr.isHausa;
    final popStr = DateFormat('MMMM yyyy').format(proj.nyscCompletionDate);
    final startStr = DateFormat('MMMM yyyy').format(proj.repaymentStartDate);

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
                      fontWeight: FontWeight.w700,
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
                  _buildTimelineStep(
                    dotColor: CupertinoColors.systemBlue,
                    label: tr.popTimelineLabel,
                    date: popStr,
                    isFirst: true,
                  ),
                  _buildTimelineStep(
                    dotColor: CupertinoColors.systemOrange,
                    label: tr.graceTimelineLabel,
                    date: isHa ? 'Cikakkun Shekaru 2 da Kariya' : '2 Full Years Protected',
                  ),
                  _buildTimelineStep(
                    dotColor: NelfundColors.emerald,
                    label: tr.repaymentTimelineLabel,
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
    final tr = AppTranslations.of(context);
    final isHa = tr.isHausa;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppleFrostedCard(
        margin: EdgeInsets.zero,
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
                    tr.complianceGuideTitle,
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
              tr.complianceGuideDesc,
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
              title: isHa
                  ? 'Kariyar Dalibai & Dakatar da Biya Saboda Lalura'
                  : 'Student Safety Nets & Hardship Deferrals',
              detail: isHa
                  ? 'Duk wanda ya tsinci kansa a rashin aikin yi ko matsin tattalin arziki zai iya neman a dakatar da biyan bashi a hukumance. Babu wani kudin ruwa ko tara da zai karu a lokacin da aka amince da dakatarwar.'
                  : 'Beneficiaries facing genuine unemployment or economic hardship can easily apply for formal repayment suspension. No interest or penalty ever accumulates during approved pauses.',
            ),
            _buildSupportPoint(
              icon: CupertinoIcons.chat_bubble_2_fill,
              iconColor: CupertinoColors.systemBlue,
              title: isHa
                  ? 'Ci gaba da Kasancewa tare da NELFUND'
                  : 'Stay Connected with NELFUND',
              detail: isHa
                  ? 'Kula da martabarka abu ne mai sauki: ka tabbatar da cewa adireshinka na gida, lambar waya, da halin aikinka na zamani ne a shafin dalibai na hukuma.'
                  : 'Maintaining your good standing is simple: keep your residential address, phone number, and employer status current on the official student portal.',
            ),
            _buildSupportPoint(
              icon: CupertinoIcons.bell_fill,
              iconColor: CupertinoColors.systemOrange,
              title: isHa
                  ? 'Wa\'adin Jan Kunne na Kwanaki 30'
                  : '30-Day Pre-Escalation Grace Windows',
              detail: isHa
                  ? 'Kafin daukar kowane mataki na gudanarwa, NELFUND tana tura takardun tunatarwa masu wa\'adin kwanaki 30 domin bayar da damar fayyace matsayi ko tsara biya.'
                  : 'Before any formal administrative escalation, NELFUND issues written reminder notices with 30-day resolution windows to allow beneficiaries to clarify status or set up payment plans.',
            ),
            _buildSupportPoint(
              icon: CupertinoIcons.arrow_2_circlepath_circle_fill,
              iconColor: NelfundColors.emerald,
              title: isHa
                  ? 'Fayyace Umarnin Banki na GSI'
                  : 'Global Standing Instruction (GSI) Clarification',
              detail: isHa
                  ? 'Tsarin GSI umarni ne na babban banki a fadin Najeriya. Dangane da bashin dalibai, ana amfani da shi ne a matsayin mataki na karshe ga wanda ya ki biya da gangan ba tare da sanarwa ba. Sadarwa ta gaskiya tana ba ka kariya kai-tsaye.'
                  : 'GSI is a standard interbank mechanism across Nigerian banking. For student loans, it is only invoked as a last-resort safeguard for extended unnotified non-remittance. Transparent communication protects your account automatically.',
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
    final tr = AppTranslations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        tr.isHausa
            ? 'Sanarwar Doka: Dukkan lissafin an yi shi ne bisa tsarin 0% ba kudin ruwa ko kobo karkashin Dokar Lamunin Dalibai ta 2024. Biyan bashi kafin lokaci ko karawa ba shi da wani caji ko tara.'
            : 'Legal Notice: All simulations are modeled strictly at 0% zero interest under the Students Loans (Access to Higher Education) Act 2024. Voluntary prepayments or accelerated installments incur zero penalty fees.',
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
