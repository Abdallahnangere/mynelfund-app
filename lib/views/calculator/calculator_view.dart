import 'dart:ui';
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
  late TextEditingController _voluntaryController;

  @override
  void initState() {
    super.initState();
    _incomeController = TextEditingController();
    _voluntaryController = TextEditingController();
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _voluntaryController.dispose();
    super.dispose();
  }

  void _syncIncomeText(double income) {
    if (income <= 0) return;
    final formatted = NumberFormat('#,###').format(income.toInt());
    if (_incomeController.text.replaceAll(',', '') != income.toInt().toString()) {
      _incomeController.text = formatted;
    }
  }

  void _syncVoluntaryText(double totalPayment, double statutory) {
    if (totalPayment <= statutory || totalPayment <= 0) {
      if (_voluntaryController.text.isNotEmpty && _voluntaryController.text != '0') {
        _voluntaryController.text = '';
      }
      return;
    }
    final formatted = NumberFormat('#,###').format(totalPayment.toInt());
    if (_voluntaryController.text.replaceAll(',', '') != totalPayment.toInt().toString()) {
      _voluntaryController.text = formatted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RepaymentProvider>();
    final proj = provider.projection;

    _syncIncomeText(provider.monthlyIncome);
    _syncVoluntaryText(proj.totalMonthlyPayment, proj.statutoryMonthlyDeduction);

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
      trailing: _AnimatedHelpButton(
        isHausa: tr.isHausa,
        onTap: () => _showCalculatorGuideModal(context, tr),
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
                        proj.isVoluntaryAccelerated
                            ? (AppTranslations.of(context).isHausa ? 'BIYAN WATA (DA SON RAI)' : 'TOTAL MONTHLY PAYMENT')
                            : AppTranslations.of(context).statutoryMonthlyDeductionLabel,
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
                        proj.isVoluntaryAccelerated
                            ? '${proj.formattedTotalMonthlyPayment} / mo'
                            : '${proj.formattedStatutoryDeduction} / mo',
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: NelfundColors.emerald,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        proj.isVoluntaryAccelerated
                            ? '${proj.formattedStatutoryDeduction} stat. + ${proj.formattedExtraPayment} vol.'
                            : AppTranslations.of(context).statutoryRateLabel,
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
                        proj.isVoluntaryAccelerated && proj.monthsSaved > 0
                            ? (AppTranslations.of(context).isHausa
                                ? '${proj.monthsSaved} mos da wuri! ⚡'
                                : '${proj.monthsSaved} mos earlier! ⚡')
                            : AppTranslations.of(context).zeroInterestTag,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: proj.isVoluntaryAccelerated ? FontWeight.w700 : FontWeight.normal,
                          color: proj.isVoluntaryAccelerated
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
                              '${tr.isHausa ? 'Kudin Makaranta' : 'Tuition'}: ${session.formattedTuition}${session.includeUpkeep && session.upkeepAmount > 0 ? (tr.isHausa ? ' + Alawus (${session.upkeepMonthsCount} watanni): ${session.formattedUpkeep}' : ' + Upkeep (${session.upkeepMonthsCount} mos): ${session.formattedUpkeep}') : (tr.isHausa ? ' (Babu Alawus)' : ' (No Upkeep)')}',
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
    bool includeUpkeep = existingLoan?.includeUpkeep ?? false;
    final Set<int> upkeepMonths = existingLoan != null
        ? (existingLoan.upkeepMonths.isNotEmpty
            ? existingLoan.upkeepMonths.toSet()
            : (existingLoan.upkeepAmount > 0
                ? List.generate(
                    (existingLoan.upkeepAmount / 20000.0).round().clamp(0, 12),
                    (i) => i + 1,
                  ).toSet()
                : <int>{}))
        : <int>{};
    final tuitionCtrl = TextEditingController(
      text: NumberFormat('#,###').format(tuition.toInt()),
    );

    showCupertinoModalPopup<void>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (builderCtx, setDialogState) {
            final double currentUpkeep =
                includeUpkeep ? (upkeepMonths.length * 20000.0) : 0.0;
            final double currentTotal = tuition + currentUpkeep;
            final totalFormatted = NumberFormat.currency(
              symbol: '₦',
              decimalDigits: 2,
            ).format(currentTotal);

            return Container(
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(builderCtx).viewInsets.bottom,
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(builderCtx).height * 0.88,
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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
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
                    if (includeUpkeep) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: CupertinoDynamicColor.resolve(
                            const CupertinoDynamicColor.withBrightness(
                              color: Color(0x0C008751),
                              darkColor: Color(0x1F008751),
                            ),
                            builderCtx,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: NelfundColors.emerald.withValues(alpha: 0.28),
                            width: 0.8,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      CupertinoIcons.calendar,
                                      size: 15,
                                      color: NelfundColors.emerald,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      tr.selectUpkeepMonthsTitle,
                                      style: NelfundTypography.captionBold.copyWith(
                                        color: NelfundColors.emerald,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${upkeepMonths.length}/12',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: NelfundColors.emerald,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tr.selectUpkeepMonthsDesc,
                              style: NelfundTypography.caption.copyWith(
                                color: CupertinoDynamicColor.resolve(
                                  NelfundColors.secondaryLabel,
                                  builderCtx,
                                ),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Quick Action Presets Row
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: [
                                  _buildQuickMonthButton(
                                    builderCtx,
                                    label: tr.quickSelectAll12,
                                    isSelected: upkeepMonths.length == 12,
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setDialogState(() {
                                        upkeepMonths.addAll(
                                          List.generate(12, (i) => i + 1),
                                        );
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  _buildQuickMonthButton(
                                    builderCtx,
                                    label: tr.quickSelectSem1,
                                    isSelected: upkeepMonths.containsAll([1, 2, 3, 4, 5, 6]) &&
                                        upkeepMonths.length == 6,
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setDialogState(() {
                                        upkeepMonths.clear();
                                        upkeepMonths.addAll([1, 2, 3, 4, 5, 6]);
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  _buildQuickMonthButton(
                                    builderCtx,
                                    label: tr.quickSelectSem2,
                                    isSelected: upkeepMonths.containsAll([7, 8, 9, 10, 11, 12]) &&
                                        upkeepMonths.length == 6,
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setDialogState(() {
                                        upkeepMonths.clear();
                                        upkeepMonths.addAll([7, 8, 9, 10, 11, 12]);
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  _buildQuickMonthButton(
                                    builderCtx,
                                    label: tr.quickClear,
                                    isSelected: upkeepMonths.isEmpty,
                                    isClear: true,
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setDialogState(() {
                                        upkeepMonths.clear();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),

                            // 12-Month Calendar Grid (4 columns x 3 rows)
                            _build12MonthCalendarGrid(
                              context: builderCtx,
                              isHausa: tr.isHausa,
                              selectedMonths: upkeepMonths,
                              onToggleMonth: (m) {
                                HapticFeedback.selectionClick();
                                setDialogState(() {
                                  if (upkeepMonths.contains(m)) {
                                    upkeepMonths.remove(m);
                                  } else {
                                    upkeepMonths.add(m);
                                  }
                                });
                              },
                            ),
                            const SizedBox(height: 10),

                            // Live calculation summary pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: upkeepMonths.isNotEmpty
                                    ? NelfundColors.emerald.withValues(alpha: 0.12)
                                    : CupertinoColors.systemOrange.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    upkeepMonths.isNotEmpty
                                        ? CupertinoIcons.checkmark_seal_fill
                                        : CupertinoIcons.exclamationmark_circle_fill,
                                    size: 14,
                                    color: upkeepMonths.isNotEmpty
                                        ? NelfundColors.emerald
                                        : CupertinoColors.systemOrange,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      upkeepMonths.isNotEmpty
                                          ? tr.upkeepSelectedSummary(
                                              upkeepMonths.length,
                                              NumberFormat.currency(
                                                symbol: '₦',
                                                decimalDigits: 2,
                                              ).format(currentUpkeep),
                                            )
                                          : tr.noMonthsSelected,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: upkeepMonths.isNotEmpty
                                            ? NelfundColors.emerald
                                            : CupertinoColors.systemOrange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                              includeUpkeep: includeUpkeep && upkeepMonths.isNotEmpty,
                              upkeepMonths: includeUpkeep
                                  ? (upkeepMonths.toList()..sort())
                                  : const [],
                              upkeepAmount: currentUpkeep,
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
            const SizedBox(height: 18),
            _buildVoluntaryRepaymentSection(context, provider, proj),
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

  Widget _buildVoluntaryRepaymentSection(
    BuildContext context,
    RepaymentProvider provider,
    RepaymentProjection proj,
  ) {
    final tr = AppTranslations.of(context);
    final isHa = tr.isHausa;
    final statutory = proj.statutoryMonthlyDeduction;

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
                    fontWeight: FontWeight.w700,
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

          // Statutory Floor Reminder
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
                    fontWeight: FontWeight.w600,
                    fontSize: 11.5,
                  ),
                ),
                Text(
                  '${proj.formattedStatutoryDeduction} / mo',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: NelfundColors.emerald,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Voluntary Options / Preset Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildVoluntaryPresetChip(
                  context: context,
                  label: isHa ? 'Doka (10%)' : 'Statutory (10%)',
                  isSelected: provider.extraPrepayment == 0.0,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    provider.setExtraPrepayment(0.0);
                    _voluntaryController.clear();
                  },
                ),
                const SizedBox(width: 6),
                _buildVoluntaryPresetChip(
                  context: context,
                  label: '15%',
                  isSelected: provider.extraPrepayment > 0 &&
                      (provider.monthlyIncome * 0.15 - proj.totalMonthlyPayment).abs() < 1.0,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    provider.setVoluntaryRatePercent(15.0);
                    _voluntaryController.text = NumberFormat('#,###').format(
                      (provider.monthlyIncome * 0.15).toInt(),
                    );
                  },
                ),
                const SizedBox(width: 6),
                _buildVoluntaryPresetChip(
                  context: context,
                  label: '20%',
                  isSelected: provider.extraPrepayment > 0 &&
                      (provider.monthlyIncome * 0.20 - proj.totalMonthlyPayment).abs() < 1.0,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    provider.setVoluntaryRatePercent(20.0);
                    _voluntaryController.text = NumberFormat('#,###').format(
                      (provider.monthlyIncome * 0.20).toInt(),
                    );
                  },
                ),
                const SizedBox(width: 6),
                _buildVoluntaryPresetChip(
                  context: context,
                  label: '+₦10,000 ${isHa ? 'Kari' : 'Extra'}',
                  isSelected: (provider.extraPrepayment - 10000.0).abs() < 1.0,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    provider.setExtraPrepayment(10000.0);
                    _voluntaryController.text = NumberFormat('#,###').format(
                      (statutory + 10000.0).toInt(),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Custom Monthly Remittance Input Field
          Text(
            tr.voluntaryCustomAmountLabel,
            style: NelfundTypography.captionBold.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 5),
          CupertinoTextField(
            controller: _voluntaryController,
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
            placeholder: tr.voluntaryCustomPlaceholder,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: CupertinoDynamicColor.resolve(
                CupertinoColors.systemBackground,
                context,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: proj.isVoluntaryAccelerated
                    ? NelfundColors.emerald
                    : CupertinoColors.systemGrey4,
                width: proj.isVoluntaryAccelerated ? 1.0 : 0.6,
              ),
            ),
            onChanged: (val) {
              final clean = val.replaceAll(',', '');
              final voluntaryAmount = double.tryParse(clean) ?? 0.0;
              provider.setVoluntaryTotalMonthlyPayment(voluntaryAmount);
            },
          ),

          // Accelerated Payoff Early Debt-Free Banner
          if (proj.isVoluntaryAccelerated && proj.monthsSaved > 0) ...[
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
                      tr.debtFreeEarlierBadge(proj.formattedTimeSaved),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
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

  Widget _buildVoluntaryPresetChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
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
            color: isSelected ? NelfundColors.emerald : CupertinoColors.systemGrey4,
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? CupertinoColors.white
                : CupertinoDynamicColor.resolve(
                    NelfundColors.label,
                    context,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _build12MonthCalendarGrid({
    required BuildContext context,
    required bool isHausa,
    required Set<int> selectedMonths,
    required ValueChanged<int> onToggleMonth,
  }) {
    const monthLabelsEn = [
      'JAN', 'FEB', 'MAR', 'APR',
      'MAY', 'JUN', 'JUL', 'AUG',
      'SEP', 'OCT', 'NOV', 'DEC'
    ];
    const monthLabelsHa = [
      'Jan', 'Fab', 'Mar', 'Afi',
      'May', 'Yun', 'Yul', 'Agu',
      'Sat', 'Okt', 'Nuw', 'Dis'
    ];
    final labels = isHausa ? monthLabelsHa : monthLabelsEn;

    return Column(
      children: [
        for (int row = 0; row < 3; row++) ...[
          if (row > 0) const SizedBox(height: 6),
          Row(
            children: [
              for (int col = 0; col < 4; col++) ...[
                if (col > 0) const SizedBox(width: 6),
                Expanded(
                  child: _buildMonthCalendarTile(
                    context: context,
                    monthNumber: row * 4 + col + 1,
                    monthLabel: labels[row * 4 + col],
                    isSelected: selectedMonths.contains(row * 4 + col + 1),
                    onTap: () => onToggleMonth(row * 4 + col + 1),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildMonthCalendarTile({
    required BuildContext context,
    required int monthNumber,
    required String monthLabel,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 38,
        decoration: BoxDecoration(
          color: isSelected
              ? NelfundColors.emerald
              : CupertinoDynamicColor.resolve(
                  CupertinoColors.systemBackground,
                  context,
                ),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: isSelected
                ? NelfundColors.emerald
                : CupertinoColors.systemGrey4,
            width: isSelected ? 1.4 : 0.6,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: NelfundColors.emerald.withValues(alpha: 0.28),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                const Icon(
                  CupertinoIcons.checkmark_alt,
                  size: 11,
                  color: CupertinoColors.white,
                ),
                const SizedBox(width: 2),
              ],
              Text(
                monthLabel,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? CupertinoColors.white
                      : CupertinoDynamicColor.resolve(
                          NelfundColors.label,
                          context,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickMonthButton(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool isClear = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected && !isClear
              ? NelfundColors.emerald.withValues(alpha: 0.16)
              : CupertinoDynamicColor.resolve(
                  CupertinoColors.systemBackground,
                  context,
                ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected && !isClear
                ? NelfundColors.emerald
                : CupertinoColors.systemGrey4,
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected && !isClear ? FontWeight.w700 : FontWeight.w500,
            color: isSelected && !isClear
                ? NelfundColors.emerald
                : (isClear ? CupertinoColors.systemRed : null),
          ),
        ),
      ),
    );
  }

  void _showCalculatorGuideModal(BuildContext context, AppTranslations tr) {
    final isHa = tr.isHausa;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: isHa ? 'Jagoran Na\'urar Lissafi' : 'Calculator Guide',
      barrierColor: CupertinoColors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curvedValue = Curves.easeOutBack.transform(anim1.value);
        return Transform.scale(
          scale: 0.90 + (0.10 * curvedValue),
          child: Opacity(
            opacity: anim1.value.clamp(0.0, 1.0),
            child: Stack(
              children: [
                // 1. Full-window BackdropFilter blur
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(
                      color: CupertinoColors.black.withValues(alpha: 0.20),
                    ),
                  ),
                ),

                // 2. Centered Frosted Liquid Glass Modal Dialog
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 420,
                        maxHeight: MediaQuery.sizeOf(ctx).height * 0.82,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: CupertinoDynamicColor.resolve(
                            const CupertinoDynamicColor.withBrightness(
                              color: Color(0xF2FFFFFF),
                              darkColor: Color(0xF018241C),
                            ),
                            context,
                          ),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: NelfundColors.emerald.withValues(alpha: 0.40),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: NelfundColors.emerald.withValues(alpha: 0.14),
                              blurRadius: 28,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Modal Header Bar with Close Icon
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 18, 16, 12),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: NelfundColors.emerald.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.creditcard_fill,
                                      color: NelfundColors.emerald,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tr.calcGuideTitle,
                                          style: NelfundTypography.headline.copyWith(
                                            fontSize: 16.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          isHa ? 'Tsarin Lamuni & Biyan Bashi' : 'Loan & Repayment Architecture',
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
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Icon(
                                      CupertinoIcons.xmark_circle_fill,
                                      color: CupertinoColors.systemGrey3,
                                      size: 26,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              height: 0.8,
                              color: NelfundColors.emerald.withValues(alpha: 0.18),
                            ),

                            // Scrollable Step Guide Content
                            Flexible(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tr.calcGuideIntro,
                                      style: NelfundTypography.body.copyWith(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w500,
                                        color: CupertinoDynamicColor.resolve(
                                          NelfundColors.label,
                                          context,
                                        ),
                                        height: 1.35,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    _buildGuideStepItem(
                                      context: context,
                                      stepNumber: '1',
                                      title: tr.calcGuideStep1Title,
                                      description: tr.calcGuideStep1Desc,
                                      stepColor: NelfundColors.emerald,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildGuideStepItem(
                                      context: context,
                                      stepNumber: '2',
                                      title: tr.calcGuideStep2Title,
                                      description: tr.calcGuideStep2Desc,
                                      stepColor: CupertinoColors.systemBlue,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildGuideStepItem(
                                      context: context,
                                      stepNumber: '3',
                                      title: tr.calcGuideStep3Title,
                                      description: tr.calcGuideStep3Desc,
                                      stepColor: NelfundColors.emerald,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Modal Footer Action
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                              child: CupertinoButton(
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                color: NelfundColors.emerald,
                                borderRadius: BorderRadius.circular(14),
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: Text(
                                  tr.calcGuideDismiss,
                                  style: const TextStyle(
                                    color: CupertinoColors.white,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
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
          ),
        );
      },
    );
  }

  Widget _buildGuideStepItem({
    required BuildContext context,
    required String stepNumber,
    required String title,
    required String description,
    required Color stepColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          CupertinoColors.systemBackground,
          context,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: stepColor.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: stepColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              stepNumber,
              style: TextStyle(
                color: stepColor,
                fontWeight: FontWeight.w800,
                fontSize: 13,
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
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
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
    );
  }
}

class _AnimatedHelpButton extends StatefulWidget {
  final bool isHausa;
  final VoidCallback onTap;

  const _AnimatedHelpButton({
    required this.isHausa,
    required this.onTap,
  });

  @override
  State<_AnimatedHelpButton> createState() => _AnimatedHelpButtonState();
}

class _AnimatedHelpButtonState extends State<_AnimatedHelpButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.08, end: 0.95)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.05)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
    ]).animate(_pulseController);

    _pulseController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          _pulseController.forward(from: 0.0);
          widget.onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: NelfundColors.emerald.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: NelfundColors.emerald.withValues(alpha: 0.38),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: NelfundColors.emerald.withValues(alpha: 0.15),
                blurRadius: 8,
                spreadRadius: 0.5,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.question_circle_fill,
                color: NelfundColors.emerald,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                widget.isHausa ? 'Jagora' : 'Help Guide',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: NelfundColors.emerald,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
