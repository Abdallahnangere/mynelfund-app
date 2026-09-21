import '../core/localization/app_locale.dart';

enum FaqCategory {
  all,
  applying,
  disbursement,
  repayment,
  defaultRecovery,
}

extension FaqCategoryExtension on FaqCategory {
  String get title => getTitle(AppLanguage.english);

  String getTitle(AppLanguage lang) {
    if (lang == AppLanguage.hausa) {
      switch (this) {
        case FaqCategory.all:
          return 'Dukkan Tambayoyi';
        case FaqCategory.applying:
          return 'Neman Bashi & Cancanta';
        case FaqCategory.disbursement:
          return 'Biyan Kudin Makaranta & Alawus';
        case FaqCategory.repayment:
          return 'Biyan Bashi & Sassauci';
        case FaqCategory.defaultRecovery:
          return 'Kin Biya & Matakan Doka';
      }
    }
    switch (this) {
      case FaqCategory.all:
        return 'All Questions';
      case FaqCategory.applying:
        return 'Applying & Eligibility';
      case FaqCategory.disbursement:
        return 'Disbursement & Fees';
      case FaqCategory.repayment:
        return 'Repayment & Moratorium';
      case FaqCategory.defaultRecovery:
        return 'Default & Legal';
    }
  }

  String get shortLabel => getShortLabel(AppLanguage.english);

  String getShortLabel(AppLanguage lang) {
    if (lang == AppLanguage.hausa) {
      switch (this) {
        case FaqCategory.all:
          return 'Duka';
        case FaqCategory.applying:
          return 'Neman Bashi';
        case FaqCategory.disbursement:
          return 'Biyan Kudi';
        case FaqCategory.repayment:
          return 'Biyan Bashi';
        case FaqCategory.defaultRecovery:
          return 'Shari\'a';
      }
    }
    switch (this) {
      case FaqCategory.all:
        return 'All';
      case FaqCategory.applying:
        return 'Applying';
      case FaqCategory.disbursement:
        return 'Disbursement';
      case FaqCategory.repayment:
        return 'Repayment';
      case FaqCategory.defaultRecovery:
        return 'Default';
    }
  }
}

class FaqItem {
  final String id;
  final String question;
  final String answer;
  final String statutoryReference;
  final String questionHa;
  final String answerHa;
  final String statutoryReferenceHa;
  final FaqCategory category;

  const FaqItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.statutoryReference,
    required this.questionHa,
    required this.answerHa,
    required this.statutoryReferenceHa,
    required this.category,
  });

  String getQuestion(AppLanguage lang) =>
      lang == AppLanguage.hausa ? questionHa : question;

  String getAnswer(AppLanguage lang) =>
      lang == AppLanguage.hausa ? answerHa : answer;

  String getReference(AppLanguage lang) =>
      lang == AppLanguage.hausa ? statutoryReferenceHa : statutoryReference;

  String getStatutoryReference(AppLanguage lang) => getReference(lang);

  static const List<FaqItem> defaultList = [
    // --- Applying & Eligibility ---
    FaqItem(
      id: 'app_1',
      question: 'Who is eligible to apply for the NELFUND Student Loan?',
      answer:
          'Under Section 2.0 of the Guidelines, you must be a verified Nigerian citizen (with valid NIN and BVN) who has gained admission or is currently enrolled full-time in an approved Federal or State public tertiary institution (University, Polytechnic, or College of Education). There are no income restrictions or family income ceilings.',
      statutoryReference: 'Section 2.0 & Section 2.1',
      questionHa: 'Su wane ne suka cancanci neman bashin karatun dalibai na NELFUND?',
      answerHa:
          'Karkashin Sashe na 2.0 na Ka\'idojin, dole ne ka kasance dan Najeriya (mai ingantacciyar lambar NIN da BVN) wanda ya sami shiga ko yake karatu a halin yanzu a jami\'a, kwalejin foliteknik, ko kwalejin ilimi ta gwamnatin tarayya ko jiha. Babu wani sharadi kan iyakar kudin shigar iyaye ko dangi.',
      statutoryReferenceHa: 'Sashe na 2.0 & Sashe na 2.1',
      category: FaqCategory.applying,
    ),
    FaqItem(
      id: 'app_2',
      question: 'Can private university students apply for NELFUND loans?',
      answer:
          'No. Under Section 2.2 of the Students Loans Act 2024, only students attending approved Federal and State public tertiary institutions (ETIs) are eligible for funding. Private university students are currently excluded.',
      statutoryReference: 'Section 2.2 (Institutional Criteria)',
      questionHa: 'Shin daliban jami\'o\'i masu zaman kansu za su iya neman bashin?',
      answerHa:
          'A\'a. Karkashin Sashe na 2.2 na Dokar Lamunin Dalibai ta 2024, daliban da suke halartar manyan makarantun gwamnatin tarayya da na jihohi ne kadai suka cancanci samun lamuni a halin yanzu.',
      statutoryReferenceHa: 'Sashe na 2.2 (Ka\'idojin Makarantu)',
      category: FaqCategory.applying,
    ),
    FaqItem(
      id: 'app_3',
      question: 'What is the Student Verification System (SVS) upload requirement?',
      answer:
          'Before an applicant can complete their loan application, their tertiary institution must upload their academic profile, matriculation/JAMB details, and fee structure directly into the NELFUND Student Verification System (SVS). If your school has not completed this upload, your profile cannot be cleared for evaluation.',
      statutoryReference: 'Section 4.1 (Institutional Verification)',
      questionHa: 'Menene ma\'anar lodin bayanai a Tsarin Tabbatar da Dalibai (SVS)?',
      answerHa:
          'Kafin mai neman bashi ya iya kammala aikace-aikacensa, dole ne makarantarsa ta loda bayanan karatunsa, lambar shiga makaranta ko ta JAMB, da tsarin kudaden makaranta kai-tsaye a tsarin SVS na NELFUND. Idan makarantarku ba ta loda bayanan ba, ba za a iya tantance ku ba.',
      statutoryReferenceHa: 'Sashe na 4.1 (Tantancewar Makaranta)',
      category: FaqCategory.applying,
    ),
    FaqItem(
      id: 'app_4',
      question: 'Are there any application or processing fees to apply?',
      answer:
          'Absolutely not. Applying on the official portal (nelf.gov.ng) is 100% free of charge. NELFUND does not charge application fees, processing fees, or commission. Beware of fraudulent agents claiming to expedite applications for a fee.',
      statutoryReference: 'Students Loans Act 2024',
      questionHa: 'Shin akwai wani kudi na cika fom ko na aiki da ake biya?',
      answerHa:
          'Sam babu ko kobo. Neman bashi a shafin gwamnati (nelf.gov.ng) kyauta ne 100%. NELFUND ba ta karbar kudin cika fom, kudin aiki, ko wani kason kudi. A kiyaye mutane ko wakilai masu neman kudi da sunan za su taimaka.',
      statutoryReferenceHa: 'Dokar Lamunin Dalibai ta 2024',
      category: FaqCategory.applying,
    ),
    FaqItem(
      id: 'app_5',
      question: 'Can someone who already holds a first degree apply?',
      answer:
          'No. Under Section 4.1.3 of the Guidelines (Attestation Form), applicants must attest under oath that they do not already possess a first degree or equivalent qualification from any Nigerian or foreign tertiary institution.',
      statutoryReference: 'Section 4.1.3 (Attestation Form)',
      questionHa: 'Shin wanda ya riga ya kammala digiri na farko zai iya sake neman bashi?',
      answerHa:
          'A\'a. Karkashin Sashe na 4.1.3 na Ka\'idoji (Takardar Rantsuwa), dole ne mai nema ya rantse cewa ba shi da digiri na farko ko makamancinsa daga kowace jami\'a a Najeriya ko kasashen waje.',
      statutoryReferenceHa: 'Sashe na 4.1.3 (Takardar Rantsuwa)',
      category: FaqCategory.applying,
    ),

    // --- Disbursement & Fees ---
    FaqItem(
      id: 'disb_1',
      question: 'How are the institutional fees (tuition) paid?',
      answer:
          'Institutional fees are never paid in cash or deposited into the student’s personal bank account. 100% of approved tuition and charges are paid electronically and directly into the designated official bank account of your tertiary institution.',
      statutoryReference: 'Section 4.3 (Disbursement Process)',
      questionHa: 'Ta yaya ake biyan kudaden makaranta (Tuition)?',
      answerHa:
          'Ba a taba biyan kudin makaranta a hannu ko a asusun dalibi na kashin kai. Ana tura 100% na kudin makarantar kai-tsaye ta hanyar na\'ura zuwa asusun bankin hukuma na makarantarku.',
      statutoryReferenceHa: 'Sashe na 4.3 (Hanyar Biyan Kudi)',
      category: FaqCategory.disbursement,
    ),
    FaqItem(
      id: 'disb_2',
      question: 'How and when is the ₦20,000 monthly upkeep stipend paid?',
      answer:
          'The optional upkeep stipend of ₦20,000 per month is credited directly into the verified commercial bank account of the student on a monthly basis throughout the approved academic session.',
      statutoryReference: 'Section 4.3 (Upkeep Stipend)',
      questionHa: 'Ta yaya kuma yaushe ake biyan alawus na tallafin rayuwa na ₦20,000 na kowanne wata?',
      answerHa:
          'Ana tura tallafin alawus na ₦20,000 a kowanne wata kai-tsaye zuwa asusun bankin dalibi na kashin kai wanda aka tantance a duk tsawon zangon karatun da aka amince da shi.',
      statutoryReferenceHa: 'Sashe na 4.3 (Alawus na Wata)',
      category: FaqCategory.disbursement,
    ),
    FaqItem(
      id: 'disb_3',
      question: 'What happens if I already paid my school fees before the loan was approved?',
      answer:
          'Under Section 4.1.2 of the Guidelines (Student Refund Policy), if a student pays their institutional charges before NELFUND disburses the approved loan, the tertiary institution is legally mandated to refund the student within 30 calendar days upon receipt of funds from NELFUND.',
      statutoryReference: 'Section 4.1.2 (Student Refund Policy)',
      questionHa: 'Menene zai faru idan na riga na biya kudin makaranta da kaina kafin bashi ya fito?',
      answerHa:
          'Karkashin Sashe na 4.1.2 na Ka\'idojin (Tsarin Mayar wa Dalibi Kudinsa), idan dalibi ya biya kudin makarantarsa kafin NELFUND ta tura kudin, doka ta tilasta wa makarantar mayar wa dalibin kudinsa cikin kwanaki 30 da samun kudin daga NELFUND.',
      statutoryReferenceHa: 'Sashe na 4.1.2 (Mayar wa Dalibi Kudi)',
      category: FaqCategory.disbursement,
    ),
    FaqItem(
      id: 'disb_4',
      question: 'What are the official turnaround times for evaluation and disbursement?',
      answer:
          'The official Service Level Agreements (SLAs) are: (1) Institution verification: up to 20 working days; (2) NELFUND evaluation: 15 calendar days; (3) Approval: up to 10 working days; (4) Fund disbursement: up to 10 working days.',
      statutoryReference: 'Section 4.2 & Section 4.3',
      questionHa: 'Menene tsawon wa\'adin tantancewa da fitar da kudi na hukuma?',
      answerHa:
          'Wa\'adin aiki na hukuma (SLAs) shi ne: (1) Tantancewar makaranta: har zuwa kwanakin aiki 20; (2) Tantancewar NELFUND: kwanaki 15 a kalanda; (3) Amincewa: kwanakin aiki 10; (4) Fitar da kudi: kwanakin aiki 10.',
      statutoryReferenceHa: 'Sashe na 4.2 & Sashe na 4.3',
      category: FaqCategory.disbursement,
    ),

    // --- Repayment & Moratorium ---
    FaqItem(
      id: 'rep_1',
      question: 'When does mandatory loan repayment begin?',
      answer:
          'Under Section 5.1 of the 2024 Act, loan repayment does not begin until exactly two (2) years after the beneficiary completes their National Youth Service Corps (NYSC) service year (or obtains a formal letter of exemption). Zero deductions occur while you are studying or during your service year.',
      statutoryReference: 'Section 5.1 (Commencement of Repayment)',
      questionHa: 'Yaushe ne dole a fara biyan kudin bashi?',
      answerHa:
          'Karkashin Sashe na 5.1 na Dokar 2024, ba za a fara biyan bashi ba sai bayan cikar shekaru biyu (2) cif da kammala hidimar kasa ta NYSC (ko samun takardar yaye ta doka). Ba a rage ko kobo a lokacin da kake karatu ko a lokacin NYSC.',
      statutoryReferenceHa: 'Sashe na 5.1 (Lokacin Fara Biyan Bashi)',
      category: FaqCategory.repayment,
    ),
    FaqItem(
      id: 'rep_2',
      question: 'Is there any interest charged on the NELFUND loan?',
      answer:
          'No. The loan is strictly 0% interest-free under the Students Loans Act 2024. Beneficiaries only repay the exact principal amount disbursed on their behalf. There are no compounding charges, processing fees, or hidden penalties.',
      statutoryReference: 'Students Loans Act 2024 (Section 5.0)',
      questionHa: 'Shin akwai wani kudin ruwa a kan bashin NELFUND?',
      answerHa:
          'A\'a. Bashin bashi ne mara kudin ruwa ko kobo (0% interest) karkashin Dokar 2024. Ainihin kudin da aka biya ma makaranta ko aka ba ka shi kadai za ka biya. Babu kudin karuwa, caji boyayye, ko tara.',
      statutoryReferenceHa: 'Dokar Lamunin Dalibai ta 2024 (Sashe na 5.0)',
      category: FaqCategory.repayment,
    ),
    FaqItem(
      id: 'rep_3',
      question: 'How is the monthly deduction calculated for employed beneficiaries?',
      answer:
          'Repayment is executed through Pay-As-You-Earn (PAYE). Your employer is legally mandated to deduct 10% of your gross monthly salary at source and remit it directly to the NELFUND recovery account.',
      statutoryReference: 'Section 5.1(a) (Employer Obligations)',
      questionHa: 'Ta yaya ake lissafin rage kudin wata ga masu aikin albashi?',
      answerHa:
          'Ana aiwatar da biyan bashi ta hanyar tsarin PAYE. Doka ta tilasta wa ma\'aikatarka cire kashi 10% na babban albashinka na wata kai-tsaye a tushe tare da tura shi asusun NELFUND.',
      statutoryReferenceHa: 'Sashe na 5.1(a) (Nauyin Ma\'aikata)',
      category: FaqCategory.repayment,
    ),
    FaqItem(
      id: 'rep_4',
      question: 'How does repayment work for self-employed beneficiaries?',
      answer:
          'Under Section 5.2, self-employed beneficiaries must remit 10% of their monthly business profit to NELFUND. Within 60 days of starting enterprise, you must register your business details, bank accounts, and monthly profit statements with NELFUND.',
      statutoryReference: 'Section 5.2 (Self-Employed Beneficiaries)',
      questionHa: 'Ta yaya biyan bashi yake aiki ga masu sana\'ar dogaro da kai?',
      answerHa:
          'Karkashin Sashe na 5.2, masu sana\'ar dogaro da kai za su rinka tura kashi 10% na ribar kasuwancinsu a wata zuwa NELFUND. Cikin kwanaki 60 da fara sana\'a, dole ne ka yi rajistar bayanan sana\'arka da asusun banki da NELFUND.',
      statutoryReferenceHa: 'Sashe na 5.2 (Masu Dogaro da Kai)',
      category: FaqCategory.repayment,
    ),
    FaqItem(
      id: 'rep_5',
      question: 'What happens if I am still unemployed 2 years after NYSC?',
      answer:
          'Under Section 5.1(c), if you remain unemployed after the 2-year post-NYSC grace period, you must submit a sworn affidavit of unemployment and periodic statutory declarations to NELFUND. Repayment is suspended without interest or penalties until you secure employment.',
      statutoryReference: 'Section 5.1(c) (Unemployment Declaration)',
      questionHa: 'Menene zai faru idan har yanzu ban sami aikin yi ba bayan shekaru 2 da NYSC?',
      answerHa:
          'Karkashin Sashe na 5.1(c), idan ba ka sami aiki ba bayan wa\'adin shekaru 2 na sassauci, za ka gabatar da takardar rantsuwa ta rashin aikin yi ga NELFUND. Za a dakatar da biyan bashi ba tare da tara ko kudin ruwa ba har sai ka sami aiki.',
      statutoryReferenceHa: 'Sashe na 5.1(c) (Sanarwar Rashin Aikin Yi)',
      category: FaqCategory.repayment,
    ),
    FaqItem(
      id: 'rep_6',
      question: 'What are my reporting duties when I get a job or change employers?',
      answer:
          'Under Section 5.1(b), within 30 days of securing employment, you must submit your employer’s name, address, monthly salary, and loan ID to NELFUND. If you switch jobs, you must report the change to NELFUND within 30 days.',
      statutoryReference: 'Section 5.1(b) (Beneficiary Obligations)',
      questionHa: 'Wane nauyi ya rataya a wuyana idan na sami aiki ko na canza ma\'aikata?',
      answerHa:
          'Karkashin Sashe na 5.1(b), cikin kwanaki 30 da samun aiki, dole ne ka aike wa NELFUND sunan ma\'aikatarka, adireshinta, albashinka, da lambar bashinka. Idan ka canza aiki ma, dole ne ka sanar cikin kwanaki 30.',
      statutoryReferenceHa: 'Sashe na 5.1(b) (Nauyin Mai Bashi)',
      category: FaqCategory.repayment,
    ),

    // --- Default & Legal Recovery ---
    FaqItem(
      id: 'def_1',
      question: 'What is the Global Standing Instruction (GSI) mandate?',
      answer:
          'The Global Standing Instruction (GSI) is a Central Bank of Nigeria (CBN) financial recovery instrument. Under Section 5.3, willful defaulters will have their outstanding loan amount automatically swept and debited from any and all commercial bank accounts linked to their BVN and NIN nationwide.',
      statutoryReference: 'Section 5.3(d) (GSI Auto-Debit)',
      questionHa: 'Menene ma\'anar umarnin banki na GSI (Global Standing Instruction)?',
      answerHa:
          'Umarnin GSI wata ka\'ida ce ta Babban Bankin Najeriya (CBN). Karkashin Sashe na 5.3, duk wanda ya ki biyan bashi da gangan, za a rinka kwasar kudin bashinsa kai-tsaye daga duk wani asusun bankin kasuwanci da yake da shi da yake hade da BVN ko NIN dinsa a fadin kasar nan.',
      statutoryReferenceHa: 'Sashe na 5.3(d) (Kwasar Kudi ta GSI)',
      category: FaqCategory.defaultRecovery,
    ),
    FaqItem(
      id: 'def_2',
      question: 'Will defaulting affect my ability to get bank loans or credit cards?',
      answer:
          'Yes. Under Section 5.3(b), defaulters are formally reported to the Central Bank’s Credit Risk Management System (CRMS) and private Credit Bureaus. This blacklists you from securing bank loans, car financing, mortgages, or credit cards across all Nigerian financial institutions.',
      statutoryReference: 'Section 5.3(b) (CRMS Blacklisting)',
      questionHa: 'Shin kin biyan bashi zai iya hana ni samun lamunin banki a gaba?',
      answerHa:
          'Kwarai kuwa. Karkashin Sashe na 5.3(b), za a kai sunan duk wanda ya ki biya zuwa Tsarin CRMS na Babban Bankin Najeriya da hukumomin binciken bashi. Wannan zai sa a toshe ka daga samun lamunin banki, katin bashi, ko jingina a duk bankunan Najeriya.',
      statutoryReferenceHa: 'Sashe na 5.3(b) (Toshewa a Tsarin CRMS)',
      category: FaqCategory.defaultRecovery,
    ),
    FaqItem(
      id: 'def_3',
      question: 'Can NELFUND publish the names of defaulters publicly?',
      answer:
          'Yes. Section 5.3(c) explicitly empowers NELFUND to publish the names, photographs, institution attended, and outstanding debt balances of chronic loan defaulters in national daily newspapers and public gazettes.',
      statutoryReference: 'Section 5.3(c) (Publication of Defaulters)',
      questionHa: 'Shin NELFUND za ta iya buga sunayen wadanda suka ki biya a jaridu?',
      answerHa:
          'E. Sashe na 5.3(c) ya ba NELFUND cikakken ikon buga sunaye, hotuna, makarantun da suka halarta, da adadin bashin da ake bin duk wadanda suka ki biya a jaridun kasar nan da mujallun gwamnati.',
      statutoryReferenceHa: 'Sashe na 5.3(c) (Buga Sunayen Masu Bashi)',
      category: FaqCategory.defaultRecovery,
    ),
    FaqItem(
      id: 'def_4',
      question: 'Can legal prosecution or court action be taken against defaulters?',
      answer:
          'Yes. Where warning notices, credit blacklisting, and GSI sweeps fail to recover the debt, NELFUND will institute legal action in the Federal High Court to recover the outstanding balance plus statutory legal recovery costs.',
      statutoryReference: 'Section 5.3(e) (Legal Prosecution)',
      questionHa: 'Shin za a iya kai mutum kotu idan ya ki biyan bashi?',
      answerHa:
          'E. Idan duk matakan jan kunne, toshewa a banki, da kwasar kudi ta GSI suka gaza, NELFUND za ta shigar da karar mai bashi a Babbar Kotun Tarayya domin karbar kudaden tare da kudaden shari\'a.',
      statutoryReferenceHa: 'Sashe na 5.3(e) (Shari\'a a Kotu)',
      category: FaqCategory.defaultRecovery,
    ),
  ];
}
