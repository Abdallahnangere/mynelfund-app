import 'package:flutter_test/flutter_test.dart';
import 'package:my_nelfund/models/repayment_model.dart';
import 'package:my_nelfund/providers/repayment_provider.dart';

void main() {
  group('RepaymentProvider Statutory Calculation Tests', () {
    late RepaymentProvider provider;

    setUp(() {
      provider = RepaymentProvider();
    });

    test('Computes exact 10% statutory deduction on monthly income', () {
      provider.setMonthlyIncome(150000);
      expect(provider.projection.statutoryMonthlyDeduction, 15000.0);
      expect(provider.projection.formattedStatutoryDeduction, '₦15,000');

      provider.setMonthlyIncome(70000); // National minimum wage baseline
      expect(provider.projection.statutoryMonthlyDeduction, 7000.0);
      expect(provider.projection.formattedStatutoryDeduction, '₦7,000');
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
      // Starts with 100 Level: 120,000 tuition + 240,000 upkeep = 360,000
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

    test('Reset restores standard parameters', () {
      provider.setLoanAmount(3000000);
      provider.setMonthlyIncome(500000);
      provider.setExtraPrepayment(50000);
      provider.reset();

      expect(provider.loanAmount, 360000.0);
      expect(provider.monthlyIncome, 150000.0);
      expect(provider.extraPrepayment, 0.0);
      expect(provider.sessionLoans.length, 1);
    });
  });
}
