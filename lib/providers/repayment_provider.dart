import 'package:flutter/foundation.dart';
import '../core/constants/nelfund_data.dart';
import '../models/repayment_model.dart';

class RepaymentProvider extends ChangeNotifier {
  double _loanAmount = 1200000.0;
  double _monthlyIncome = 150000.0;
  double _extraPrepayment = 0.0;
  RepaymentMode _mode = RepaymentMode.employedPaye;
  int _nyscGraduationYear = DateTime.now().year;
  int _nyscGraduationMonth = 11; // Standard November passing out parade

  // Getters
  double get loanAmount => _loanAmount;
  double get monthlyIncome => _monthlyIncome;
  double get extraPrepayment => _extraPrepayment;
  RepaymentMode get mode => _mode;
  int get nyscGraduationYear => _nyscGraduationYear;
  int get nyscGraduationMonth => _nyscGraduationMonth;

  // Setters
  void setLoanAmount(double value) {
    _loanAmount = value;
    notifyListeners();
  }

  void setMonthlyIncome(double value) {
    _monthlyIncome = value;
    notifyListeners();
  }

  void setExtraPrepayment(double value) {
    _extraPrepayment = value;
    notifyListeners();
  }

  void setMode(RepaymentMode mode) {
    _mode = mode;
    notifyListeners();
  }

  void setNyscGraduationYear(int year) {
    _nyscGraduationYear = year;
    notifyListeners();
  }

  void setNyscGraduationMonth(int month) {
    _nyscGraduationMonth = month;
    notifyListeners();
  }

  void reset() {
    _loanAmount = 1200000.0;
    _monthlyIncome = 150000.0;
    _extraPrepayment = 0.0;
    _mode = RepaymentMode.employedPaye;
    _nyscGraduationYear = DateTime.now().year;
    _nyscGraduationMonth = 11;
    notifyListeners();
  }

  RepaymentProjection get projection {
    const rate = NelfundData.repaymentRatePercent; // 10.0%
    final statutoryMonthlyDeduction = _monthlyIncome * (rate / 100.0);

    final baselineMonths = statutoryMonthlyDeduction > 0
        ? (_loanAmount / statutoryMonthlyDeduction).ceil()
        : 0;

    final totalMonthlyPayment = statutoryMonthlyDeduction + _extraPrepayment;
    final acceleratedMonths = totalMonthlyPayment > 0
        ? (_loanAmount / totalMonthlyPayment).ceil()
        : 0;

    final monthsSaved = (baselineMonths - acceleratedMonths).clamp(0, baselineMonths);

    final nyscCompletion = DateTime(_nyscGraduationYear, _nyscGraduationMonth, 1);
    final repaymentStart = DateTime(
      _nyscGraduationYear + NelfundData.postNyscMoratoriumYears,
      _nyscGraduationMonth,
      1,
    );

    return RepaymentProjection(
      loanAmount: _loanAmount,
      monthlyIncome: _monthlyIncome,
      statutoryRate: rate,
      statutoryMonthlyDeduction: statutoryMonthlyDeduction,
      baselineMonths: baselineMonths,
      extraMonthlyPayment: _extraPrepayment,
      totalMonthlyPayment: totalMonthlyPayment,
      acceleratedMonths: acceleratedMonths,
      monthsSaved: monthsSaved,
      nyscCompletionDate: nyscCompletion,
      repaymentStartDate: repaymentStart,
    );
  }
}
