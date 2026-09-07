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
    // -----------------------------------------------------------
    // SECTION 1: Statutory Core Criteria (Section 2.0)
    // -----------------------------------------------------------
    final passedCore = <String>[];
    final pendingCore = <String>[];

    if (_isNigerianCitizen) {
      passedCore.add('Nigerian Citizenship confirmed via NIN & BVN (Sec. 2.1)');
    } else {
      pendingCore.add('Nigerian citizenship verification via NIN & BVN is required.');
    }

    if (_isEnrolledInPublicEti) {
      passedCore.add('Enrolled in an approved Federal or State public tertiary institution (Sec. 2.2)');
    } else {
      pendingCore.add('Enrollment in an approved Federal or State public tertiary institution is required.');
    }

    if (_isAcademicAdmissionVerified) {
      passedCore.add(_academicType.academicRequirementLabel);
    } else {
      pendingCore.add('Valid academic admission letter or official matriculation number required.');
    }

    if (_isSchoolDataUploaded) {
      passedCore.add('Institution uploaded student roster to Student Verification System (SVS)');
    } else {
      pendingCore.add('Your institution must upload your student data to the NELFUND SVS portal.');
    }

    // -----------------------------------------------------------
    // SECTION 2: KYC & Identity Verification Readiness (Section 2.3)
    // -----------------------------------------------------------
    final passedKyc = <String>[];
    final pendingKyc = <String>[];

    if (_hasJambNumber) {
      passedKyc.add('JAMB Registration Number ready');
    } else {
      pendingKyc.add('JAMB Registration Number');
    }

    if (_hasBvn) {
      passedKyc.add('Bank Verification Number (BVN) ready');
    } else {
      pendingKyc.add('Bank Verification Number (BVN)');
    }

    if (_hasNin) {
      passedKyc.add('National Identity Number (NIN) ready');
    } else {
      pendingKyc.add('National Identity Number (NIN)');
    }

    if (_hasPersonalInfo) {
      passedKyc.add('Complete Personal Bio-data ready');
    } else {
      pendingKyc.add('Personal Bio-data (Date of Birth, State, LGA)');
    }

    if (_hasPassportPhoto) {
      passedKyc.add('Digital Passport Photograph ready');
    } else {
      pendingKyc.add('Digital Passport Photograph (white background)');
    }

    if (_hasAdmissionOrStudentId) {
      passedKyc.add('Admission Letter or Student ID card ready');
    } else {
      pendingKyc.add('Official Admission Letter or Institution ID Card');
    }

    // -----------------------------------------------------------
    // SECTION 3: Statutory Disqualification Bars (Section 3.0 & 4.1.3)
    // -----------------------------------------------------------
    final disqualifiers = <String>[];

    if (_hasPriorLoanDefault) {
      disqualifiers.add(
        'Prior loan default: Defaulted in respect of any previous education loan granted by the FG, state government, or their agencies (Sec. 3.1).',
      );
    }
    if (_hasActiveScholarship) {
      disqualifiers.add(
        'Concurrent Aid: Currently receiving another Federal/State education loan or scholarship (Sec. 3.1).',
      );
    }
    if (_hasAcademicMisconduct) {
      disqualifiers.add(
        'Institutional Misconduct: Sanctioned for examination malpractice, cultism, violence, or forged documents (Sec. 3.1).',
      );
    }
    if (_hasCriminalConviction) {
      disqualifiers.add(
        'Criminal Conviction: Convicted of fraud, forgery, drug offenses, felony, or dishonesty (Sec. 3.1).',
      );
    }
    if (_holdsFirstDegree) {
      disqualifiers.add(
        'Prior Degree Bar: Already a holder of a first degree or foreign equivalent (Sec. 4.1.3 Attestation).',
      );
    }

    // High-Level Diagnostics
    final bool isDisqualified = disqualifiers.isNotEmpty;
    final bool hasAllCore = pendingCore.isEmpty;
    final bool isEligible = !isDisqualified && hasAllCore;

    String title;
    String message;

    if (isDisqualified) {
      title = 'Statutory Disqualification Bar(s) Active';
      message =
          'You flagged ${disqualifiers.length} statutory disqualification bar(s). Under Section 3.0 of the Students Loans Act 2024, applicants with these conditions are legally barred from the Fund.';
    } else if (!hasAllCore) {
      title = 'Incomplete Core Criteria — Action Required';
      message =
          'You have 0 disqualification bars, but ${pendingCore.length} statutory prerequisite(s) remain pending in Section 1 before you can apply.';
    } else if (pendingKyc.isNotEmpty) {
      title = 'Likely Eligible • KYC Documents Pending';
      message =
          'You meet all statutory core criteria with 0 disqualifications! However, you still need to prepare ${pendingKyc.length} required KYC document(s) before portal submission.';
    } else {
      title = 'Statutory Clearance: Likely Eligible';
      message =
          'Congratulations! You satisfy all core statutory criteria, have prepared all 6 KYC documents, and carry 0 disqualification bars under the 2024 Act.';
    }

    return EligibilityReport(
      isLikelyEligible: isEligible,
      summaryTitle: title,
      summaryMessage: message,
      coreMetCount: passedCore.length,
      coreTotalCount: 4,
      passedCoreCriteria: passedCore,
      pendingCoreCriteria: pendingCore,
      kycMetCount: passedKyc.length,
      kycTotalCount: 6,
      passedKycItems: passedKyc,
      pendingKycItems: pendingKyc,
      disqualifierCount: disqualifiers.length,
      activeDisqualifiers: disqualifiers,
    );
  }
}
