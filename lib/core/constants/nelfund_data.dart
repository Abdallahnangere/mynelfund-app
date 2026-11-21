import '../localization/app_locale.dart';

/// Authoritative Data & Constants sourced from the Students Loans Act 2024
/// and the official Guidelines for the Administration of NELFUND Student Loan.
class NelfundData {
  NelfundData._();

  // App Identity
  static const String appName = 'My NELFund';
  static const String appTagline =
      'Independent Student Loan Guide & Repayment Calculator';
  static const String officialPortalUrl = 'https://nelf.gov.ng';

  static String getAppTagline(AppLanguage lang) {
    return lang == AppLanguage.hausa
        ? 'Manhaja domin Taimaka wa Dalibai Fahimtar Bashin NELFUND da kuma Biyanshi'
        : appTagline;
  }

  // Statutory Parameters
  static const double interestRate = 0.0; // 0% Interest-free
  static const double monthlyUpkeepStipend = 20000.0; // ₦20,000/month
  static const double repaymentRatePercent = 10.0; // 10% statutory deduction
  static const int postNyscMoratoriumYears = 2; // 2 years after NYSC
  static const int selfEmployedDisclosureDays =
      60; // 60 days to report business
  static const int jobChangeDisclosureDays =
      30; // 30 days to report new employer

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
  static const String currentBatchName =
      'Phase 1 - Public Tertiary Institutions';
  static const bool isWindowOpen = true;
  static const String windowStatusText = 'Portal Currently Open';
  static const String windowAdvisory =
      'Applications are actively received on nelf.gov.ng. Verify that your institution has uploaded your profile to the Student Verification System (SVS).';

  static String getWindowStatusText(AppLanguage lang) {
    return lang == AppLanguage.hausa
        ? 'Shafin Cika Bashi Yana Bude a Yanzu'
        : windowStatusText;
  }

  static String getWindowAdvisory(AppLanguage lang) {
    return lang == AppLanguage.hausa
        ? 'Ana cika bashin dalibai a halin yanzu a shafin yanar gizo na nelf.gov.ng. Tabbatar cewa makarantarku ta loda bayananku a Tsarin Tabbatar da Dalibai (SVS).'
        : windowAdvisory;
  }

  // 3 Core Pillars
  static const List<Map<String, String>> corePillars = [
    {
      'title': '0% Zero Interest',
      'subtitle':
          'No compounding fees or interest accumulation. You only repay the exact principal amount disbursed.',
      'icon': 'percent',
      'highlight': '100% Interest-Free',
    },
    {
      'title': 'Direct Tuition Disbursement',
      'subtitle':
          'Institutional fees are paid electronically and directly to your tertiary institution upon verification.',
      'icon': 'school',
      'highlight': '100% Institutional',
    },
    {
      'title': '₦20,000 Monthly Upkeep',
      'subtitle':
          'Optional living stipend paid monthly directly into your personal bank account to support study costs.',
      'icon': 'wallet',
      'highlight': 'Direct to Student',
    },
  ];

  static List<Map<String, String>> getCorePillars(AppLanguage lang) {
    if (lang == AppLanguage.hausa) {
      return const [
        {
          'title': '0% Babu Kudin Ruwa',
          'subtitle':
              'Babu karin kudin ruwa ko boyayyun caje-caje. Adadin ainihin kudin da aka biya ma makaranta ko aka ba ka shi kadai za ka biya.',
          'icon': 'percent',
          'highlight': '0% Ba Kudin Ruwa',
        },
        {
          'title': 'Biyan Kudin Makaranta Kai-tsaye',
          'subtitle':
              'Ana tura kudaden makaranta 100% kai-tsaye ta hanyar na\'ura zuwa asusun babban bankin makarantarku bayan an tantance ka.',
          'icon': 'school',
          'highlight': '100% An Biya',
        },
        {
          'title': '₦20,000 Tallafin Rayuwa a Wata',
          'subtitle':
              'Tallafin alawus na rayuwa na kowanne wata da ake sawa kai-tsaye a asusun bankinka na kashin kai domin saukaka hidimar karatu.',
          'icon': 'wallet',
          'highlight': '₦20k a Wata',
        },
      ];
    }
    return corePillars;
  }

  // Legal & Act Overview
  static const String actTitle =
      'Students Loans (Access to Higher Education) Act, 2024';
  static const String actSummary =
      'Signed into law by President Bola Ahmed Tinubu, the Act establishes the Nigerian Education Loan Fund (NELFUND) as a body corporate to provide zero-interest loans for tuition and upkeep to eligible Nigerian students in public tertiary institutions.';

  static String getActTitle(AppLanguage lang) {
    return lang == AppLanguage.hausa
        ? 'Dokar Bashin Dalibai domin Samar da Ilimi Mai Zurfi ta Shekarar 2024'
        : actTitle;
  }

  static String getActSummary(AppLanguage lang) {
    return lang == AppLanguage.hausa
        ? 'Shugaba Bola Ahmed Tinubu ya sanya wa dokar hannu, wadda ta kafa Asusun Lamunin Ilimi na Najeriya (NELFUND) a matsayin hukuma mai cin gashin kanta domin samar da bashi marar kudin ruwa don biyan kudin makaranta da tallafin rayuwa na wata-wata ga daliban Najeriya da suka cancanta a manyan makarantun gwamnati na gaba da sakandire.'
        : actSummary;
  }

  static const String independentDisclaimer =
      'Disclaimer: My NELFund is an independent educational guide and utility created to help Nigerian students understand their rights, eligibility, and repayment obligations under the 2024 Act. It is not affiliated with or endorsed by the Federal Government of Nigeria or NELFUND.';

  static String getIndependentDisclaimer(AppLanguage lang) {
    return lang == AppLanguage.hausa
        ? 'Wanke Kai: My NELFund wani jagora ne mai zaman kansa da aka samar domin taimaka wa daliban Najeriya su fahimci hakkokinsu, cancanta, da ka\'idojin biyan bashi karkashin Dokar 2024. Ba shi da wata alaka ta hukuma da Gwamnatin Tarayyar Najeriya ko NELFUND.'
        : independentDisclaimer;
  }
}
