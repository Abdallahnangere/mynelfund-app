import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/nelfund_data.dart';
import '../core/services/analytics_service.dart';
import '../models/repayment_model.dart';

class RepaymentProvider extends ChangeNotifier {
  static const String _storageKey = 'nelfund_configured_repayment_v1';

  final List<AcademicSessionLoan> _sessionLoans = [];

  double _loanAmount = 0.0;
  double _monthlyIncome = 0.0;
  double _extraPrepayment = 0.0;
  RepaymentMode _mode = RepaymentMode.employedPaye;
  int _nyscGraduationYear = DateTime.now().year;
  int _nyscGraduationMonth = 11; // Standard November passing out parade
  bool _isLoaded = false;

  RepaymentProvider() {
    _syncTotalLoanAmount();
    _loadFromStorage();
  }

  bool get isLoaded => _isLoaded;

  void _syncTotalLoanAmount() {
    if (_sessionLoans.isNotEmpty) {
      _loanAmount = _sessionLoans.fold<double>(
        0.0,
        (sum, item) => sum + item.totalAmount,
      );
    }
  }

  // Getters
  List<AcademicSessionLoan> get sessionLoans => List.unmodifiable(_sessionLoans);
  double get loanAmount => _loanAmount;
  double get monthlyIncome => _monthlyIncome;
  double get extraPrepayment => _extraPrepayment;
  RepaymentMode get mode => _mode;
  int get nyscGraduationYear => _nyscGraduationYear;
  int get nyscGraduationMonth => _nyscGraduationMonth;

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
        _monthlyIncome = (data['monthlyIncome'] as num?)?.toDouble() ?? 0.0;
        _extraPrepayment = (data['extraPrepayment'] as num?)?.toDouble() ?? 0.0;

        final modeStr = data['mode'] as String?;
        if (modeStr == 'selfEmployedIbr') {
          _mode = RepaymentMode.selfEmployedIbr;
        } else {
          _mode = RepaymentMode.employedPaye;
        }

        _nyscGraduationYear = (data['nyscGraduationYear'] as num?)?.toInt() ?? DateTime.now().year;
        _nyscGraduationMonth = (data['nyscGraduationMonth'] as num?)?.toInt() ?? 11;

        final rawLoans = data['sessionLoans'] as List<dynamic>?;
        if (rawLoans != null && rawLoans.isNotEmpty) {
          _sessionLoans.clear();
          for (final item in rawLoans) {
            _sessionLoans.add(AcademicSessionLoan.fromMap(item as Map<String, dynamic>));
          }
          _sessionLoans.sort((a, b) => a.level.compareTo(b.level));
        }

        _syncTotalLoanAmount();
        _isLoaded = true;
        notifyListeners();
        debugPrint('[RepaymentProvider] Restored ${_sessionLoans.length} session loans from phone storage.');
      } else {
        _isLoaded = true;
      }
    } catch (e) {
      debugPrint('[RepaymentProvider] Local storage load note: $e');
      _isLoaded = true;
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'monthlyIncome': _monthlyIncome,
        'extraPrepayment': _extraPrepayment,
        'mode': _mode == RepaymentMode.selfEmployedIbr ? 'selfEmployedIbr' : 'employedPaye',
        'nyscGraduationYear': _nyscGraduationYear,
        'nyscGraduationMonth': _nyscGraduationMonth,
        'sessionLoans': _sessionLoans.map((s) => s.toMap()).toList(),
      };
      await prefs.setString(_storageKey, jsonEncode(data));
      debugPrint('[RepaymentProvider] Saved configured loan profile to phone storage.');
    } catch (e) {
      debugPrint('[RepaymentProvider] Local storage save note: $e');
    }
  }

  Future<void> _clearStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      debugPrint('[RepaymentProvider] Cleared configured loan profile from phone storage.');
    } catch (e) {
      debugPrint('[RepaymentProvider] Local storage clear note: $e');
    }
  }

  // Session Loan Management
  void addOrUpdateSessionLoan(AcademicSessionLoan loan) {
    final index = _sessionLoans.indexWhere((s) => s.level == loan.level);
    if (index >= 0) {
      _sessionLoans[index] = loan;
    } else {
      _sessionLoans.add(loan);
    }
    _sessionLoans.sort((a, b) => a.level.compareTo(b.level));
    _syncTotalLoanAmount();
    notifyListeners();
    _saveToStorage();
    _logAnalytics();
  }

  void removeSessionLoan(int level) {
    _sessionLoans.removeWhere((s) => s.level == level);
    if (_sessionLoans.isEmpty) {
      _loanAmount = 0.0;
    } else {
      _syncTotalLoanAmount();
    }
    notifyListeners();
    _saveToStorage();
    _logAnalytics();
  }

  // Setters
  void setLoanAmount(double value) {
    _loanAmount = value;
    notifyListeners();
    _saveToStorage();
    _logAnalytics();
  }

  void setMonthlyIncome(double value) {
    _monthlyIncome = value;
    notifyListeners();
    _saveToStorage();
    _logAnalytics();
  }

  void _logAnalytics() {
    final proj = projection;
    final tuitionTotal =
        _sessionLoans.fold<double>(0.0, (sum, s) => sum + s.tuitionFee);
    final upkeepTotal =
        _sessionLoans.fold<double>(0.0, (sum, s) => sum + s.upkeepAmount);
    AnalyticsService.instance.logLoanCalculation(
      institutionalFees: tuitionTotal,
      upkeepTotal: upkeepTotal,
      totalLoan: proj.loanAmount,
      expectedIncome: proj.monthlyIncome,
      monthlyDeduction: proj.statutoryMonthlyDeduction,
      repaymentMonths: proj.baselineMonths,
    );
  }

  void setExtraPrepayment(double value) {
    _extraPrepayment = value.clamp(0.0, double.infinity);
    notifyListeners();
    _saveToStorage();
  }

  void setVoluntaryTotalMonthlyPayment(double totalAmount) {
    const rate = NelfundData.repaymentRatePercent; // 10.0%
    final statutory = _monthlyIncome * (rate / 100.0);
    if (totalAmount > statutory) {
      _extraPrepayment = totalAmount - statutory;
    } else {
      _extraPrepayment = 0.0;
    }
    notifyListeners();
    _saveToStorage();
  }

  void setVoluntaryRatePercent(double targetPercent) {
    if (targetPercent > NelfundData.repaymentRatePercent) {
      final extraPercent = targetPercent - NelfundData.repaymentRatePercent;
      _extraPrepayment = _monthlyIncome * (extraPercent / 100.0);
    } else {
      _extraPrepayment = 0.0;
    }
    notifyListeners();
    _saveToStorage();
  }

  void setMode(RepaymentMode mode) {
    _mode = mode;
    notifyListeners();
    _saveToStorage();
  }

  void setNyscGraduationYear(int year) {
    _nyscGraduationYear = year;
    notifyListeners();
    _saveToStorage();
  }

  void setNyscGraduationMonth(int month) {
    _nyscGraduationMonth = month;
    notifyListeners();
    _saveToStorage();
  }

  void reset() {
    _sessionLoans.clear();
    _loanAmount = 0.0;
    _monthlyIncome = 0.0;
    _extraPrepayment = 0.0;
    _mode = RepaymentMode.employedPaye;
    _nyscGraduationYear = DateTime.now().year;
    _nyscGraduationMonth = 11;
    _clearStorage();
    notifyListeners();
  }

  RepaymentProjection get projection {
    const rate = NelfundData.repaymentRatePercent; // 10.0%
    final statutoryMonthlyDeduction = _monthlyIncome * (rate / 100.0);

    final baselineMonths = statutoryMonthlyDeduction > 0 && _loanAmount > 0
        ? (_loanAmount / statutoryMonthlyDeduction).ceil()
        : 0;

    final totalMonthlyPayment = statutoryMonthlyDeduction + _extraPrepayment;
    final acceleratedMonths = totalMonthlyPayment > 0 && _loanAmount > 0
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
      sessionLoans: _sessionLoans,
    );
  }
}
