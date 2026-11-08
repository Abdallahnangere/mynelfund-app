import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Production-grade Google Analytics Service for My NELFund.
///
/// Encapsulates event logging, screen view tracking, user properties,
/// and automated error protection for both Android and iOS.
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  FirebaseAnalytics? _analytics;
  FirebaseAnalyticsObserver? _observer;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  FirebaseAnalytics? get analytics => _analytics;

  FirebaseAnalyticsObserver? get observer {
    if (_analytics != null) {
      _observer ??= FirebaseAnalyticsObserver(analytics: _analytics!);
      return _observer;
    }
    return null;
  }

  /// Initialize Google Analytics
  Future<void> initialize() async {
    if (_isInitialized || kIsWeb) return;

    try {
      _analytics = FirebaseAnalytics.instance;
      await _analytics?.setAnalyticsCollectionEnabled(true);
      _isInitialized = true;
      await logAppOpen();
      debugPrint('[AnalyticsService] Google Analytics initialized successfully.');
    } catch (e) {
      debugPrint('[AnalyticsService] Note: Analytics unavailable in this environment ($e).');
    }
  }

  /// Log App Open Event
  Future<void> logAppOpen() async {
    try {
      await _analytics?.logAppOpen();
    } catch (_) {}
  }

  /// Log Screen Views
  Future<void> logScreenView(String screenName) async {
    try {
      await _analytics?.logScreenView(
        screenName: screenName,
        screenClass: screenName,
      );
    } catch (_) {}
  }

  /// Log Bottom Navigation Tab Switching
  Future<void> logTabSelected(int tabIndex, String tabName) async {
    try {
      await _analytics?.logEvent(
        name: 'tab_switched',
        parameters: {
          'tab_index': tabIndex,
          'tab_name': tabName,
        },
      );
    } catch (_) {}
  }

  /// Log Statutory Eligibility Check Result
  Future<void> logEligibilityCheck({
    required bool isEligible,
    required int metCriteriaCount,
    required int unmetCount,
    required int disqualifierCount,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'eligibility_audit_completed',
        parameters: {
          'is_eligible': isEligible ? 1 : 0,
          'met_criteria_count': metCriteriaCount,
          'unmet_count': unmetCount,
          'disqualifier_count': disqualifierCount,
        },
      );
    } catch (_) {}
  }

  /// Log Student Loan & Repayment Simulation
  Future<void> logLoanCalculation({
    required double institutionalFees,
    required double upkeepTotal,
    required double totalLoan,
    required double expectedIncome,
    required double monthlyDeduction,
    required int repaymentMonths,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'loan_calculated',
        parameters: {
          'institutional_fees': institutionalFees,
          'upkeep_total': upkeepTotal,
          'total_loan': totalLoan,
          'expected_income': expectedIncome,
          'monthly_deduction': monthlyDeduction,
          'repayment_months': repaymentMonths,
        },
      );
    } catch (_) {}
  }

  /// Log FAQ Search Queries
  Future<void> logFaqSearch({
    required String query,
    required int matchCount,
  }) async {
    if (query.trim().isEmpty) return;
    try {
      await _analytics?.logEvent(
        name: 'faq_searched',
        parameters: {
          'search_term': query.trim().toLowerCase(),
          'result_count': matchCount,
        },
      );
    } catch (_) {}
  }

  /// Log Developer Contact Action (Call, Copy, WhatsApp)
  Future<void> logDeveloperContact({
    required String method,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'developer_contact_tapped',
        parameters: {
          'contact_method': method,
        },
      );
    } catch (_) {}
  }

  /// Log Official External Links (NELFUND Portal, Anjal Ventures)
  Future<void> logExternalLink({
    required String destination,
    required String url,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'external_link_opened',
        parameters: {
          'destination': destination,
          'url': url,
        },
      );
    } catch (_) {}
  }

  /// Log In-App Push Notification Receipt or Tap
  Future<void> logNotificationInteraction({
    required String title,
    required String? messageId,
    required String action,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'push_notification_interaction',
        parameters: {
          'notification_title': title,
          'message_id': messageId ?? 'unknown',
          'action': action,
        },
      );
    } catch (_) {}
  }

  /// Log Sauki Go Companion App Promo Impression
  Future<void> logSaukiPromoImpression({
    required String placement,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'sauki_promo_impression',
        parameters: {
          'placement': placement,
        },
      );
    } catch (_) {}
  }

  /// Log Sauki Go Startup / On-Demand Modal Dismissal
  Future<void> logSaukiPromoDismissed({
    required String trigger,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'sauki_promo_dismissed',
        parameters: {
          'trigger': trigger,
        },
      );
    } catch (_) {}
  }

  /// Log Sauki Go Store Badge Click (App Store / Google Play)
  Future<void> logSaukiPromoStoreClick({
    required String store,
    required String placement,
    required String url,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'sauki_promo_store_clicked',
        parameters: {
          'store': store,
          'placement': placement,
          'url': url,
        },
      );
    } catch (_) {}
  }
}

