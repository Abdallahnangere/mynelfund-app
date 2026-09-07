import 'package:intl/intl.dart';

enum RepaymentMode {
  employedPaye,
  selfEmployedIbr,
}

extension RepaymentModeExtension on RepaymentMode {
  String get title {
    switch (this) {
      case RepaymentMode.employedPaye:
        return 'Employed (PAYE)';
      case RepaymentMode.selfEmployedIbr:
        return 'Self-Employed (Direct)';
    }
  }

  String get description {
    switch (this) {
      case RepaymentMode.employedPaye:
        return '10% deducted at source by your employer from monthly salary and remitted to NELFUND.';
      case RepaymentMode.selfEmployedIbr:
        return '10% of monthly business profit remitted directly to NELFUND within statutory deadlines.';
    }
  }
}

class AcademicSessionLoan {
  final int level; // 100, 200, 300, 400, 500, 600
  final double tuitionFee;
  final bool includeUpkeep;
  final double upkeepAmount; // Statutory: ₦20,000 * 12 = ₦240,000

  const AcademicSessionLoan({
    required this.level,
    required this.tuitionFee,
    this.includeUpkeep = true,
    this.upkeepAmount = 240000.0,
  });

  double get totalAmount => tuitionFee + (includeUpkeep ? upkeepAmount : 0.0);

  String get levelLabel => '$level Level';
  String get formattedTuition =>
      NumberFormat.currency(symbol: '₦', decimalDigits: 0).format(tuitionFee);
  String get formattedUpkeep =>
      NumberFormat.currency(symbol: '₦', decimalDigits: 0)
          .format(includeUpkeep ? upkeepAmount : 0.0);
  String get formattedTotal =>
      NumberFormat.currency(symbol: '₦', decimalDigits: 0).format(totalAmount);

  AcademicSessionLoan copyWith({
    int? level,
    double? tuitionFee,
    bool? includeUpkeep,
    double? upkeepAmount,
  }) {
    return AcademicSessionLoan(
      level: level ?? this.level,
      tuitionFee: tuitionFee ?? this.tuitionFee,
      includeUpkeep: includeUpkeep ?? this.includeUpkeep,
      upkeepAmount: upkeepAmount ?? this.upkeepAmount,
    );
  }
}

class RepaymentProjection {
  final double loanAmount;
  final double monthlyIncome;
  final double statutoryRate;
  final double statutoryMonthlyDeduction;
  final int baselineMonths;
  final double extraMonthlyPayment;
  final double totalMonthlyPayment;
  final int acceleratedMonths;
  final int monthsSaved;
  final DateTime nyscCompletionDate;
  final DateTime repaymentStartDate;
  final List<AcademicSessionLoan> sessionLoans;

  const RepaymentProjection({
    required this.loanAmount,
    required this.monthlyIncome,
    required this.statutoryRate,
    required this.statutoryMonthlyDeduction,
    required this.baselineMonths,
    required this.extraMonthlyPayment,
    required this.totalMonthlyPayment,
    required this.acceleratedMonths,
    required this.monthsSaved,
    required this.nyscCompletionDate,
    required this.repaymentStartDate,
    this.sessionLoans = const [],
  });

  static final NumberFormat _nairaFormat =
      NumberFormat.currency(symbol: '₦', decimalDigits: 0);

  String get formattedLoanAmount => _nairaFormat.format(loanAmount);
  String get formattedMonthlyIncome => _nairaFormat.format(monthlyIncome);
  String get formattedStatutoryDeduction =>
      _nairaFormat.format(statutoryMonthlyDeduction);
  String get formattedExtraPayment => _nairaFormat.format(extraMonthlyPayment);
  String get formattedTotalMonthlyPayment =>
      _nairaFormat.format(totalMonthlyPayment);

  String formatDuration(int months) {
    if (months <= 0) return '0 Months';
    final years = months ~/ 12;
    final remMonths = months % 12;
    if (years == 0) return '$remMonths ${remMonths == 1 ? 'Month' : 'Months'}';
    if (remMonths == 0) return '$years ${years == 1 ? 'Year' : 'Years'}';
    return '$years ${years == 1 ? 'Yr' : 'Yrs'}, $remMonths ${remMonths == 1 ? 'Mo' : 'Mos'}';
  }

  String get formattedBaselineDuration => formatDuration(baselineMonths);
  String get formattedAcceleratedDuration =>
      formatDuration(acceleratedMonths);
  String get formattedTimeSaved => formatDuration(monthsSaved);

  String get formattedPayoffTimeline {
    if (loanAmount <= 0) return 'No Loans Added';
    if (statutoryMonthlyDeduction <= 0) return 'Enter Monthly Income';
    return formattedBaselineDuration;
  }
}
