import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../../app/app.dart';
import '../../../../core/formatters/currency_formatter.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/theme/nelfund_colors.dart';
import '../../../../shared/widgets/animated_help_button.dart';
import '../../../../shared/widgets/liquid_glass_header.dart';
import '../providers/repayment_provider.dart';
import '../widgets/add_session_sheet.dart';
import '../widgets/calculator_info_cards.dart';
import '../widgets/employment_configurator_card.dart';
import '../widgets/nysc_grace_period_card.dart';
import '../widgets/session_loans_card.dart';
import '../widgets/wallet_summary_card.dart';

export '../../../../core/formatters/currency_formatter.dart'
    show ThousandsSeparatorInputFormatter;

/// Statutory 10% income-driven repayment simulator supporting multi-year loan
/// portfolios, optional monthly upkeep selection, NYSC moratorium timelines,
/// and voluntary prepayment modeling.
class CalculatorView extends StatelessWidget {
  /// Creates a [CalculatorView].
  const CalculatorView({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProv = AppProviders.maybeRead<LocaleProvider>(context);
    final repayProv = AppProviders.maybeRead<RepaymentProvider>(context);

    if (localeProv == null || repayProv == null) {
      return MultiProvider(
        providers: [
          if (localeProv == null)
            ChangeNotifierProvider<LocaleProvider>(
              create: (_) => LocaleProvider(),
            ),
          if (repayProv == null)
            ChangeNotifierProvider<RepaymentProvider>(
              create: (_) => RepaymentProvider(),
            ),
        ],
        child: const _CalculatorContent(),
      );
    }

    return const _CalculatorContent();
  }
}

class _CalculatorContent extends StatefulWidget {
  const _CalculatorContent();

  @override
  State<_CalculatorContent> createState() => _CalculatorContentState();
}

class _CalculatorContentState extends State<_CalculatorContent> {
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _voluntaryController = TextEditingController();

  @override
  void dispose() {
    _incomeController.dispose();
    _voluntaryController.dispose();
    super.dispose();
  }

  void _syncIncomeText(double income) {
    if (income <= 0) {
      if (_incomeController.text.isNotEmpty) {
        _incomeController.clear();
      }
      return;
    }
    final formatted = CurrencyFormatter.formatGrouped(income);
    if (_incomeController.text.replaceAll(',', '') !=
        income.toInt().toString()) {
      _incomeController.text = formatted;
    }
  }

  void _syncVoluntaryText(double totalPayment, double statutory) {
    if (totalPayment <= statutory + 0.01) {
      if (_voluntaryController.text.isNotEmpty &&
          totalPayment <= statutory + 0.01) {
        _voluntaryController.clear();
      }
      return;
    }
    final formatted = CurrencyFormatter.formatGrouped(totalPayment);
    if (_voluntaryController.text.replaceAll(',', '') !=
        totalPayment.toInt().toString()) {
      _voluntaryController.text = formatted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppTranslations.of(context);
    final provider = context.watch<RepaymentProvider>();
    final proj = provider.projection;

    _syncIncomeText(provider.monthlyIncome);
    _syncVoluntaryText(
      proj.totalMonthlyPayment,
      proj.statutoryMonthlyDeduction,
    );

    return CupertinoPageScaffold(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            LiquidGlassHeader(
              title: tr.calcHeaderTitle,
              subtitle: tr.isHausa
                  ? 'Binciken Basussuka da Jadawalin Biya'
                  : '10% Statutory Deduction Calculator',
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
              trailing: AnimatedHelpButton(
                isHausa: tr.isHausa,
                onTap: () => showCalculatorGuideModal(context, tr),
              ),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 88),
                children: [
                  CalculatorTipBanner(tr: tr),
                  const SizedBox(height: 14),
                  WalletSummaryCard(
                    projection: proj,
                    tr: tr,
                    onAddLoanYear: () =>
                        showAddOrEditLoanDialog(context, provider),
                  ),
                  const SizedBox(height: 14),
                  SessionLoansCard(
                    sessions: provider.sessionLoans,
                    tr: tr,
                    onEditSession: (session) => showAddOrEditLoanDialog(
                      context,
                      provider,
                      existingLoan: session,
                    ),
                    onRemoveSession: provider.removeSessionLoan,
                  ),
                  const SizedBox(height: 16),
                  EmploymentConfiguratorCard(
                    provider: provider,
                    projection: proj,
                    tr: tr,
                    incomeController: _incomeController,
                    voluntaryController: _voluntaryController,
                  ),
                  const SizedBox(height: 16),
                  NyscGracePeriodCard(projection: proj, tr: tr),
                  const SizedBox(height: 16),
                  FriendlyComplianceCard(tr: tr),
                  const SizedBox(height: 16),
                  StatutoryNoticeText(tr: tr),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
