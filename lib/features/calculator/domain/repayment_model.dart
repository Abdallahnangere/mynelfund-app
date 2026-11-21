import '../../../../core/formatters/currency_formatter.dart';
import '../../../../core/localization/app_locale.dart';

enum RepaymentMode { employedPaye, selfEmployedIbr }

extension RepaymentModeExtension on RepaymentMode {
  String get title => getTitle(AppLanguage.english);

  String getTitle(AppLanguage lang) {
    if (lang == AppLanguage.hausa) {
      switch (this) {
        case RepaymentMode.employedPaye:
          return 'Mai Aikin Albashi (PAYE)';
        case RepaymentMode.selfEmployedIbr:
          return 'Mai Sana\'ar Dogaro da Kai';
      }
    }
    switch (this) {
      case RepaymentMode.employedPaye:
        return 'Employed (PAYE)';
      case RepaymentMode.selfEmployedIbr:
        return 'Self-Employed (Direct)';
    }
  }

  String get description => getDescription(AppLanguage.english);

  String getDescription(AppLanguage lang) {
    if (lang == AppLanguage.hausa) {
      switch (this) {
        case RepaymentMode.employedPaye:
          return 'Ma\'aikatarka za ta rage 10% kai-tsaye daga babban albashinka a tushe tare da tura shi asusun NELFUND.';
        case RepaymentMode.selfEmployedIbr:
          return 'Za ka rinka biyan 10% na ribar kasuwancinka a wata kai-tsaye zuwa NELFUND cikin wa\'adin doka.';
      }
    }
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
  final List<int> upkeepMonths; // 1 to 12 (Jan - Dec)
  final double upkeepAmount;

  AcademicSessionLoan({
    required this.level,
    required this.tuitionFee,
    this.includeUpkeep = true,
    this.upkeepMonths = const [],
    double? upkeepAmount,
  }) : upkeepAmount =
           upkeepAmount ??
           (includeUpkeep ? (upkeepMonths.length * 20000.0) : 0.0);

  int get upkeepMonthsCount => upkeepMonths.length;

  double get totalAmount => tuitionFee + (includeUpkeep ? upkeepAmount : 0.0);

  String get levelLabel => getLevelLabel(AppLanguage.english);

  String getLevelLabel(AppLanguage lang) {
    return lang == AppLanguage.hausa ? 'Aji na $level' : '$level Level';
  }

  String get formattedTuition => CurrencyFormatter.formatNaira(tuitionFee);
  String get formattedUpkeep =>
      CurrencyFormatter.formatNaira(includeUpkeep ? upkeepAmount : 0.0);
  String get formattedTotal => CurrencyFormatter.formatNaira(totalAmount);

  String getUpkeepSummary(AppLanguage lang) {
    if (!includeUpkeep || upkeepMonths.isEmpty || upkeepAmount <= 0) {
      return lang == AppLanguage.hausa ? 'Babu Alawus' : 'No Upkeep';
    }
    final count = upkeepMonths.length;
    final monthStr = lang == AppLanguage.hausa
        ? (count == 1 ? 'Wata 1' : 'Watanni $count')
        : (count == 1 ? '1 mo' : '$count mos');
    return '$formattedUpkeep ($monthStr)';
  }

  AcademicSessionLoan copyWith({
    int? level,
    double? tuitionFee,
    bool? includeUpkeep,
    List<int>? upkeepMonths,
    double? upkeepAmount,
  }) {
    return AcademicSessionLoan(
      level: level ?? this.level,
      tuitionFee: tuitionFee ?? this.tuitionFee,
      includeUpkeep: includeUpkeep ?? this.includeUpkeep,
      upkeepMonths: upkeepMonths ?? this.upkeepMonths,
      upkeepAmount: upkeepAmount ?? this.upkeepAmount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'level': level,
      'tuitionFee': tuitionFee,
      'includeUpkeep': includeUpkeep,
      'upkeepMonths': upkeepMonths,
      'upkeepAmount': upkeepAmount,
    };
  }

  factory AcademicSessionLoan.fromMap(Map<String, dynamic> map) {
    return AcademicSessionLoan(
      level: (map['level'] as num?)?.toInt() ?? 100,
      tuitionFee: (map['tuitionFee'] as num?)?.toDouble() ?? 0.0,
      includeUpkeep: map['includeUpkeep'] as bool? ?? true,
      upkeepMonths:
          (map['upkeepMonths'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      upkeepAmount: (map['upkeepAmount'] as num?)?.toDouble(),
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

  String get formattedLoanAmount => CurrencyFormatter.formatNaira(loanAmount);
  String get formattedMonthlyIncome =>
      CurrencyFormatter.formatNaira(monthlyIncome);
  String get formattedStatutoryDeduction =>
      CurrencyFormatter.formatNaira(statutoryMonthlyDeduction);
  String get formattedExtraPayment =>
      CurrencyFormatter.formatNaira(extraMonthlyPayment);
  String get formattedTotalMonthlyPayment =>
      CurrencyFormatter.formatNaira(totalMonthlyPayment);

  String formatDuration(int months, [AppLanguage lang = AppLanguage.english]) {
    if (months <= 0) {
      return lang == AppLanguage.hausa ? 'Watanni 0' : '0 Months';
    }
    final years = months ~/ 12;
    final remMonths = months % 12;

    if (lang == AppLanguage.hausa) {
      if (years == 0) {
        return '$remMonths ${remMonths == 1 ? 'Wata' : 'Watanni'}';
      }
      if (remMonths == 0) return '$years ${years == 1 ? 'Shekara' : 'Shekaru'}';
      return '$years ${years == 1 ? 'Shekara' : 'Shekaru'}, $remMonths ${remMonths == 1 ? 'Wata' : 'Watanni'}';
    }

    if (years == 0) return '$remMonths ${remMonths == 1 ? 'Month' : 'Months'}';
    if (remMonths == 0) return '$years ${years == 1 ? 'Year' : 'Years'}';
    return '$years ${years == 1 ? 'Yr' : 'Yrs'}, $remMonths ${remMonths == 1 ? 'Mo' : 'Mos'}';
  }

  bool get isVoluntaryAccelerated => extraMonthlyPayment > 0;

  String get formattedBaselineDuration => formatDuration(baselineMonths);
  String get formattedAcceleratedDuration => formatDuration(acceleratedMonths);
  String get formattedTimeSaved => formatDuration(monthsSaved);

  String get formattedPayoffTimeline =>
      getFormattedPayoffTimeline(AppLanguage.english);

  String getFormattedPayoffTimeline([AppLanguage lang = AppLanguage.english]) {
    if (loanAmount <= 0) {
      return lang == AppLanguage.hausa
          ? 'Ba a Saka Bashi Ba'
          : 'No Loans Added';
    }
    if (statutoryMonthlyDeduction <= 0) {
      return lang == AppLanguage.hausa
          ? 'Shigar da Kudin Shiga'
          : 'Enter Monthly Income';
    }
    return formatDuration(
      isVoluntaryAccelerated ? acceleratedMonths : baselineMonths,
      lang,
    );
  }
}
