import 'package:flutter/foundation.dart';
import '../models/eligibility_model.dart';

class EligibilityProvider extends ChangeNotifier {
  AcademicEntryType _academicType = AcademicEntryType.freshEntry;

  // Core Eligibility Criteria (Section 2.0)
  bool _isNigerianCitizen = false;
  bool _isEnrolledInPublicEti = false;
  bool _isAcademicAdmissionVerified = false;
  bool _isSchoolDataUploaded = false;

  // KYC Readiness Checklist (Section 2.3)
  bool _hasJambNumber = false;
  bool _hasBvn = false;
  bool _hasNin = false;
  bool _hasPersonalInfo = false;
  bool _hasPassportPhoto = false;
  bool _hasAdmissionOrStudentId = false;

  // Disqualification Flags (Section 3.0 & 4.1.3)
  bool _hasPriorLoanDefault = false;
  bool _hasActiveScholarship = false;
  bool _hasAcademicMisconduct = false;
  bool _hasCriminalConviction = false;
  bool _holdsFirstDegree = false;

  // Getters
  AcademicEntryType get academicType => _academicType;

  bool get isNigerianCitizen => _isNigerianCitizen;
  bool get isEnrolledInPublicEti => _isEnrolledInPublicEti;
  bool get isAcademicAdmissionVerified => _isAcademicAdmissionVerified;
  bool get isSchoolDataUploaded => _isSchoolDataUploaded;

  bool get hasJambNumber => _hasJambNumber;
  bool get hasBvn => _hasBvn;
  bool get hasNin => _hasNin;
  bool get hasPersonalInfo => _hasPersonalInfo;
  bool get hasPassportPhoto => _hasPassportPhoto;
  bool get hasAdmissionOrStudentId => _hasAdmissionOrStudentId;

  bool get hasPriorLoanDefault => _hasPriorLoanDefault;
  bool get hasActiveScholarship => _hasActiveScholarship;
  bool get hasAcademicMisconduct => _hasAcademicMisconduct;
  bool get hasCriminalConviction => _hasCriminalConviction;
  bool get holdsFirstDegree => _holdsFirstDegree;

  // Setters
  void setAcademicType(AcademicEntryType type) {
    _academicType = type;
    notifyListeners();
  }

  void toggleNigerianCitizen(bool val) {
    _isNigerianCitizen = val;
    notifyListeners();
  }

  void toggleEnrolledInPublicEti(bool val) {
    _isEnrolledInPublicEti = val;
    notifyListeners();
  }

  void toggleAcademicAdmissionVerified(bool val) {
    _isAcademicAdmissionVerified = val;
    notifyListeners();
  }

  void toggleSchoolDataUploaded(bool val) {
    _isSchoolDataUploaded = val;
    notifyListeners();
  }

  void toggleJambNumber(bool val) {
    _hasJambNumber = val;
    notifyListeners();
  }

  void toggleBvn(bool val) {
    _hasBvn = val;
    notifyListeners();
  }

  void toggleNin(bool val) {
    _hasNin = val;
    notifyListeners();
  }

  void togglePersonalInfo(bool val) {
    _hasPersonalInfo = val;
    notifyListeners();
  }

  void togglePassportPhoto(bool val) {
    _hasPassportPhoto = val;
    notifyListeners();
  }

  void toggleAdmissionOrStudentId(bool val) {
    _hasAdmissionOrStudentId = val;
    notifyListeners();
  }

  void togglePriorLoanDefault(bool val) {
    _hasPriorLoanDefault = val;
    notifyListeners();
  }

  void toggleActiveScholarship(bool val) {
    _hasActiveScholarship = val;
    notifyListeners();
  }

  void toggleAcademicMisconduct(bool val) {
    _hasAcademicMisconduct = val;
    notifyListeners();
  }

  void toggleCriminalConviction(bool val) {
    _hasCriminalConviction = val;
    notifyListeners();
  }

  void toggleHoldsFirstDegree(bool val) {
    _holdsFirstDegree = val;
    notifyListeners();
  }

  void reset() {
    _academicType = AcademicEntryType.freshEntry;
    _isNigerianCitizen = false;
    _isEnrolledInPublicEti = false;
    _isAcademicAdmissionVerified = false;
    _isSchoolDataUploaded = false;
    _hasJambNumber = false;
    _hasBvn = false;
    _hasNin = false;
    _hasPersonalInfo = false;
    _hasPassportPhoto = false;
    _hasAdmissionOrStudentId = false;
    _hasPriorLoanDefault = false;
    _hasActiveScholarship = false;
    _hasAcademicMisconduct = false;
    _hasCriminalConviction = false;
    _holdsFirstDegree = false;
    notifyListeners();
  }

  EligibilityReport get report {
    final passed = <String>[];
    final pending = <String>[];
    final disqualifiers = <String>[];

    // Check Core Criteria
    if (_isNigerianCitizen) {
      passed.add('Nigerian Citizenship confirmed (NIN & BVN)');
    } else {
      pending.add('Proof of Nigerian citizenship via NIN & BVN is required (Sec. 2.1).');
    }

    if (_isEnrolledInPublicEti) {
      passed.add('Admitted to an approved Public Tertiary Institution (Sec. 2.2)');
    } else {
      pending.add('Only approved Federal and State public tertiary institutions qualify.');
    }

    if (_isAcademicAdmissionVerified) {
      passed.add(_academicType.academicRequirementLabel);
    } else {
      pending.add('Valid admission verification or matriculation required.');
    }

    if (_isSchoolDataUploaded) {
      passed.add('School uploaded data to Student Verification System (SVS)');
    } else {
      pending.add('Your institution must upload your academic data to NELFUND SVS.');
    }

    // Check Disqualifications
    if (_hasPriorLoanDefault) {
      disqualifiers.add(
        'Prior loan default: Defaulted in respect of any previous education loan granted by the FG, state government, or their agencies (Sec. 3.1).',
      );
    }
    if (_hasActiveScholarship) {
      disqualifiers.add(
        'Concurrent aid: Currently a beneficiary of another education loan or government scholarship scheme (Sec. 3.1).',
      );
    }
    if (_hasAcademicMisconduct) {
      disqualifiers.add(
        'Disciplinary sanction: Found culpable of exam malpractice, plagiarism, cultism, violence, or submitting forged documents (Sec. 3.1).',
      );
    }
    if (_hasCriminalConviction) {
      disqualifiers.add(
        'Criminal record: Convicted of fraud, forgery, drug offenses, felony, or dishonesty (Sec. 3.1).',
      );
    }
    if (_holdsFirstDegree) {
      disqualifiers.add(
        'Prior degree: Already a holder of a first degree or foreign equivalent (Sec. 4.1.3 Attestation).',
      );
    }

    // Check KYC Readiness
    int kycCount = 0;
    if (_hasJambNumber) kycCount++;
    if (_hasBvn) kycCount++;
    if (_hasNin) kycCount++;
    if (_hasPersonalInfo) kycCount++;
    if (_hasPassportPhoto) kycCount++;
    if (_hasAdmissionOrStudentId) kycCount++;

    final bool isDisqualified = disqualifiers.isNotEmpty;
    final bool hasCoreCriteria = pending.isEmpty;
    final bool isEligible = !isDisqualified && hasCoreCriteria;

    String title;
    String message;

    if (isDisqualified) {
      title = 'May Be Disqualified Under NELFUND Rules';
      message =
          'You flagged ${disqualifiers.length} statutory disqualification factor(s). Under Section 3.0 of the 2024 Guidelines, applicants with these conditions cannot access the Fund.';
    } else if (!hasCoreCriteria) {
      title = 'Action Required on Basic Requirements';
      message =
          'You meet no disqualification bars, but have ${pending.length} pending prerequisite(s) before you can submit an application.';
    } else {
      title = 'Likely Eligible for NELFUND Loan';
      message =
          'You satisfy all statutory criteria under the 2024 Act and have flagged zero disqualification factors. Your KYC document readiness is $kycCount/6 items.';
    }

    return EligibilityReport(
      isLikelyEligible: isEligible,
      passedCriteria: passed,
      pendingRequirements: pending,
      disqualificationReasons: disqualifiers,
      summaryTitle: title,
      summaryMessage: message,
    );
  }
}
