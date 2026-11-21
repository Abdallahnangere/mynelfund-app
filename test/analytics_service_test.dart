import 'package:flutter_test/flutter_test.dart';
import 'package:my_nelfund/core/services/analytics_service.dart';

void main() {
  group('AnalyticsService Tests', () {
    test('Singleton instance exists and is non-null', () {
      final service = AnalyticsService.instance;
      expect(service, isNotNull);
    });

    test(
      'All event logging methods run safely in headless test harness without throwing',
      () async {
        final service = AnalyticsService.instance;

        await expectLater(service.logAppOpen(), completes);
        await expectLater(service.logScreenView('TestScreen'), completes);
        await expectLater(service.logTabSelected(0, 'Home'), completes);
        await expectLater(
          service.logEligibilityCheck(
            isEligible: true,
            metCriteriaCount: 5,
            unmetCount: 0,
            disqualifierCount: 0,
          ),
          completes,
        );
        await expectLater(
          service.logLoanCalculation(
            institutionalFees: 120000,
            upkeepTotal: 240000,
            totalLoan: 360000,
            expectedIncome: 150000,
            monthlyDeduction: 15000,
            repaymentMonths: 24,
          ),
          completes,
        );
        await expectLater(
          service.logFaqSearch(query: '30-day refund', matchCount: 1),
          completes,
        );
        await expectLater(
          service.logDeveloperContact(method: 'call_phone'),
          completes,
        );
        await expectLater(
          service.logExternalLink(
            destination: 'NELFUND Portal',
            url: 'https://nelf.gov.ng',
          ),
          completes,
        );
        await expectLater(
          service.logNotificationInteraction(
            title: 'Portal Open',
            messageId: 'msg-456',
            action: 'opened_from_background',
          ),
          completes,
        );
      },
    );
  });
}
