import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'app_locale.dart';
import 'locale_provider.dart';

class AppTranslations {
  final AppLanguage language;

  const AppTranslations(this.language);

  static AppTranslations of(BuildContext context) {
    try {
      final provider = Provider.of<LocaleProvider?>(context, listen: true);
      if (provider != null) {
        return AppTranslations(provider.currentLanguage);
      }
    } catch (_) {}
    return const AppTranslations(AppLanguage.english);
  }

  static AppTranslations from(AppLanguage language) {
    return AppTranslations(language);
  }

  bool get isHausa => language == AppLanguage.hausa;

  // ----------------------------------------------------
  // Navigation & Bottom Bar Tabs
  // ----------------------------------------------------
  String get tabHome => isHausa ? 'Gida' : 'Home';
  String get tabEligibility => isHausa ? 'Cancanta' : 'Eligibility';
  String get tabCalculator => isHausa ? 'Lissafa Bashi' : 'Calculator';
  String get tabFaq => isHausa ? 'Tambayoyi' : 'FAQ';
  String get tabAbout => isHausa ? 'Game da Mu' : 'About';

  String get appTitle => 'My NELFund';
  String get appSubtitle =>
      isHausa ? 'Fahimtar Bashin Karatu na Dalibai.' : 'Student Loan Guide';

  String get backToExitToast => isHausa
      ? 'Ka sake danna madannin baya domin fita'
      : 'Press back again to exit';

  String get buttonDone => isHausa ? 'An Kammala' : 'Done';
  String get buttonReset => isHausa ? 'Sake Farawa' : 'Reset';
  String get buttonOk => isHausa ? 'Toh' : 'OK';
  String get buttonCopy => isHausa ? 'Kwafi' : 'Copy';
  String get buttonCallNow => isHausa ? 'Kira Yanzu' : 'Call Now';
  String get buttonOpenPortal =>
      isHausa ? 'Bude Shafin Hukumar NELFUND' : 'Open Portal';
  String get buttonSendEmail => isHausa ? 'Aika Imel' : 'Send Email';
  String get buttonCheckUpdate => isHausa ? 'Duba Sabuntawa' : 'Check Update';
  String get buttonRateApp => isHausa ? 'Bada Tauraro' : 'Rate on Store';
  String get buttonAddLoanYear =>
      isHausa ? 'Kara Bashin Wata Shekara' : 'Add Loan Year';
  String get buttonUpdateLoan =>
      isHausa ? 'Sabunta Bayanan Bashi' : 'Update Loan';
  String get buttonAddToWallet =>
      isHausa ? 'Saka a Asusun Bashi' : 'Add to Wallet';

  // ----------------------------------------------------
  // Home Screen
  // ----------------------------------------------------
  String get officialBulletinsTitle =>
      isHausa ? 'Sanarwar Hukuma' : 'Official Bulletins';
  String get notificationsViewTitle =>
      isHausa ? 'Sanarwar Hukuma' : 'Official Bulletins';
  String get notificationsSubtitle =>
      isHausa ? 'Bayanai da Sabbin Sanarwa' : 'Real-time Bulletins & Updates';
  String get notificationsEmptyTitle =>
      isHausa ? 'Babu Sabuwar Sanarwa' : 'No Notifications Yet';
  String get notificationsEmptyDesc => isHausa
      ? 'Dukkan sabbin sanarwar hukuma, bayanan shigar kudi da bude fom zasu bayyana a nan da zaran an turo su.'
      : 'Official announcements, disbursement alerts, and portal updates will appear here in real time.';
  String get markAllReadLabel => isHausa ? 'Karanta Duka' : 'Mark all read';
  String get clearNotificationsLabel => isHausa ? 'Goge' : 'Clear';
  String get searchNotificationsPlaceholder =>
      isHausa ? 'Nemo a cikin sanarwa...' : 'Search bulletins & alerts...';
  String get programOverviewTitle =>
      isHausa ? 'Bayanin Shirin Bashi' : 'Program Overview';
  String get keyLoanPillarsTitle =>
      isHausa ? 'Muhimman Rukunnan Bashi' : 'Key Loan Pillars';
  String get exploreToolsTitle =>
      isHausa ? 'Duba Cancanta da Gwajin Biya' : 'Explore Tools & Guides';

  // Quick Access Cards
  String get cardEligibilityTitle =>
      isHausa ? 'Cancanta' : 'Eligibility Checker';
  String get cardEligibilityDesc => isHausa
      ? 'Abubuwan da ake bukata da wadanda za su iya sa a rasa bashi'
      : 'Interactive checklist & disqualification audit';

  String get cardCalcTitle =>
      isHausa ? 'Lissafa Biyan Bashi' : 'Repayment Calc';
  String get cardCalcDesc => isHausa
      ? 'Biyan kashi 10% daga albashi, shekaru 2 bayan NYSC'
      : '10% PAYE/IBR & 2-year NYSC countdown';

  String get cardFaqTitle =>
      isHausa ? 'Tambayoyi Masu Muhimmanci' : 'Official FAQ';
  String get cardFaqDesc => isHausa
      ? 'Dokokin mayar da kudi, amsoshin tambayoyi da shari\'a'
      : 'Institutional refund rules, FAQs & recovery';

  String get cardAboutTitle =>
      isHausa ? 'Game da Mu & Tuntuba' : 'About & Support';
  String get cardAboutDesc => isHausa
      ? 'Lambar waya, shafin kamfani da kuma na hukuma'
      : 'Developer contact, awareness guide & channels';

  // Act Overview Card
  String get primaryLegalProvisionsTitle =>
      isHausa ? 'Sharuddan Doka Masu Muhimmanci:' : 'Primary Legal Provisions:';

  String get provisionRepealedAct => isHausa
      ? 'Ta soke Dokar Lamuni ta 2023 domin cire shingen yawan kudin shigar iyaye.'
      : 'Repealed the 2023 Student Loan Act to remove family income barriers.';

  String get provisionNoGuarantor => isHausa
      ? 'Babu bukatar mai tsaya wa mutum ko jinginar wata kadara ga daliban makarantun gwamnati.'
      : 'No guarantor or collateral requirement for eligible public students.';

  String get provisionTwoYearGrace => isHausa
      ? 'Dole ne a bayar da sassaucin shekaru 2 bayan kammala NYSC kafin a fara karbar kudin bashi.'
      : 'Mandatory 2-year post-NYSC grace period before loan recovery begins.';

  String get provisionUnemploymentForgiveness => isHausa
      ? 'Hukunce-hukuncen sassauci da tsaida biya ga duk wanda bincike ya tabbatar bai sami aiki ba tukuna.'
      : 'Forgiveness / extension provisions for beneficiaries facing documented unemployment.';

  // ----------------------------------------------------
  // Repayment Calculator Screen
  // ----------------------------------------------------
  String get calcHeaderTitle =>
      isHausa ? 'Lissafa Bashi' : 'Payment Calculator';
  String get calcTipBannerText => isHausa
      ? 'Danna kasa domin saka adadin bashinka na kowacce shekara tare da saka albashi ko kudin shigar da kake sa ran samu bayan kammala karatu domin ganin adadin da za a rinka cirewa duk wata na tsawon lokacin biya.'
      : 'Tap below to add your loans and select your expected income after graduation to simulate your monthly deduction and repayment timeline.';

  String get walletBadge =>
      isHausa ? 'ASUSUN LAMUNIN NELFUND' : 'NELFUND WALLET';
  String get totalPortfolioLabel =>
      isHausa ? 'JUMULLAR KUDIN BASHIN DA AKE BINKA' : 'TOTAL LOAN PORTFOLIO';
  String get statutoryMonthlyDeductionLabel => isHausa
      ? 'ADADIN ABUNDA ZA A RINKA CIREWA DUK WATA DAGA ALBASHINKA'
      : 'STATUTORY MONTHLY DEDUCTION';

  String get statutoryRateLabel => isHausa
      ? 'Kashi 10% na Albashi wanda Doka ta Tanada ba za a Cire Sama da Shi ba'
      : '10% Statutory Rate';

  String get expectedPayoffTimeLabel => isHausa
      ? 'TSAWON LOKACIN DA ZA KA GAMA BIYA GABA DAYA'
      : 'EXPECTED PAYOFF TIME';

  String get zeroInterestTag =>
      isHausa ? '0% Babu Kudin Ruwa ko Kobo' : '0% Zero Interest';

  String get configuredSessionsTitle =>
      isHausa ? 'Zangon Karatun da Aka Saka' : 'Configured Academic Sessions';
  String get tapToEdit => isHausa ? 'Danna domin gyarawa' : 'Tap to edit';
  String get noSessionsAdded => isHausa
      ? 'Ba a saka kudaden wata shekarar karatu ba tukuna. Latsa "Kara Bashin Wata Shekara" a katin da ke sama domin saka bayananka.'
      : 'No academic session loans added. Tap "Add Loan Year" on the wallet card above to onboard your loans.';

  String get nyscGraduationYearLabel =>
      isHausa ? 'Shekarar Kammala NYSC:' : 'NYSC Graduation Year:';
  String get twoYearGraceActivePrefix => isHausa
      ? 'Sassaucin Shekaru 2 Bayan Aiki: Za a fara biya a '
      : '2-Year Grace Active: Repayment starts ';

  String get repaymentStreamTitle =>
      isHausa ? 'Hanyar Biyan Bashi:' : 'Repayment Stream:';
  String get expectedMonthlyIncomeLabel => isHausa
      ? 'Kudin Shigar da Ake Sa Ran Samu a Wata (₦):'
      : 'Expected Monthly Income (₦):';

  String get expectedSalaryDesc => isHausa
      ? 'Shigar da albashin da kake sa ran samu idan ka sami aikin yi.'
      : 'Enter the expected salary that you will earn if you get employed.';

  String get minimumWageChip => isHausa
      ? '₦70,000.00 (Mafi Karancin Albashi)'
      : '₦70,000.00 (Minimum Wage)';

  String get postNyscGraceCardTitle => isHausa
      ? 'Sassaucin Shekaru 2 Bayan NYSC'
      : '2-Year Post-NYSC Grace Period';

  String get postNyscGraceCardDesc => isHausa
      ? 'Karkashin Sashe na 5.0 na Dokar Lamunin Dalibai ta 2024, duk mai karbar bashi yana da sassaucin watanni 24 ba tare da kudin ruwa ba bayan kammala hidimar kasa:'
      : 'Under Section 5.0 of the Students Loans Act 2024, beneficiaries enjoy an automatic 24-month interest-free moratorium after completing national service:';

  String get popTimelineLabel => isHausa
      ? 'Ranar Kammala Faretin Fita ta NYSC (POP)'
      : 'NYSC Passing Out Parade (POP)';

  String get graceTimelineLabel => isHausa
      ? 'Ba za a cire ko kobo ba na biyan bashi a wadannan shekarun'
      : '24-Month Statutory Grace Period (0 Deductions)';

  String get repaymentTimelineLabel => isHausa
      ? 'Fara Biyan Bashi na Doka Bayan Shekaru 2'
      : 'Mandatory Repayment Begins';

  String get unemploymentProtectionTitle => isHausa
      ? 'Kariyar Rashin Aikin Yi (Sashe na 5.1c)'
      : 'Unemployment Protection (Sec. 5.1c)';

  String get unemploymentProtectionDesc => isHausa
      ? 'Idan har yanzu ba ka sami aikin yi ba bayan cikar wa\'adin shekaru 2 na sassauci, doka ta kare ka. Mika takardar rantsuwa ta rashin aikin yi zai sa a dakatar da biyan bashi ba tare da tara ko kudin ruwa ba har sai ka sami aiki.'
      : 'If you are not yet gainfully employed at the end of your 2-year grace period, you are legally protected. Submitting a periodic statutory declaration or sworn affidavit pauses deductions until you secure employment.';

  String get complianceGuideTitle => isHausa
      ? 'Tallafin Biyan Bashi & Ka\'idojin Doka'
      : 'Repayment Support & Compliance Guidelines';

  String get complianceGuideDesc => isHausa
      ? 'Dokar Lamunin Dalibai ta 2024 an gina ta ne domin kare muradun dalibai. Ga yadda tsarin kariyar yake aiki:'
      : 'The Students Loans Act 2024 is built with student safeguards first. Here is how statutory compliance and protections work:';

  // Calculator Modal
  String get editLoanYearTitle =>
      isHausa ? 'Gyara Bashin Shekarar Karatu' : 'Edit Academic Year Loan';
  String get addLoanYearTitle =>
      isHausa ? 'Kara Bashin Wata Shekara' : 'Add Academic Year Loan';
  String get selectLevelLabel =>
      isHausa ? 'Zabi Ajin Karatu:' : 'Select Academic Level:';
  String get institutionalFeeLabel => isHausa
      ? 'Kudin Makaranta Kai-tsaye (₦):'
      : 'Institutional / Tuition Fee (₦):';
  String get enterFeeDesc => isHausa
      ? 'Shigar da adadin kudin makarantar da kake bukata a wannan shekarar'
      : 'Enter the institutional fee loan amount of this year';

  String get includeUpkeepLabel =>
      isHausa ? 'Saka Alawus na Tallafin Rayuwa' : 'Include Upkeep Allowance';
  String get upkeepAutoCalculated => isHausa
      ? '₦20,000 a kowane wata da aka karɓa'
      : '₦20,000 per collected month';

  String get selectUpkeepMonthsTitle =>
      isHausa ? 'Zaɓi Watannin Alawus' : 'Select Disbursed Upkeep Months';
  String get selectUpkeepMonthsDesc => isHausa
      ? 'Danna watannin da ka karɓi tallafin rayuwa (₦20,000 a wata):'
      : 'Select the specific months you received upkeep allowance (₦20,000/month):';
  String get quickSelectAll12 => isHausa ? 'Duka 12' : 'All 12';
  String get quickSelectSem1 => isHausa ? 'Zangon 1 (W1-6)' : 'Sem 1 (M1-6)';
  String get quickSelectSem2 => isHausa ? 'Zangon 2 (W7-12)' : 'Sem 2 (M7-12)';
  String get quickClear => isHausa ? 'Share' : 'Clear';
  String get noMonthsSelected =>
      isHausa ? 'Ba a zaɓi wata ba (₦0.00)' : 'No months selected (₦0.00)';

  String upkeepSelectedSummary(int count, String total) => isHausa
      ? 'Watanni $count da aka zaɓa × ₦20,000 = $total'
      : '$count Months Selected × ₦20,000 = $total';

  // Voluntary Repayment Translations
  String get voluntaryRepaymentTitle => isHausa
      ? 'Tsarin Biyan Bashi na Son Rai'
      : 'Voluntary Repayment Configurator';
  String get voluntaryRepaymentDesc => isHausa
      ? 'Dokar NELFUND ta kayyade mafi karancin kason 10%. Zaka iya zabar biyan karin kudi domin biya cikin gajeren lokaci.'
      : 'NELFUND mandates 10% statutory deduction. You can voluntarily pay more to clear your loan faster and become debt-free earlier.';
  String get statutoryBaselineLabel =>
      isHausa ? 'Kason Doka (10%):' : 'Statutory Minimum (10%):';
  String get voluntaryCustomAmountLabel => isHausa
      ? 'Adadin da Kake Son Biya a Wata (₦):'
      : 'Custom Monthly Remittance (₦):';
  String get voluntaryCustomPlaceholder =>
      isHausa ? 'misali: 20,000' : 'e.g. 20,000';
  String debtFreeEarlierBadge(String timeSaved) => isHausa
      ? '⚡ Za ka gama biya kafin wa\'adi da $timeSaved!'
      : '⚡ Debt-free $timeSaved earlier!';

  // Calculator Guide Modal
  String get calcGuideTitle =>
      isHausa ? 'Jagorar Na\'urar Lissafi' : 'Loan & Repayment Guide';
  String get calcGuideIntro => isHausa
      ? 'Koyi yadda ake tsara bashin makaranta da alawus, wa\'adin NYSC, da biyan bashi na doka da na son rai:'
      : 'Learn how to configure your academic session loans, upkeep allowance, NYSC grace period, and repayments:';
  String get calcGuideStep1Title => isHausa
      ? '1. Saka Bashin Shekarun Karatu & Alawus'
      : '1. Add Academic Loans & Upkeep';
  String get calcGuideStep1Desc => isHausa
      ? 'Saka kudin makarantarka na kowace shekara. Idan ka karbi alawus na tallafin rayuwa (₦20,000/wata), zabi ainihin watannin da aka biya ka a kalanda.'
      : 'Enter your institutional tuition fee. If you received upkeep allowance (₦20,000/month), tap the exact months you collected in the calendar.';
  String get calcGuideStep2Title => isHausa
      ? '2. Wa\'adin Sassauci na NYSC (Shekaru 2)'
      : '2. NYSC 2-Year Grace Period';
  String get calcGuideStep2Desc => isHausa
      ? 'Dokar Lamunin Dalibai ta 2024 ta ba ka cikakkun shekaru 2 bayan kammala NYSC ba tare da rage ko sisin kobo ba daga kudin shigarka.'
      : 'The Students Loans Act 2024 grants 2 full years post-NYSC moratorium with zero deductions to help you stabilize.';
  String get calcGuideStep3Title => isHausa
      ? '3. Kason Doka 10% & Biyan Son Rai'
      : '3. 10% Statutory & Voluntary Repayment';
  String get calcGuideStep3Desc => isHausa
      ? 'Kason doka shine 10% na albashi ko ribar kasuwanci. Zaka iya zabar biyan karin kudi na son rai domin gama biyan bashin da wuri.'
      : '10% of monthly income is deducted at source. You can voluntarily configure a higher remittance to clear debt faster.';
  String get calcGuideDismiss =>
      isHausa ? 'Na Fahimta, Na Gode' : 'Got It, Continue';

  String sessionLoanTotalLabel(int level) => isHausa
      ? 'Jumullar Bashin Shekara ($level Level):'
      : 'Session Loan Total ($level Level):';

  // ----------------------------------------------------
  // Eligibility Screen
  // ----------------------------------------------------
  String get eligibilityHeaderTitle =>
      isHausa ? 'Cancanta' : 'Eligibility Checker';
  String get academicStreamTitle =>
      isHausa ? 'Rukunin Shiga Makaranta' : 'Academic Entry Stream';
  String get coreCriteriaTitle => isHausa
      ? '1. Muhimman Sharuddan Doka (Sashe na 2.0)'
      : '1. Statutory Core Criteria';
  String get kycChecklistTitle => isHausa
      ? '2. Shirye-shiryen Takardun Tantancewa (KYC)'
      : '2. KYC & Identity Verification';
  String get disqualificationBarsTitle => isHausa
      ? '3. Shingen Doka Masu Hana Samun Bashi (Sashe na 3.0)'
      : '3. Statutory Disqualification Bars';
  String get checkStatusButton =>
      isHausa ? 'Duba Sakamakon Cancanta' : 'Evaluate My Eligibility';

  // ----------------------------------------------------
  // Timeline Screen
  // ----------------------------------------------------
  String get timelineHeaderTitle => isHausa
      ? 'Matakan Neman Lamuni & Wa\'adin Aiki'
      : 'Timeline & SLA Tracker';
  String get timelineIntroDesc => isHausa
      ? 'Sashe na 4.2 na Ka\'idojin ya gindaya tsauraran wa\'adin aiki a matakai 5 (tsawon kwanakin aiki 47 a jimlace). Gwada matsayin aikace-aikacenka a kasa.'
      : 'Section 4.2 of the Guidelines mandates strict processing deadlines across 5 stages (~47 working days maximum cycle). Test whether your application is on track below.';

  String get onTrackEvaluatorTitle => isHausa
      ? 'Na\'urar Gwada Halin da Aikace-aikace Yake Ciki'
      : 'Interactive On-Track Evaluator';
  String get currentStageLabel => isHausa
      ? 'Zabi Matakin da Aikace-aikacenka Yake Ciki'
      : 'Current Application Stage';
  String get submissionDateLabel =>
      isHausa ? 'Ranar da Aka Cika Fom' : 'Submission Date';

  String get statusOnTrack =>
      isHausa ? 'Yana Kan Lokaci Cikin Tsari' : 'On Track';
  String get statusApproachingDeadline =>
      isHausa ? 'Wa\'adi na Gabatowa' : 'Approaching Deadline';
  String get statusOverdue => isHausa ? 'Ya Wuce Wa\'adi' : 'Overdue';

  String get grievanceDirectoryTitle => isHausa
      ? 'Shafukan Tuntubar Hukuma da Korafi'
      : 'Official Grievance & Escalation Directory';

  // ----------------------------------------------------
  // FAQ Screen
  // ----------------------------------------------------
  String get faqHeaderTitle =>
      isHausa ? 'Tambayoyi Masu Muhimmanci' : 'Official FAQ';
  String get faqSearchPlaceholder => isHausa
      ? 'Bincika tambayoyi kan doka da biya...'
      : 'Search guidelines, repayment, or legal terms...';
  String get faqAllQuestions => isHausa ? 'Dukkan Tambayoyi' : 'All Questions';
  String get faqNoResultsTitle => isHausa
      ? 'Ba a sami tambayar da ta dace ba'
      : 'No matching questions found';
  String get faqNoResultsDesc => isHausa
      ? 'Gwada bincika wata kalmar daban ko zabi wani rukunin tambayoyin.'
      : 'Try searching with different keywords or switch categories.';

  // ----------------------------------------------------
  // About Screen
  // ----------------------------------------------------
  String get aboutHeaderTitle =>
      isHausa ? 'Game da Mu & Tuntuba' : 'About & Support';
  String get developerBadge => isHausa
      ? 'GAME DA WANDA YA SAMAR DA WANNAN JAGORA'
      : 'ABOUT DEVELOPER & BUILDER';
  String get developerIntro => isHausa
      ? 'My NELFund wani yunkuri ne na kashin kai mai zaman kansa wanda ya samar da shi:'
      : 'My NELFund is an independent civic initiative developed and built by:';

  String get developerName => 'Abdullahi Adam Usman';
  String get developerRole => isHausa
      ? 'Ɗalibi • Jami\'ar Ahmadu Bello (ABU)'
      : 'Student • Ahmadu Bello University (ABU)';
  String get developerEducation => isHausa
      ? 'Ɗalibi mai karatu a aji na 300 a Sashen Nazarin Harkokin Ƙasa da Ƙasa.\nJami\'ar Ahmadu Bello (ABU), Zaria.'
      : '300 Level Student of International Studies.\nAhmadu Bello University (ABU), Zaria.';

  String get contactDeveloperTitle => isHausa ? 'Tuntuba' : 'Contact Developer';
  String get contactDeveloperDesc => isHausa
      ? 'Kuna da wata shawara, gyaran kuskuren fasaha (bugs), ko ra\'ayi kan aikin wannan manhaja? Ku tuntubi mai haɓakawa kai-tsaye:'
      : 'Have technical feedback, bug reports, or feature suggestions regarding this mobile app? Reach out directly to the developer:';

  // Official Loan Inquiry Disclaimer
  String get loanInquiryNoticeTitle => isHausa
      ? 'Batutuwan da suka Shafi NELFUND da Lamuni'
      : 'Official NELFUND & Loan Enquiries';
  String get loanInquiryNoticeDesc => isHausa
      ? 'Duk wata matsala ko tambaya kan cika fom ɗin bashi, tantancewar makaranta (SVS), amincewa, ko fitar da kuɗin karatu da alawus, hukumar NELFUND ce kaɗai ke da alhakin su. Mai haɓaka wannan manhaja ba shi da hurumi ko damar shiga bayanan ɗalibai na hukuma. Da fatan a tuntuɓi hukuma kai-tsaye:'
      : 'For all matters concerning loan applications, SVS school verification, approvals, upkeep stipends, or school fee disbursement, contact official NELFUND administrators directly. The app developer has no access to personal student records or loan accounts. Please contact the agency directly:';
  String get contactOfficialNelfundEmailBtn => isHausa
      ? 'Tura Imel zuwa Hukumar NELFUND'
      : 'Email Official NELFUND Support';

  // Digital Solutions CTA
  String get digitalSolutionsBadge => isHausa
      ? 'FASAHA DA MANHAJOJIN ZAMANI'
      : 'DIGITAL INNOVATION & DEVELOPMENT';
  String get digitalSolutionsTitle => isHausa
      ? 'Kuna Buƙatar Manhaja ko Tsarin Dijital don Kanku, Kasuwanci, ko Ƙungiya?'
      : 'Need a Digital Solution for Yourself, Business, or Organisation?';
  String get digitalSolutionsDesc => isHausa
      ? 'Kuna da tunani ko aikin manhajar waya (mobile app), shafin yanar gizo, ko tsarin kwamfuta na zamani don kanku, kasuwancinku, ko ƙungiyarku? Daga fasaha zuwa aiki mai nagarta da tsari, ku tuntube mu domin tattaunawa da mayar da burinku gaskiya.'
      : 'Have a vision for a mobile app, high-performance web platform, automated system, or custom digital product? Whether you are an individual with an idea, a growing business, or an organisation seeking modern tech solutions, let\'s build something exceptional together.';
  String get digitalSolutionsPill1 =>
      isHausa ? 'Manhajojin Waya da Yanar Gizo' : 'Mobile & Web Apps';
  String get digitalSolutionsPill2 =>
      isHausa ? 'Tsarin Kasuwanci na Zamani' : 'Business Systems';
  String get digitalSolutionsPill3 =>
      isHausa ? 'Daga Tunani zuwa Aiki' : 'Idea to Execution';
  String get digitalSolutionsCtaButton => isHausa
      ? 'Tattauna a WhatsApp • Faɗi Shirinku'
      : 'Chat on WhatsApp • Discuss Your Idea';

  String get directCallPhone => '08164135836';
  String get whatsappPhone => '09076872520';
  String get whatsappOnlyLabel => isHausa ? 'WhatsApp Kawai' : 'WhatsApp Only';
  String get whatsappButtonLabel => isHausa
      ? 'Tuntuɓa a WhatsApp (WhatsApp Only)'
      : 'Chat on WhatsApp (WhatsApp Only)';
  String get callButtonLabel =>
      isHausa ? 'Kira: 08164135836' : 'Call: 08164135836';

  String get clarificationTitle => isHausa
      ? 'Fayyace Matsayi & Wanke Kai na Hukuma'
      : 'Official Clarification & Disclaimer';
  String get clarificationBody => isHausa
      ? 'Manhaja Mai Zaman Kanta: Wannan manhaja ba daga hukumar NELFUND take ba kuma ba daga Gwamnatin Tarayyar Najeriya take ba. An gina ta ne a matsayin jagora mai zaman kanta domin wayar da kan dalibai, ilmantarwa, da fahimtar harkokin kudi karkashin Dokar Lamunin Dalibai ta 2024.'
      : 'Independent Civic Initiative: This application is not from NELFUND (Nigerian Education Loan Fund) or the Federal Government of Nigeria. It was developed as an independent civic guide created solely for student education, awareness, and financial empowerment under the Students Loans Act 2024.';

  String get zeroDataCollectionDesc => isHausa
      ? 'Manhajar Ba Ta Tattara Bayanai: Wannan manhaja ba ta tattarawa, adanawa, ko tura sunanka, adadin bashinka, lambar BVN, lambar NIN, ko takardun karatunka. Manhajar tana aiki ne a kan wayarka ba tare da bukatar intanet ba domin lissafi da tantancewa kadai.'
      : 'Zero Personal Data Collection: This application does not collect, store, or transmit your name, loan amount, financial data, Bank Verification Number (BVN), National Identity Number (NIN), or academic credentials. This app is completely data-free, private, and functions entirely offline solely for your statutory calculation and simulation.';

  String get officialChannelsTitle =>
      isHausa ? 'Hanyoyin Hukumar NELFUND' : 'Official NELFUND Channels';
  String get officialChannelsDesc => isHausa
      ? 'Domin cika bashi, tantancewar makaranta (SVS), da tambayoyi, yi amfani da shafukan Gwamnatin Tarayya kadai:'
      : 'For official loan applications, institution verification (SVS), and formal inquiries, use only authorized Federal Government portals:';

  String get officialPortalTitle =>
      isHausa ? 'Shafin Yanar Gizo na Hukuma' : 'Official Portal & Website';
  String get officialEmailTitle =>
      isHausa ? 'Imel na Hukuma' : 'Official Inquiries Email';

  String get languageCardTitle =>
      isHausa ? 'Zabin Harshe / Language' : 'Language / Harshe';
  String get languageCardDesc => isHausa
      ? 'Zabi harshen da kake son manhajar ta rinka amfani da shi nan take:'
      : 'Select your preferred language for the application:';

  // ----------------------------------------------------
  // Sauki Go Companion App Promo
  // ----------------------------------------------------
  String get getDataHeaderLabel => 'Get Data';
  String get saukiTrustedTag => isHausa ? 'Amintacciya' : 'Trusted App';
  String get saukiForIphoneLabel => isHausa ? 'NA IPHONE' : 'FOR IPHONE';
  String get saukiForAndroidLabel => isHausa ? 'NA ANDROID' : 'FOR ANDROID';
  String get saukiModalIphoneOverline =>
      isHausa ? 'NA IPHONE • SAUKE A' : 'FOR IPHONE • DOWNLOAD ON';
  String get saukiModalAndroidOverline =>
      isHausa ? 'NA ANDROID • SAUKE A' : 'FOR ANDROID • GET IT ON';
  String get saukiMaybeLaterLabel => isHausa ? 'Ba Yanzu Ba' : 'Maybe Later';
}
