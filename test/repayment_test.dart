import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_nelfund/models/repayment_model.dart';
import 'package:my_nelfund/providers/repayment_provider.dart';
import 'package:my_nelfund/views/calculator/calculator_view.dart';

void main() {
  group('RepaymentProvider Statutory Calculation Tests', () {
    late RepaymentProvider provider;

    setUp(() {
      provider = RepaymentProvider();
    });

    test('Computes exact 10% statutory deduction on monthly income', () {
      provider.setMonthlyIncome(150000);
      expect(provider.projection.statutoryMonthlyDeduction, 15000.0);
      expect(provider.projection.formattedStatutoryDeduction, '₦15,000.00');

      provider.setMonthlyIncome(70000); // National minimum wage baseline
      expect(provider.projection.statutoryMonthlyDeduction, 7000.0);
      expect(provider.projection.formattedStatutoryDeduction, '₦7,000.00');
    });

    test('Calculates accurate baseline duration in months and formatted text', () {
      provider.setLoanAmount(1200000);
      provider.setMonthlyIncome(150000); // 15k / mo deduction
      final proj = provider.projection;

      expect(proj.baselineMonths, 80); // 1,200,000 / 15,000 = 80 months
      expect(proj.formattedBaselineDuration, '6 Yrs, 8 Mos');
    });

    test('Accelerated prepayment reduces repayment timeline and records time saved', () {
      provider.setLoanAmount(1200000);
      provider.setMonthlyIncome(150000); // 15,000/mo statutory
      provider.setExtraPrepayment(10000); // 25,000/mo total

      final proj = provider.projection;
      expect(proj.totalMonthlyPayment, 25000.0);
      expect(proj.acceleratedMonths, 48); // 1,200,000 / 25,000 = 48 months (4 yrs)
      expect(proj.monthsSaved, 32); // 80 - 48 = 32 months saved
      expect(proj.formattedAcceleratedDuration, '4 Years');
    });

    test('Calculates post-NYSC moratorium exactly 2 years into the future', () {
      provider.setNyscGraduationYear(2025);
      provider.setNyscGraduationMonth(11);

      final proj = provider.projection;
      expect(proj.nyscCompletionDate.year, 2025);
      expect(proj.repaymentStartDate.year, 2027);
      expect(proj.repaymentStartDate.month, 11);
    });

    test('Mode switching updates between employed and self-employed models', () {
      expect(provider.mode, RepaymentMode.employedPaye);
      provider.setMode(RepaymentMode.selfEmployedIbr);
      expect(provider.mode, RepaymentMode.selfEmployedIbr);
      expect(provider.mode.title, contains('Self-Employed'));
    });

    test('Session loans onboarding, upkeep calculation, and dynamic portfolio total', () {
      // Starts with zero session loans and zero loan amount
      expect(provider.sessionLoans.isEmpty, true);
      expect(provider.loanAmount, 0.0);

      // Add 100 Level: 120,000 tuition + 240,000 upkeep = 360,000
      provider.addOrUpdateSessionLoan(
        const AcademicSessionLoan(
          level: 100,
          tuitionFee: 120000.0,
          includeUpkeep: true,
          upkeepAmount: 240000.0,
        ),
      );
      expect(provider.sessionLoans.length, 1);
      expect(provider.loanAmount, 360000.0);
      expect(provider.sessionLoans.first.totalAmount, 360000.0);
      expect(provider.sessionLoans.first.upkeepAmount, 240000.0);

      // Add 200 Level loan: 150,000 tuition without upkeep
      provider.addOrUpdateSessionLoan(
        const AcademicSessionLoan(
          level: 200,
          tuitionFee: 150000.0,
          includeUpkeep: false,
        ),
      );

      expect(provider.sessionLoans.length, 2);
      expect(provider.loanAmount, 510000.0); // 360k + 150k

      // Update 100 Level
      provider.addOrUpdateSessionLoan(
        const AcademicSessionLoan(
          level: 100,
          tuitionFee: 100000.0,
          includeUpkeep: true,
          upkeepAmount: 240000.0,
        ),
      );
      expect(provider.loanAmount, 490000.0); // (100k + 240k) + 150k

      // Remove session
      provider.removeSessionLoan(200);
      expect(provider.sessionLoans.length, 1);
      expect(provider.loanAmount, 340000.0);
    });

    test('Reset restores standard zero parameters', () {
      provider.setLoanAmount(3000000);
      provider.setMonthlyIncome(500000);
      provider.setExtraPrepayment(50000);
      provider.reset();

      expect(provider.loanAmount, 0.0);
      expect(provider.monthlyIncome, 0.0);
      expect(provider.extraPrepayment, 0.0);
      expect(provider.sessionLoans.isEmpty, true);
    });

    test('AcademicSessionLoan formats currency with two decimal digits and commas', () {
      const loan = AcademicSessionLoan(
        level: 100,
        tuitionFee: 120000,
        includeUpkeep: true,
        upkeepAmount: 240000,
      );
      expect(loan.formattedTuition, '₦120,000.00');
      expect(loan.formattedUpkeep, '₦240,000.00');
      expect(loan.formattedTotal, '₦360,000.00');
    });

    test('AcademicSessionLoan supports granular upkeep months and accurate summaries', () {
      // 5 months selected: 5 * 20,000 = 100,000
      final loan5Months = AcademicSessionLoan(
        level: 100,
        tuitionFee: 120000,
        includeUpkeep: true,
        upkeepMonths: const [1, 2, 3, 4, 5],
      );
      expect(loan5Months.upkeepMonthsCount, 5);
      expect(loan5Months.upkeepAmount, 100000.0);
      expect(loan5Months.formattedUpkeep, '₦100,000.00');
      expect(loan5Months.totalAmount, 220000.0);

      // 0 months selected with includeUpkeep false
      const loanNoUpkeep = AcademicSessionLoan(
        level: 200,
        tuitionFee: 150000,
        includeUpkeep: false,
      );
      expect(loanNoUpkeep.upkeepMonthsCount, 0);
      expect(loanNoUpkeep.upkeepAmount, 0.0);
      expect(loanNoUpkeep.totalAmount, 150000.0);
    });

    test('Voluntary repayment configurator calculates extra prepayment accurately', () {
      provider.setLoanAmount(360000);
      provider.setMonthlyIncome(70000); // 7,000 statutory

      expect(provider.projection.statutoryMonthlyDeduction, 7000.0);
      expect(provider.extraPrepayment, 0.0);
      expect(provider.projection.isVoluntaryAccelerated, false);

      // User configures total 20,000 monthly payment (7,000 statutory + 13,000 voluntary)
      provider.setVoluntaryTotalMonthlyPayment(20000);
      expect(provider.extraPrepayment, 13000.0);
      expect(provider.projection.totalMonthlyPayment, 20000.0);
      expect(provider.projection.isVoluntaryAccelerated, true);

      // Baseline: 360,000 / 7,000 = 52 months (4 Yrs, 4 Mos)
      // Accelerated: 360,000 / 20,000 = 18 months (1 Yr, 6 Mos)
      expect(provider.projection.baselineMonths, 52);
      expect(provider.projection.acceleratedMonths, 18);
      expect(provider.projection.monthsSaved, 34);

      // Test percentage-based voluntary configuration (e.g. 15% on 70k = 10,500 total, 3,500 extra)
      provider.setVoluntaryRatePercent(15.0);
      expect(provider.extraPrepayment, 3500.0);
      expect(provider.projection.totalMonthlyPayment, 10500.0);
    });

    test('ThousandsSeparatorInputFormatter formats raw numbers with commas', () {
      final formatter = ThousandsSeparatorInputFormatter();
      const oldVal = TextEditingValue.empty;
      
      final res1 = formatter.formatEditUpdate(
        oldVal,
        const TextEditingValue(text: '12000'),
      );
      expect(res1.text, '12,000');

      final res2 = formatter.formatEditUpdate(
        oldVal,
        const TextEditingValue(text: '70000'),
      );
      expect(res2.text, '70,000');

      final res3 = formatter.formatEditUpdate(
        oldVal,
        const TextEditingValue(text: '1500000'),
      );
      expect(res3.text, '1,500,000');
    });
  });

  group('CalculatorView UI Tests', () {
    testWidgets('Renders header, help button, salary helper, minimum wage, and voluntary configurator', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const CupertinoApp(
          home: CalculatorView(),
        ),
      );
      await tester.pumpAndSettle();

      // Check header and help button
      expect(find.text('Payment Calculator'), findsOneWidget);
      expect(find.text('Help Guide'), findsOneWidget);

      // Check salary helper tip
      expect(
        find.text('Enter the expected salary that you will earn if you get employed.'),
        findsOneWidget,
      );

      // Check only minimum wage suggestion is present
      expect(find.text('₦70,000.00 (Minimum Wage)'), findsOneWidget);
      expect(find.text('₦150k'), findsNothing);

      // Check voluntary repayment configurator section
      expect(find.text('Voluntary Repayment Configurator'), findsOneWidget);
      expect(find.text('Statutory (10%)'), findsOneWidget);
      expect(find.text('15%'), findsOneWidget);
      expect(find.text('20%'), findsOneWidget);

      // Tap minimum wage chip and verify statutory deduction
      await tester.tap(find.text('₦70,000.00 (Minimum Wage)'));
      await tester.pumpAndSettle();

      expect(find.text('₦7,000.00 / mo'), findsAtLeast(1));

      // Tap Help Guide button to open modal
      await tester.tap(find.text('Help Guide'));
      await tester.pumpAndSettle();

      expect(find.text('Loan & Repayment Guide'), findsOneWidget);
      expect(find.text('1. Add Academic Loans & Upkeep'), findsOneWidget);
      expect(find.text('2. NYSC 2-Year Grace Period'), findsOneWidget);
      expect(find.text('3. 10% Statutory & Voluntary Repayment'), findsOneWidget);

      // Dismiss guide modal
      await tester.tap(find.text('Got It, Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Loan & Repayment Guide'), findsNothing);
    });

    testWidgets('Add Loan Dialog Upkeep toggle starts with 0 months selected and allows granular calendar selection', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const CupertinoApp(
          home: CalculatorView(),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap "Add Loan Year"
      expect(find.text('Add Loan Year'), findsOneWidget);
      await tester.tap(find.text('Add Loan Year'));
      await tester.pumpAndSettle();

      // Verify modal bottom sheet dialog appeared
      expect(find.text('Include Upkeep Allowance'), findsOneWidget);

      // Toggle Upkeep switch ON
      await tester.tap(find.byType(CupertinoSwitch));
      await tester.pumpAndSettle();

      // Per user rule: when toggled ON, starts with 0 months (NOT all 12)
      expect(find.text('0/12'), findsOneWidget);
      expect(find.text('No months selected (₦0.00)'), findsOneWidget);

      // Tap Sem 1 quick filter
      await tester.tap(find.text('Sem 1 (M1-6)'));
      await tester.pumpAndSettle();

      expect(find.text('6/12'), findsOneWidget);
      expect(find.text('6 Months Selected × ₦20,000 = ₦120,000.00'), findsOneWidget);

      // Tap 'All 12'
      await tester.tap(find.text('All 12'));
      await tester.pumpAndSettle();

      expect(find.text('12/12'), findsOneWidget);
      expect(find.text('12 Months Selected × ₦20,000 = ₦240,000.00'), findsOneWidget);

      // Submit and add to wallet
      await tester.tap(find.text('Add to Wallet'));
      await tester.pumpAndSettle();

      // Dialog dismissed and wallet shows 100 Level session loan with Upkeep
      expect(find.text('Include Upkeep Allowance'), findsNothing);
      expect(find.text('100 Level'), findsAtLeast(1));
      expect(find.text('₦360,000.00'), findsAtLeast(1));
      expect(find.textContaining('+ Upkeep (12 mos): ₦240,000.00'), findsOneWidget);
    });
  });
}
