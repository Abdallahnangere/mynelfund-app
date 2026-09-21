import '../core/localization/app_locale.dart';

enum SlaStage {
  etiVerification,
  nelfundEvaluation,
  approval,
  disbursement,
  etiReceipt,
}

enum SlaHealthStatus {
  onTrack,
  approachingDeadline,
  overdue,
}

class SlaStageInfo {
  final SlaStage stage;
  final int stageNumber;
  final String title;
  final String durationLabel;
  final int allowedDays;
  final bool isWorkingDays;
  final String actor;
  final String description;
  final String milestone;
  final String escalationAction;

  final String titleHa;
  final String durationLabelHa;
  final String actorHa;
  final String descriptionHa;
  final String milestoneHa;
  final String escalationActionHa;

  const SlaStageInfo({
    required this.stage,
    required this.stageNumber,
    required this.title,
    required this.durationLabel,
    required this.allowedDays,
    required this.isWorkingDays,
    required this.actor,
    required this.description,
    required this.milestone,
    required this.escalationAction,
    required this.titleHa,
    required this.durationLabelHa,
    required this.actorHa,
    required this.descriptionHa,
    required this.milestoneHa,
    required this.escalationActionHa,
  });

  String getTitle(AppLanguage lang) =>
      lang == AppLanguage.hausa ? titleHa : title;

  String getDurationLabel(AppLanguage lang) =>
      lang == AppLanguage.hausa ? durationLabelHa : durationLabel;

  String getActor(AppLanguage lang) =>
      lang == AppLanguage.hausa ? actorHa : actor;

  String getDescription(AppLanguage lang) =>
      lang == AppLanguage.hausa ? descriptionHa : description;

  String getMilestone(AppLanguage lang) =>
      lang == AppLanguage.hausa ? milestoneHa : milestone;

  String getEscalationAction(AppLanguage lang) =>
      lang == AppLanguage.hausa ? escalationActionHa : escalationAction;

  static const List<SlaStageInfo> allStages = [
    SlaStageInfo(
      stage: SlaStage.etiVerification,
      stageNumber: 1,
      title: 'Institution (ETI) SVS Verification',
      durationLabel: '20 Working Days',
      allowedDays: 20,
      isWorkingDays: true,
      actor: 'Institution Desk Officer / SVS',
      description:
          'Your tertiary institution validates your matriculation/JAMB details, enrollment status, and official tuition schedule on the NELFUND Student Verification System (SVS).',
      milestone: 'Verified candidate roster submitted to NELFUND',
      escalationAction:
          'Contact your institution’s Dean of Student Affairs or designated NELFUND Desk Officer with your Matric/JAMB number.',
      titleHa: 'Tantancewa a Tsarin SVS na Makaranta',
      durationLabelHa: 'Kwanakin Aiki 20',
      actorHa: 'Jami\'in Makarantarku a Hukumar Dalibai / SVS',
      descriptionHa:
          'Makarantarku za ta tantance lambar JAMB, shigar dalibi da tsarin kudin makaranta a tsarin NELFUND SVS.',
      milestoneHa: 'Tura sunayen daliban da aka tantance zuwa NELFUND',
      escalationActionHa:
          'Tuntubi Shugaban Sashen Dalibai (Dean of Student Affairs) ko jami\'in NELFUND na makarantarku tare da lambar rajistarku.',
    ),
    SlaStageInfo(
      stage: SlaStage.nelfundEvaluation,
      stageNumber: 2,
      title: 'NELFUND Application Evaluation',
      durationLabel: '15 Calendar Days',
      allowedDays: 15,
      isWorkingDays: false,
      actor: 'NELFUND Evaluation Directorate',
      description:
          'Comprehensive background check: NIN verification with NIMC, BVN match with NIBSS, JAMB CAPS admission confirmation, and Section 3.0 disqualification screening.',
      milestone: 'Candidate recommended for formal approval',
      escalationAction:
          'Check nelf.gov.ng application portal for any KYC discrepancy flags, or email support@nelf.gov.ng.',
      titleHa: 'Tantancewar Hukumar NELFUND',
      durationLabelHa: 'Kwanaki 15 a Kalanda',
      actorHa: 'Sashen Bincike na NELFUND',
      descriptionHa:
          'Binciken asalin lambar NIN a NIMC, lambar BVN a NIBSS, takardar shiga a JAMB CAPS da binciken shingen doka na Sashe na 3.0.',
      milestoneHa: 'Ba da shawarar amincewa da dalibi a hukumance',
      escalationActionHa:
          'Bincika shafinku a nelf.gov.ng domin ganin ko akwai kuskuren bayani, ko tura imel zuwa support@nelf.gov.ng.',
    ),
    SlaStageInfo(
      stage: SlaStage.approval,
      stageNumber: 3,
      title: 'Executive Approval & Allocation',
      durationLabel: '10 Working Days',
      allowedDays: 10,
      isWorkingDays: true,
      actor: 'Fund Executive Management Committee',
      description:
          'Final executive sanction of institutional tuition allocation and student monthly upkeep stipends. Official approval notices generated.',
      milestone: 'Application status marked "Approved"',
      escalationAction:
          'Monitor your registered email and SMS for formal approval notification and payment schedule.',
      titleHa: 'Amincewar Hukumar Zartarwa',
      durationLabelHa: 'Kwanakin Aiki 10',
      actorHa: 'Kwamitin Zartarwa na NELFUND',
      descriptionHa:
          'Amincewa ta karshe kan fitar da kudaden makaranta da alawus na dalibi, tare da fitar da takardun amincewa.',
      milestoneHa: 'Sauya matsayin fom zuwa "Approved" (An Amince)',
      escalationActionHa:
          'Kula da sakon imel da wayarku domin samun takardar amincewa ta hukuma da tsarin biya.',
    ),
    SlaStageInfo(
      stage: SlaStage.disbursement,
      stageNumber: 4,
      title: 'Electronic Fund Disbursement',
      durationLabel: '10 Working Days',
      allowedDays: 10,
      isWorkingDays: true,
      actor: 'Central Bank of Nigeria / Commercial Banks',
      description:
          '100% of approved tuition is electronically wired directly to your tertiary institution’s bank account. Upkeep (₦20,000/mo) is scheduled for direct credit to your personal bank account.',
      milestone: 'Funds debited from NELFUND treasury and credited to ETI',
      escalationAction:
          'File a formal inquiry with NELFUND disbursement desk if your institution has not acknowledged payment within 10 working days.',
      titleHa: 'Fitar da Kudade ta Banki',
      durationLabelHa: 'Kwanakin Aiki 10',
      actorHa: 'Babban Bankin Najeriya (CBN) / Bankunan Kasuwanci',
      descriptionHa:
          'Tura kudin makaranta 100% kai-tsaye zuwa asusun makaranta, da tsara tura alawus na ₦20,000 zuwa asusun dalibi na kashin kai.',
      milestoneHa: 'Cire kudi daga baitulmalin NELFUND tare da shigar da su asusun makaranta',
      escalationActionHa:
          'Tuntubi ofishin biyan kudi na NELFUND idan makarantarku ba ta tabbatar da samun kudin ba bayan kwanakin aiki 10.',
    ),
    SlaStageInfo(
      stage: SlaStage.etiReceipt,
      stageNumber: 5,
      title: 'ETI Official Receipt & Clearance',
      durationLabel: '7 Working Days',
      allowedDays: 7,
      isWorkingDays: true,
      actor: 'Institution Bursary / Student Affairs',
      description:
          'Upon confirming NELFUND funds, your institution issues an official payment receipt, credits your student portal, and grants exam clearance.',
      milestone: 'Official Bursary receipt issued and exam clearance granted',
      escalationAction:
          'Present your NELFUND disbursement notification and Application ID to your school bursary department.',
      titleHa: 'Tabbatarwar Makarantarku & Izinin Jarrabawa',
      durationLabelHa: 'Kwanakin Aiki 7',
      actorHa: 'Sashen Kudi na Makarantarku (Bursary)',
      descriptionHa:
          'Bayar da rasidin makaranta na hukuma, sabunta shafinku na makaranta, da ba ku izinin zana jarrabawa.',
      milestoneHa: 'Fitar da rasidin Bursary na hukuma da ba da izinin jarrabawa',
      escalationActionHa:
          'Nuna shaidar biyan kudi ta NELFUND da lambar neman lamuninku a ofishin kudi (Bursary) na makarantarku.',
    ),
  ];

  static SlaStageInfo getFor(SlaStage stage) {
    return allStages.firstWhere((s) => s.stage == stage);
  }
}

class SlaEvaluationResult {
  final DateTime submissionDate;
  final SlaStageInfo stageInfo;
  final int elapsedCalendarDays;
  final int elapsedWorkingDays;
  final SlaHealthStatus healthStatus;
  final String statusTitle;
  final String diagnosis;
  final String actionableAdvice;

  const SlaEvaluationResult({
    required this.submissionDate,
    required this.stageInfo,
    required this.elapsedCalendarDays,
    required this.elapsedWorkingDays,
    required this.healthStatus,
    required this.statusTitle,
    required this.diagnosis,
    required this.actionableAdvice,
  });

  int get relevantElapsedDays =>
      stageInfo.isWorkingDays ? elapsedWorkingDays : elapsedCalendarDays;

  int get daysRemaining => stageInfo.allowedDays - relevantElapsedDays;
}
