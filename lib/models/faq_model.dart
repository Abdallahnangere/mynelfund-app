enum FaqCategory {
  all,
  applying,
  disbursement,
  repayment,
  defaultRecovery,
}

extension FaqCategoryExtension on FaqCategory {
  String get title {
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

  String get shortLabel {
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
  final FaqCategory category;

  const FaqItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.statutoryReference,
    required this.category,
  });

  static const List<FaqItem> defaultList = [
    // --- Applying & Eligibility ---
    FaqItem(
      id: 'app_1',
      question: 'Who is eligible to apply for the NELFUND Student Loan?',
      answer:
          'Under Section 2.0 of the Guidelines, you must be a verified Nigerian citizen (with valid NIN and BVN) who has gained admission or is currently enrolled full-time in an approved Federal or State public tertiary institution (University, Polytechnic, or College of Education). There are no income restrictions or family income ceilings.',
      statutoryReference: 'Section 2.0 & Section 2.1',
      category: FaqCategory.applying,
    ),
    FaqItem(
      id: 'app_2',
      question: 'Can private university students apply for NELFUND loans?',
      answer:
          'No. Under Section 2.2 of the Students Loans Act 2024, only students attending approved Federal and State public tertiary institutions (ETIs) are eligible for funding. Private university students are currently excluded.',
      statutoryReference: 'Section 2.2 (Institutional Criteria)',
      category: FaqCategory.applying,
    ),
    FaqItem(
      id: 'app_3',
      question: 'What is the Student Verification System (SVS) upload requirement?',
      answer:
          'Before an applicant can complete their loan application, their tertiary institution must upload their academic profile, matriculation/JAMB details, and fee structure directly into the NELFUND Student Verification System (SVS). If your school has not completed this upload, your profile cannot be cleared for evaluation.',
      statutoryReference: 'Section 4.1 (Institutional Verification)',
      category: FaqCategory.applying,
    ),
    FaqItem(
      id: 'app_4',
      question: 'Are there any application or processing fees to apply?',
      answer:
          'Absolutely not. Applying on the official portal (nelf.gov.ng) is 100% free of charge. NELFUND does not charge application fees, processing fees, or commission. Beware of fraudulent agents claiming to expedite applications for a fee.',
      statutoryReference: 'Students Loans Act 2024',
      category: FaqCategory.applying,
    ),
    FaqItem(
      id: 'app_5',
      question: 'Can someone who already holds a first degree apply?',
      answer:
          'No. Under Section 4.1.3 of the Guidelines (Attestation Form), applicants must attest under oath that they do not already possess a first degree or equivalent qualification from any Nigerian or foreign tertiary institution.',
      statutoryReference: 'Section 4.1.3 (Attestation Form)',
      category: FaqCategory.applying,
    ),

    // --- Disbursement & Fees ---
    FaqItem(
      id: 'disb_1',
      question: 'How are the institutional fees (tuition) paid?',
      answer:
          'Institutional fees are never paid in cash or deposited into the student’s personal bank account. 100% of approved tuition and charges are paid electronically and directly into the designated official bank account of your tertiary institution.',
      statutoryReference: 'Section 4.3 (Disbursement Process)',
      category: FaqCategory.disbursement,
    ),
    FaqItem(
      id: 'disb_2',
      question: 'How and when is the ₦20,000 monthly upkeep stipend paid?',
      answer:
          'The optional upkeep stipend of ₦20,000 per month is credited directly into the verified commercial bank account of the student on a monthly basis throughout the approved academic session.',
      statutoryReference: 'Section 4.3 (Upkeep Stipend)',
      category: FaqCategory.disbursement,
    ),
    FaqItem(
      id: 'disb_3',
      question: 'What happens if I already paid my school fees before the loan was approved?',
      answer:
          'Under Section 4.1.2 of the Guidelines (Student Refund Policy), if a student pays their institutional charges before NELFUND disburses the approved loan, the tertiary institution is legally mandated to refund the student within 30 calendar days upon receipt of funds from NELFUND.',
      statutoryReference: 'Section 4.1.2 (Student Refund Policy)',
      category: FaqCategory.disbursement,
    ),
    FaqItem(
      id: 'disb_4',
      question: 'What are the official turnaround times for evaluation and disbursement?',
      answer:
          'The official Service Level Agreements (SLAs) are: (1) Institution verification: up to 20 working days; (2) NELFUND evaluation: 15 calendar days; (3) Approval: up to 10 working days; (4) Fund disbursement: up to 10 working days.',
      statutoryReference: 'Section 4.2 & Section 4.3',
      category: FaqCategory.disbursement,
    ),

    // --- Repayment & Moratorium ---
    FaqItem(
      id: 'rep_1',
      question: 'When does mandatory loan repayment begin?',
      answer:
          'Under Section 5.1 of the 2024 Act, loan repayment does not begin until exactly two (2) years after the beneficiary completes their National Youth Service Corps (NYSC) service year (or obtains a formal letter of exemption). Zero deductions occur while you are studying or during your service year.',
      statutoryReference: 'Section 5.1 (Commencement of Repayment)',
      category: FaqCategory.repayment,
    ),
    FaqItem(
      id: 'rep_2',
      question: 'Is there any interest charged on the NELFUND loan?',
      answer:
          'No. The loan is strictly 0% interest-free under the Students Loans Act 2024. Beneficiaries only repay the exact principal amount disbursed on their behalf. There are no compounding charges, processing fees, or hidden penalties.',
      statutoryReference: 'Students Loans Act 2024 (Section 5.0)',
      category: FaqCategory.repayment,
    ),
    FaqItem(
      id: 'rep_3',
      question: 'How is the monthly deduction calculated for employed beneficiaries?',
      answer:
          'Repayment is executed through Pay-As-You-Earn (PAYE). Your employer is legally mandated to deduct 10% of your gross monthly salary at source and remit it directly to the NELFUND recovery account.',
      statutoryReference: 'Section 5.1(a) (Employer Obligations)',
      category: FaqCategory.repayment,
    ),
    FaqItem(
      id: 'rep_4',
      question: 'How does repayment work for self-employed beneficiaries?',
      answer:
          'Under Section 5.2, self-employed beneficiaries must remit 10% of their monthly business profit to NELFUND. Within 60 days of starting enterprise, you must register your business details, bank accounts, and monthly profit statements with NELFUND.',
      statutoryReference: 'Section 5.2 (Self-Employed Beneficiaries)',
      category: FaqCategory.repayment,
    ),
    FaqItem(
      id: 'rep_5',
      question: 'What happens if I am still unemployed 2 years after NYSC?',
      answer:
          'Under Section 5.1(c), if you remain unemployed after the 2-year post-NYSC grace period, you must submit a sworn affidavit of unemployment and periodic statutory declarations to NELFUND. Repayment is suspended without interest or penalties until you secure employment.',
      statutoryReference: 'Section 5.1(c) (Unemployment Declaration)',
      category: FaqCategory.repayment,
    ),
    FaqItem(
      id: 'rep_6',
      question: 'What are my reporting duties when I get a job or change employers?',
      answer:
          'Under Section 5.1(b), within 30 days of securing employment, you must submit your employer’s name, address, monthly salary, and loan ID to NELFUND. If you switch jobs, you must report the change to NELFUND within 30 days.',
      statutoryReference: 'Section 5.1(b) (Beneficiary Obligations)',
      category: FaqCategory.repayment,
    ),

    // --- Default & Legal Recovery ---
    FaqItem(
      id: 'def_1',
      question: 'What is the Global Standing Instruction (GSI) mandate?',
      answer:
          'The Global Standing Instruction (GSI) is a Central Bank of Nigeria (CBN) financial recovery instrument. Under Section 5.3, willful defaulters will have their outstanding loan amount automatically swept and debited from any and all commercial bank accounts linked to their BVN and NIN nationwide.',
      statutoryReference: 'Section 5.3(d) (GSI Auto-Debit)',
      category: FaqCategory.defaultRecovery,
    ),
    FaqItem(
      id: 'def_2',
      question: 'Will defaulting affect my ability to get bank loans or credit cards?',
      answer:
          'Yes. Under Section 5.3(b), defaulters are formally reported to the Central Bank’s Credit Risk Management System (CRMS) and private Credit Bureaus. This blacklists you from securing bank loans, car financing, mortgages, or credit cards across all Nigerian financial institutions.',
      statutoryReference: 'Section 5.3(b) (CRMS Blacklisting)',
      category: FaqCategory.defaultRecovery,
    ),
    FaqItem(
      id: 'def_3',
      question: 'Can NELFUND publish the names of defaulters publicly?',
      answer:
          'Yes. Section 5.3(c) explicitly empowers NELFUND to publish the names, photographs, institution attended, and outstanding debt balances of chronic loan defaulters in national daily newspapers and public gazettes.',
      statutoryReference: 'Section 5.3(c) (Publication of Defaulters)',
      category: FaqCategory.defaultRecovery,
    ),
    FaqItem(
      id: 'def_4',
      question: 'Can legal prosecution or court action be taken against defaulters?',
      answer:
          'Yes. Where warning notices, credit blacklisting, and GSI sweeps fail to recover the debt, NELFUND will institute legal action in the Federal High Court to recover the outstanding balance plus statutory legal recovery costs.',
      statutoryReference: 'Section 5.3(e) (Legal Prosecution)',
      category: FaqCategory.defaultRecovery,
    ),
  ];
}
