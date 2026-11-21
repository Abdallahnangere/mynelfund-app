import 'package:flutter_test/flutter_test.dart';
import 'package:my_nelfund/features/eligibility/domain/eligibility_model.dart';
import 'package:my_nelfund/features/eligibility/presentation/providers/eligibility_provider.dart';

void main() {
  group('EligibilityProvider Statutory Logic Tests', () {
    late EligibilityProvider provider;

    setUp(() {
      provider = EligibilityProvider();
    });

    test(
      'Initial state starts with all unchecked boxes pending verification',
      () {
        final report = provider.report;
        expect(report.isLikelyEligible, isFalse);
        expect(report.disqualificationReasons, isEmpty);
        expect(report.pendingRequirements.length, 4);
        expect(report.summaryTitle, contains('Action Required'));
      },
    );

    test('Satisfying all core criteria qualifies as likely eligible', () {
      provider.toggleNigerianCitizen(true);
      provider.toggleEnrolledInPublicEti(true);
      provider.toggleAcademicAdmissionVerified(true);
      provider.toggleSchoolDataUploaded(true);

      final report = provider.report;
      expect(report.isLikelyEligible, isTrue);
      expect(report.disqualificationReasons, isEmpty);
      expect(report.summaryTitle, contains('Likely Eligible'));
    });

    test(
      'Flagging prior loan default triggers statutory disqualification under Section 3.1',
      () {
        provider.togglePriorLoanDefault(true);
        final report = provider.report;

        expect(report.isLikelyEligible, isFalse);
        expect(report.disqualificationReasons.length, 1);
        expect(
          report.disqualificationReasons.first,
          contains('Prior loan default'),
        );
        expect(report.summaryTitle, contains('Disqualification'));
      },
    );

    test(
      'Flagging exam misconduct or felony convictions disqualifies applicant',
      () {
        provider.toggleAcademicMisconduct(true);
        provider.toggleCriminalConviction(true);
        final report = provider.report;

        expect(report.isLikelyEligible, isFalse);
        expect(report.disqualificationReasons.length, 2);
      },
    );

    test(
      'Missing Nigerian citizenship places application in pending requirements',
      () {
        provider.toggleEnrolledInPublicEti(true);
        provider.toggleAcademicAdmissionVerified(true);
        provider.toggleSchoolDataUploaded(true);
        provider.toggleNigerianCitizen(false);
        final report = provider.report;

        expect(report.isLikelyEligible, isFalse);
        expect(report.pendingRequirements.length, 1);
        expect(report.pendingRequirements.first, contains('citizenship'));
        expect(report.summaryTitle, contains('Action Required'));
      },
    );

    test(
      'Detailed 3-section report correctly tracks Core, KYC, and Disqualification counts',
      () {
        provider.toggleNigerianCitizen(true);
        provider.toggleEnrolledInPublicEti(true);
        provider.toggleJambNumber(true);
        provider.toggleBvn(true);
        provider.toggleNin(true);

        final report = provider.report;
        expect(report.coreMetCount, 2);
        expect(report.coreTotalCount, 4);
        expect(report.kycMetCount, 3);
        expect(report.kycTotalCount, 6);
        expect(report.disqualifierCount, 0);
        expect(report.hasDisqualifiers, isFalse);
      },
    );

    test(
      'Switching academic entry stream dynamically updates requirement label',
      () {
        provider.setAcademicType(AcademicEntryType.undergraduate);
        expect(
          provider.academicType.academicRequirementLabel,
          contains('Matriculation Number'),
        );

        provider.setAcademicType(AcademicEntryType.freshEntry);
        expect(
          provider.academicType.academicRequirementLabel,
          contains('JAMB Admission Letter'),
        );
      },
    );

    test(
      'Reset clears all disqualifications and restores unchecked baseline',
      () {
        provider.toggleNigerianCitizen(true);
        provider.togglePriorLoanDefault(true);
        provider.toggleHoldsFirstDegree(true);
        expect(provider.report.isLikelyEligible, isFalse);

        provider.reset();
        expect(provider.report.isLikelyEligible, isFalse);
        expect(provider.report.disqualificationReasons, isEmpty);
        expect(reportAfterReset().pendingRequirements.length, 4);
      },
    );
  });
}

EligibilityReport reportAfterReset() => EligibilityProvider().report;
