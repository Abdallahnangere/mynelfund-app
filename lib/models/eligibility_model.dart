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

/// Structured diagnostic report generated from the eligibility evaluation.
class EligibilityReport {
  final bool isLikelyEligible;
  final List<String> passedCriteria;
  final List<String> pendingRequirements;
  final List<String> disqualificationReasons;
  final String summaryTitle;
  final String summaryMessage;

  const EligibilityReport({
    required this.isLikelyEligible,
    required this.passedCriteria,
    required this.pendingRequirements,
    required this.disqualificationReasons,
    required this.summaryTitle,
    required this.summaryMessage,
  });
}
