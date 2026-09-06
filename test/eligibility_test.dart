import 'package:flutter_test/flutter_test.dart';
import 'package:my_nelfund/models/eligibility_model.dart';
import 'package:my_nelfund/providers/eligibility_provider.dart';

void main() {
  group('EligibilityProvider Statutory Logic Tests', () {
    late EligibilityProvider provider;

    setUp(() {
      provider = EligibilityProvider();
    });

    test('Initial state qualifies as likely eligible with zero disqualifications', () {
      final report = provider.report;
      expect(report.isLikelyEligible, isTrue);
      expect(report.disqualificationReasons, isEmpty);
      expect(report.summaryTitle, contains('Likely Eligible'));
    });

    test('Flagging prior loan default triggers statutory disqualification under Section 3.1', () {
      provider.togglePriorLoanDefault(true);
      final report = provider.report;

      expect(report.isLikelyEligible, isFalse);
      expect(report.disqualificationReasons.length, 1);
      expect(report.disqualificationReasons.first, contains('Prior loan default'));
      expect(report.summaryTitle, contains('May Be Disqualified'));
    });

    test('Flagging exam misconduct or felony convictions disqualifies applicant', () {
      provider.toggleAcademicMisconduct(true);
      provider.toggleCriminalConviction(true);
      final report = provider.report;

      expect(report.isLikelyEligible, isFalse);
      expect(report.disqualificationReasons.length, 2);
    });

    test('Missing Nigerian citizenship or BVN places application in pending requirements', () {
      provider.toggleNigerianCitizen(false);
      final report = provider.report;

      expect(report.isLikelyEligible, isFalse);
      expect(report.pendingRequirements.length, 1);
      expect(report.pendingRequirements.first, contains('citizenship'));
      expect(report.summaryTitle, contains('Action Required'));
    });

    test('Switching academic entry stream dynamically updates requirement label', () {
      provider.setAcademicType(AcademicEntryType.undergraduate);
      expect(provider.academicType.academicRequirementLabel, contains('Matriculation Number'));

      provider.setAcademicType(AcademicEntryType.freshEntry);
      expect(provider.academicType.academicRequirementLabel, contains('JAMB Admission Letter'));
    });

    test('Reset clears all disqualifications and restores baseline', () {
      provider.togglePriorLoanDefault(true);
      provider.toggleHoldsFirstDegree(true);
      expect(provider.report.isLikelyEligible, isFalse);

      provider.reset();
      expect(provider.report.isLikelyEligible, isTrue);
      expect(provider.report.disqualificationReasons, isEmpty);
    });
  });
}
