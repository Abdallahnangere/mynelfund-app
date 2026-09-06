/// Authoritative Data & Constants sourced from the Students Loans Act 2024
/// and the official Guidelines for the Administration of NELFUND Student Loan.
class NelfundData {
  NelfundData._();

  // App Identity
  static const String appName = 'My NELFund';
  static const String appTagline =
      'Independent Student Loan Guide & Repayment Calculator';
  static const String officialPortalUrl = 'https://nelf.gov.ng';

  // Statutory Parameters
  static const double interestRate = 0.0; // 0% Interest-free
  static const double monthlyUpkeepStipend = 20000.0; // ₦20,000/month
  static const double repaymentRatePercent = 10.0; // 10% statutory deduction
  static const int postNyscMoratoriumYears = 2; // 2 years after NYSC
  static const int selfEmployedDisclosureDays = 60; // 60 days to report business
  static const int jobChangeDisclosureDays = 30; // 30 days to report new employer

  // Official Service Level Agreement (SLA) Turnaround Times (from nelfund.pdf)
  static const int slaInstitutionVerificationDays = 20; // Working days
  static const int slaEvaluationCalendarDays = 15; // Calendar days
  static const int slaApprovalWorkingDays = 10; // Working days
  static const int slaDisbursementWorkingDays = 10; // Working days
  static const int slaEtiReceiptWorkingDays = 7; // Working days
  static const int slaRefundCalendarDays = 30; // Calendar days
  static const int slaTsaNotificationDays = 10; // Working days
  static const int slaNonTsaNotificationDays = 5; // Working days

  // Application Window (Configurable Standalone State)
  static const String currentAcademicSession = '2024/2025';
  static const String currentBatchName = 'Phase 1 - Public Tertiary Institutions';
  static const bool isWindowOpen = true;
  static const String windowStatusText = 'Portal Currently Open';
  static const String windowAdvisory =
      'Applications are actively received on nelf.gov.ng. Verify that your institution has uploaded your profile to the Student Verification System (SVS).';

  // 3 Core Pillars
  static const List<Map<String, String>> corePillars = [
    {
      'title': '0% Interest Rate',
      'subtitle': 'Zero compounding or hidden interest. Repay only what was disbursed.',
      'icon': 'percent',
      'highlight': '0% APR',
    },
    {
      'title': 'Direct Institutional Fees',
      'subtitle': '100% of approved tuition & institutional charges paid electronically straight to your school.',
      'icon': 'school',
      'highlight': '100% Covered',
    },
    {
      'title': '₦20,000 Monthly Upkeep',
      'subtitle': 'Optional living stipend deposited directly into your verified bank account monthly.',
      'icon': 'wallet',
      'highlight': '₦20k / Month',
    },
  ];

  // Legal & Act Overview
  static const String actTitle =
      'Students Loans (Access to Higher Education) Act, 2024';
  static const String actSummary =
      'Signed into law by President Bola Ahmed Tinubu, the Act establishes the Nigerian Education Loan Fund (NELFUND) as a body corporate to provide zero-interest loans for tuition and upkeep to eligible Nigerian students in public tertiary institutions.';

  static const String independentDisclaimer =
      'Disclaimer: My NELFund is an independent educational guide and utility created to help Nigerian students understand their rights, eligibility, and repayment obligations under the 2024 Act. It is not affiliated with or endorsed by the Federal Government of Nigeria or NELFUND.';
}
