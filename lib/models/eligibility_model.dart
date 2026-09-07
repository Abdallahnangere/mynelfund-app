/// Academic Entry Streams recognized under Section 2.2 of NELFUND Guidelines.
enum AcademicEntryType {
  freshEntry,
  directEntry,
  undergraduate,
}

extension AcademicEntryTypeExtension on AcademicEntryType {
  String get title {
    switch (this) {
      case AcademicEntryType.freshEntry:
        return 'Fresh Entry';
      case AcademicEntryType.directEntry:
        return 'Direct Entry';
      case AcademicEntryType.undergraduate:
        return 'Undergraduate';
    }
  }

  String get description {
    switch (this) {
      case AcademicEntryType.freshEntry:
        return 'Prospective 100-level student with valid admission via JAMB.';
      case AcademicEntryType.directEntry:
        return 'Secured valid 200-level direct entry admission via JAMB.';
      case AcademicEntryType.undergraduate:
        return 'Currently enrolled full-time student with official matriculation number.';
    }
  }

  String get academicRequirementLabel {
    switch (this) {
      case AcademicEntryType.freshEntry:
      case AcademicEntryType.directEntry:
        return 'Valid JAMB Admission Letter to an Eligible Tertiary Institution (ETI)';
      case AcademicEntryType.undergraduate:
        return 'Official Matriculation Number & verified full-time studentship at an ETI';
    }
  }
}

/// Structured diagnostic report generated from the eligibility evaluation across all 3 sections.
class EligibilityReport {
  final bool isLikelyEligible;
  final String summaryTitle;
  final String summaryMessage;

  // Section 1: Statutory Core Criteria
  final int coreMetCount;
  final int coreTotalCount;
  final List<String> passedCoreCriteria;
  final List<String> pendingCoreCriteria;

  // Section 2: KYC & Identity Verification
  final int kycMetCount;
  final int kycTotalCount;
  final List<String> passedKycItems;
  final List<String> pendingKycItems;

  // Section 3: Statutory Disqualification Bars
  final int disqualifierCount;
  final List<String> activeDisqualifiers;

  // Backward-compatibility aliases
  List<String> get passedCriteria => passedCoreCriteria;
  List<String> get pendingRequirements => pendingCoreCriteria;
  List<String> get disqualificationReasons => activeDisqualifiers;

  bool get hasDisqualifiers => disqualifierCount > 0;
  bool get hasPendingCore => pendingCoreCriteria.isNotEmpty;
  bool get hasPendingKyc => pendingKycItems.isNotEmpty;
  bool get isFullySatisfied =>
      !hasDisqualifiers && !hasPendingCore && !hasPendingKyc;

  const EligibilityReport({
    required this.isLikelyEligible,
    required this.summaryTitle,
    required this.summaryMessage,
    required this.coreMetCount,
    required this.coreTotalCount,
    required this.passedCoreCriteria,
    required this.pendingCoreCriteria,
    required this.kycMetCount,
    required this.kycTotalCount,
    required this.passedKycItems,
    required this.pendingKycItems,
    required this.disqualifierCount,
    required this.activeDisqualifiers,
  });
}
