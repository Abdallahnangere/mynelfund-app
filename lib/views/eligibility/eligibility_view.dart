import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/analytics_service.dart';
import '../../core/theme/nelfund_colors.dart';
import '../../core/theme/nelfund_typography.dart';
import '../../models/eligibility_model.dart';
import '../../providers/eligibility_provider.dart';
import '../../widgets/apple_frosted_card.dart';

class EligibilityView extends StatelessWidget {
  const EligibilityView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EligibilityProvider(),
      child: const _EligibilityContent(),
    );
  }
}

class _EligibilityContent extends StatelessWidget {
  const _EligibilityContent();

  Future<void> _launchNelfundPortal(BuildContext context) async {
    AnalyticsService.instance.logExternalLink(
      destination: 'NELFUND Application Portal',
      url: 'https://nelf.gov.ng',
    );
    final uri = Uri.parse('https://nelf.gov.ng');
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        _showUrlFallbackDialog(context);
      }
    } catch (_) {
      if (context.mounted) {
        _showUrlFallbackDialog(context);
      }
    }
  }

  void _showUrlFallbackDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Official Portal'),
        content: const Text(
          'Please visit the official NELFUND application portal in your browser at: https://nelf.gov.ng',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  void _showEligibilityModal(BuildContext context, EligibilityReport report) {
    final bool isEligible = report.isLikelyEligible;
    final bool hasDisqualifiers = report.hasDisqualifiers;

    AnalyticsService.instance.logEligibilityCheck(
      isEligible: isEligible,
      metCriteriaCount: report.coreMetCount + report.kycMetCount,
      unmetCount: report.pendingCoreCriteria.length + report.pendingKycItems.length,
      disqualifierCount: report.disqualifierCount,
    );

    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final Color statusColor = isEligible
            ? NelfundColors.emerald
            : (hasDisqualifiers
                ? CupertinoColors.systemRed
                : CupertinoColors.systemOrange);

        return CupertinoAlertDialog(
          title: Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Column(
              children: [
                Icon(
                  isEligible
                      ? CupertinoIcons.checkmark_seal_fill
                      : (hasDisqualifiers
                          ? CupertinoIcons.xmark_octagon_fill
                          : CupertinoIcons.exclamationmark_triangle_fill),
                  size: 42,
                  color: statusColor,
                ),
                const SizedBox(height: 8),
                Text(
                  isEligible
                      ? 'Statutory Criteria Satisfied'
                      : (hasDisqualifiers
                          ? 'Statutory Disqualification'
                          : 'Incomplete Requirements'),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  report.summaryMessage,
                  style: const TextStyle(fontSize: 13, height: 1.35),
                ),
                const SizedBox(height: 12),

                // Section 1 Breakdown
                Text(
                  '1. Core Criteria (${report.coreMetCount}/${report.coreTotalCount} Met)',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 4),
                if (report.pendingCoreCriteria.isEmpty)
                  const Text(
                    '✓ All statutory core criteria confirmed.',
                    style: TextStyle(
                      color: NelfundColors.emerald,
                      fontSize: 12,
                    ),
                  )
                else
                  ...report.pendingCoreCriteria.map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '! ',
                            style: TextStyle(
                              color: CupertinoColors.systemOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              p,
                              style: const TextStyle(
                                fontSize: 11.5,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 10),

                // Section 2 Breakdown
                Text(
                  '2. KYC Readiness (${report.kycMetCount}/${report.kycTotalCount} Ready)',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 4),
                if (report.pendingKycItems.isEmpty)
                  const Text(
                    '✓ All mandatory KYC documents verified.',
                    style: TextStyle(
                      color: NelfundColors.emerald,
                      fontSize: 12,
                    ),
                  )
                else
                  ...report.pendingKycItems.map(
                    (k) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(
                              color: CupertinoColors.systemOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              k,
                              style: const TextStyle(
                                fontSize: 11.5,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 10),

                // Section 3 Breakdown
                const Text(
                  '3. Disqualification Bars',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 4),
                if (!hasDisqualifiers)
                  const Text(
                    '✓ Clean Record: 0 active disqualification bars.',
                    style: TextStyle(
                      color: NelfundColors.emerald,
                      fontSize: 12,
                    ),
                  )
                else ...[
                  ...report.activeDisqualifiers.map(
                    (reason) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '✕ ',
                            style: TextStyle(
                              color: CupertinoColors.systemRed,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              reason,
                              style: const TextStyle(
                                color: CupertinoColors.systemRed,
                                fontSize: 11.5,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            if (isEligible)
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _launchNelfundPortal(context);
                },
                child: const Text(
                  'Proceed to Portal (nelf.gov.ng)',
                  style: TextStyle(
                    color: NelfundColors.emerald,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            CupertinoDialogAction(
              isDestructiveAction: !isEligible,
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(isEligible ? 'Close' : 'Review Checklist'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EligibilityProvider>();
    final report = provider.report;

    return CupertinoPageScaffold(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildFintechHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 14),
                children: [
                  _buildStepGuideCard(context),
                  const SizedBox(height: 16),
                  _buildAcademicStreamSelector(context, provider),
                  const SizedBox(height: 16),
                  _buildSectionHeader('1. Statutory Core Criteria'),
                  _buildCoreCriteriaSection(context, provider),
                  const SizedBox(height: 16),
                  _buildSectionHeader('2. KYC & Identity Verification'),
                  _buildKycReadinessSection(context, provider),
                  const SizedBox(height: 16),
                  _buildSectionHeader('3. Statutory Disqualification Bars'),
                  _buildDisqualificationSection(context, provider),
                  const SizedBox(height: 20),
                  _buildEvaluateButton(context, report),
                  const SizedBox(height: 20),
                  _buildDiagnosticResultCard(context, report),
                  const SizedBox(height: 16),
                  _buildLegalDisclaimer(context),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFintechHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          const CupertinoDynamicColor.withBrightness(
            color: Color(0xF2F8FAF8),
            darkColor: Color(0xF2161718),
          ),
          context,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Center(
              child: Text(
                'Eligibility Checker',
                style: NelfundTypography.title2.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
            ),
          ),
          // Green lighting ambient separator bar
          Container(
            height: 2.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  NelfundColors.emerald.withValues(alpha: 0.1),
                  NelfundColors.emerald,
                  NelfundColors.emerald.withValues(alpha: 0.1),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: NelfundColors.emerald.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepGuideCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppleFrostedCard(
        padding: const EdgeInsets.all(16),
        borderColor: NelfundColors.emerald.withValues(alpha: 0.35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: NelfundColors.emerald.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    CupertinoIcons.checkmark_shield_fill,
                    size: 18,
                    color: NelfundColors.emerald,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Student Eligibility Guide',
                    style: NelfundTypography.headline.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Follow through the following steps to check if you are eligible for the NELFund Student Loan:',
              style: NelfundTypography.body.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: CupertinoDynamicColor.resolve(
                  NelfundColors.label,
                  context,
                ),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            _buildGuideStepItem(
              context: context,
              stepNumber: '1',
              title: 'Select Academic Stream',
              description:
                  'Choose whether you are Fresh Entry (100L via JAMB), Direct Entry (200L/DE), or Returning Undergraduate.',
              stepColor: NelfundColors.emerald,
            ),
            const SizedBox(height: 10),
            _buildGuideStepItem(
              context: context,
              stepNumber: '2',
              title: 'Fill Sections 1 & 2',
              description:
                  'Tick every box where you have met the statutory criteria in Section 1 and prepared the required KYC documents in Section 2.',
              stepColor: NelfundColors.emerald,
            ),
            const SizedBox(height: 10),
            _buildGuideStepItem(
              context: context,
              stepNumber: '3',
              title: 'Section 3 (Caution — Disqualifications)',
              description:
                  'Do NOT fill or check any box in Section 3 unless you actually have the disqualifying condition stated therein (such as prior loan default, exam malpractice, or felony).',
              stepColor: CupertinoColors.systemOrange,
              isWarning: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideStepItem({
    required BuildContext context,
    required String stepNumber,
    required String title,
    required String description,
    required Color stepColor,
    bool isWarning = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          CupertinoDynamicColor.withBrightness(
            color: isWarning ? const Color(0x0CFF9500) : const Color(0x0C008751),
            darkColor: isWarning ? const Color(0x18FF9500) : const Color(0x18008751),
          ),
          context,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: stepColor.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: stepColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                stepNumber,
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: NelfundTypography.headline.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: isWarning ? CupertinoColors.systemOrange : null,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: NelfundTypography.footnote.copyWith(
                    fontSize: 12,
                    color: CupertinoDynamicColor.resolve(
                      NelfundColors.secondaryLabel,
                      context,
                    ),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicStreamSelector(
      BuildContext context, EligibilityProvider provider) {
    return AppleFrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Academic Stream',
            style: NelfundTypography.headline.copyWith(fontSize: 15),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: CupertinoSlidingSegmentedControl<AcademicEntryType>(
              groupValue: provider.academicType,
              children: {
                AcademicEntryType.freshEntry: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text('Fresh Entry', style: NelfundTypography.footnote),
                ),
                AcademicEntryType.directEntry: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text('Direct Entry', style: NelfundTypography.footnote),
                ),
                AcademicEntryType.undergraduate: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text('Undergraduate', style: NelfundTypography.footnote),
                ),
              },
              onValueChanged: (val) {
                if (val != null) {
                  provider.setAcademicType(val);
                }
              },
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: CupertinoDynamicColor.resolve(
                const CupertinoDynamicColor.withBrightness(
                  color: Color(0x0C008751),
                  darkColor: Color(0x1F008751),
                ),
                context,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              provider.academicType.description,
              style: NelfundTypography.footnote.copyWith(
                color: NelfundColors.emerald,
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Text(
        title,
        style: NelfundTypography.title3.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCoreCriteriaSection(
      BuildContext context, EligibilityProvider provider) {
    return AppleFrostedCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildCheckRow(
            context: context,
            title: 'Nigerian Citizen (NIN & BVN Verified)',
            subtitle: 'Must be a Nigerian citizen as defined by the Constitution.',
            value: provider.isNigerianCitizen,
            onChanged: provider.toggleNigerianCitizen,
            isFirst: true,
          ),
          _buildCheckRow(
            context: context,
            title: 'Approved Public Tertiary Institution',
            subtitle: 'Enrolled in an eligible Federal/State public university, polytechnic, or college.',
            value: provider.isEnrolledInPublicEti,
            onChanged: provider.toggleEnrolledInPublicEti,
          ),
          _buildCheckRow(
            context: context,
            title: 'Academic Status Verified',
            subtitle: provider.academicType.academicRequirementLabel,
            value: provider.isAcademicAdmissionVerified,
            onChanged: provider.toggleAcademicAdmissionVerified,
          ),
          _buildCheckRow(
            context: context,
            title: 'Uploaded to Student Verification System (SVS)',
            subtitle: 'Your tertiary institution has uploaded your student profile to NELFUND.',
            value: provider.isSchoolDataUploaded,
            onChanged: provider.toggleSchoolDataUploaded,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildKycReadinessSection(
      BuildContext context, EligibilityProvider provider) {
    return AppleFrostedCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildCheckRow(
            context: context,
            title: 'JAMB Registration Number',
            subtitle: 'Validated with the Joint Admissions & Matriculation Board.',
            value: provider.hasJambNumber,
            onChanged: provider.toggleJambNumber,
            isFirst: true,
          ),
          _buildCheckRow(
            context: context,
            title: 'Bank Verification Number (BVN)',
            subtitle: 'Mandatory for all applicants aged 18 years and above (NIBSS).',
            value: provider.hasBvn,
            onChanged: provider.toggleBvn,
          ),
          _buildCheckRow(
            context: context,
            title: 'National Identity Number (NIN)',
            subtitle: 'Verified through NIMC database.',
            value: provider.hasNin,
            onChanged: provider.toggleNin,
          ),
          _buildCheckRow(
            context: context,
            title: 'Personal Contact & Residential Info',
            subtitle: 'Valid phone number, residential address, age, gender, and active email.',
            value: provider.hasPersonalInfo,
            onChanged: provider.togglePersonalInfo,
          ),
          _buildCheckRow(
            context: context,
            title: 'Recent Passport Photograph',
            subtitle: 'Clear digital headshot for identity verification.',
            value: provider.hasPassportPhoto,
            onChanged: provider.togglePassportPhoto,
          ),
          _buildCheckRow(
            context: context,
            title: 'Valid Admission Letter or Student ID',
            subtitle: 'Official proof of studentship from an Eligible Tertiary Institution (ETI).',
            value: provider.hasAdmissionOrStudentId,
            onChanged: provider.toggleAdmissionOrStudentId,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDisqualificationSection(
      BuildContext context, EligibilityProvider provider) {
    return AppleFrostedCard(
      borderColor: CupertinoColors.systemRed.withValues(alpha: 0.3),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.exclamationmark_shield_fill,
                      color: CupertinoColors.systemRed,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Statutory Disqualification Bars',
                        style: NelfundTypography.headline.copyWith(
                          color: CupertinoColors.systemRed,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Under Section 3.0 of the Guidelines, having any of these conditions will automatically disqualify an applicant:',
                  style: NelfundTypography.footnote.copyWith(
                    color: CupertinoDynamicColor.resolve(
                      NelfundColors.secondaryLabel,
                      context,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildDisqualificationCheckRow(
            context: context,
            title: 'Prior Education Loan Default',
            subtitle: 'Defaulted on any prior FG or state education loan.',
            value: provider.hasPriorLoanDefault,
            onChanged: provider.togglePriorLoanDefault,
          ),
          _buildDisqualificationCheckRow(
            context: context,
            title: 'Concurrent Scholarship / Loan Beneficiary',
            subtitle:
                'Currently receiving another FG or state education loan or scholarship.',
            value: provider.hasActiveScholarship,
            onChanged: provider.toggleActiveScholarship,
          ),
          _buildDisqualificationCheckRow(
            context: context,
            title: 'Institutional Misconduct or Malpractice',
            subtitle:
                'Found culpable of plagiarism, cultism, violence, exam malpractice dismissal, or forged papers.',
            value: provider.hasAcademicMisconduct,
            onChanged: provider.toggleAcademicMisconduct,
          ),
          _buildDisqualificationCheckRow(
            context: context,
            title: 'Criminal Conviction',
            subtitle:
                'Convicted of fraud, forgery, drug offences, felony, or dishonesty.',
            value: provider.hasCriminalConviction,
            onChanged: provider.toggleCriminalConviction,
          ),
          _buildDisqualificationCheckRow(
            context: context,
            title: 'Holder of First Degree',
            subtitle:
                'Already possesses a bachelor’s degree or higher equivalent.',
            value: provider.holdsFirstDegree,
            onChanged: provider.toggleHoldsFirstDegree,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckRow({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: !isLast
              ? const Border(
                  bottom: BorderSide(color: Color(0x14000000), width: 0.5),
                )
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: CupertinoCheckbox(
                value: value,
                activeColor: NelfundColors.emerald,
                onChanged: (val) {
                  if (val != null) onChanged(val);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: NelfundTypography.headline.copyWith(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: NelfundTypography.footnote.copyWith(
                      fontSize: 12.5,
                      color: CupertinoDynamicColor.resolve(
                        NelfundColors.secondaryLabel,
                        context,
                      ),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisqualificationCheckRow({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isLast = false,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: !isLast
              ? const Border(
                  bottom: BorderSide(color: Color(0x14000000), width: 0.5),
                )
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: CupertinoCheckbox(
                value: value,
                activeColor: CupertinoColors.systemRed,
                onChanged: (val) {
                  if (val != null) onChanged(val);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: NelfundTypography.headline.copyWith(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: value ? CupertinoColors.systemRed : null,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: NelfundTypography.footnote.copyWith(
                      fontSize: 12.5,
                      color: CupertinoDynamicColor.resolve(
                        NelfundColors.secondaryLabel,
                        context,
                      ),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvaluateButton(BuildContext context, EligibilityReport report) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 14),
        color: NelfundColors.emerald,
        borderRadius: BorderRadius.circular(14),
        onPressed: () => _showEligibilityModal(context, report),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.checkmark_shield_fill,
              size: 20,
              color: CupertinoColors.white,
            ),
            SizedBox(width: 8),
            Text(
              'Evaluate My Eligibility',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: CupertinoColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosticResultCard(
      BuildContext context, EligibilityReport report) {
    final bool isEligible = report.isLikelyEligible;
    final bool hasDisqualifiers = report.hasDisqualifiers;

    final Color badgeColor = isEligible
        ? NelfundColors.emerald
        : (hasDisqualifiers
            ? CupertinoColors.systemRed
            : CupertinoColors.systemOrange);

    final IconData badgeIcon = isEligible
        ? CupertinoIcons.checkmark_seal_fill
        : (hasDisqualifiers
            ? CupertinoIcons.exclamationmark_octagon_fill
            : CupertinoIcons.info_circle_fill);

    return AppleFrostedCard(
      borderColor: badgeColor.withValues(alpha: 0.45),
      backgroundColor: CupertinoDynamicColor.resolve(
        CupertinoDynamicColor.withBrightness(
          color: isEligible
              ? const Color(0xF2F0FBF5)
              : (hasDisqualifiers
                  ? const Color(0xF2FFF4F4)
                  : const Color(0xF2FFFBF0)),
          darkColor: isEligible
              ? const Color(0xD0132B1D)
              : (hasDisqualifiers
                  ? const Color(0xD02D1515)
                  : const Color(0xD02D2415)),
        ),
        context,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Header
          Row(
            children: [
              Icon(badgeIcon, color: badgeColor, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  report.summaryTitle,
                  style: NelfundTypography.headline.copyWith(
                    color: badgeColor,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            report.summaryMessage,
            style: NelfundTypography.body.copyWith(
              fontSize: 14,
              color: CupertinoDynamicColor.resolve(
                NelfundColors.label,
                context,
              ),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),

          // ==========================================
          // SECTION 1 BREAKDOWN: CORE CRITERIA
          // ==========================================
          _buildEvaluationSectionBox(
            context: context,
            title: 'Section 1: Core Criteria',
            statusTag: '${report.coreMetCount}/${report.coreTotalCount} Met',
            isSuccess: report.coreMetCount == report.coreTotalCount,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (report.coreMetCount == report.coreTotalCount)
                  const Text(
                    '✓ All 4 core statutory criteria satisfied (Citizenship, Public Institution, Admission, and SVS data uploaded).',
                    style: TextStyle(
                      color: NelfundColors.emerald,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else ...[
                  Text(
                    'Pending Core Requirements:',
                    style: NelfundTypography.captionBold.copyWith(
                      color: CupertinoColors.systemOrange,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...report.pendingCoreCriteria.map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '! ',
                            style: TextStyle(
                              color: CupertinoColors.systemOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              p,
                              style: NelfundTypography.footnote.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ==========================================
          // SECTION 2 BREAKDOWN: KYC READINESS
          // ==========================================
          _buildEvaluationSectionBox(
            context: context,
            title: 'Section 2: KYC Readiness',
            statusTag: '${report.kycMetCount}/${report.kycTotalCount} Ready',
            isSuccess: report.kycMetCount == report.kycTotalCount,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (report.kycMetCount == report.kycTotalCount)
                  const Text(
                    '✓ All 6 mandatory KYC documents prepared and ready for upload.',
                    style: TextStyle(
                      color: NelfundColors.emerald,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else ...[
                  Text(
                    'Documents Pending Preparation:',
                    style: NelfundTypography.captionBold.copyWith(
                      color: CupertinoColors.systemOrange,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...report.pendingKycItems.map(
                    (k) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(
                              color: CupertinoColors.systemOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              k,
                              style: NelfundTypography.footnote.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ==========================================
          // SECTION 3 BREAKDOWN: DISQUALIFICATION BARS
          // ==========================================
          _buildEvaluationSectionBox(
            context: context,
            title: 'Section 3: Disqualification Record',
            statusTag: hasDisqualifiers
                ? '${report.disqualifierCount} Active Bar(s)'
                : 'Clean Record',
            isSuccess: !hasDisqualifiers,
            isCriticalError: hasDisqualifiers,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!hasDisqualifiers)
                  const Text(
                    '✓ Cleared: 0 disqualification factors flagged under Section 3.0 of the 2024 Act.',
                    style: TextStyle(
                      color: NelfundColors.emerald,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else ...[
                  Text(
                    'Triggered Disqualification Factor(s):',
                    style: NelfundTypography.captionBold.copyWith(
                      color: CupertinoColors.systemRed,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...report.activeDisqualifiers.map(
                    (reason) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '✕ ',
                            style: TextStyle(
                              color: CupertinoColors.systemRed,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              reason,
                              style: NelfundTypography.footnote.copyWith(
                                color: CupertinoColors.systemRed,
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ==========================================
          // WHAT HAPPENED & RESOLUTION BREAKDOWN
          // ==========================================
          if (!isEligible) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CupertinoDynamicColor.resolve(
                  const CupertinoDynamicColor.withBrightness(
                    color: Color(0x0C000000),
                    darkColor: Color(0x20FFFFFF),
                  ),
                  context,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: (hasDisqualifiers
                          ? CupertinoColors.systemRed
                          : CupertinoColors.systemOrange)
                      .withValues(alpha: 0.3),
                  width: 0.8,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.question_circle_fill,
                        size: 16,
                        color: hasDisqualifiers
                            ? CupertinoColors.systemRed
                            : CupertinoColors.systemOrange,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Full Breakdown: What Happened?',
                        style: NelfundTypography.headline.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: hasDisqualifiers
                              ? CupertinoColors.systemRed
                              : CupertinoColors.systemOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    hasDisqualifiers
                        ? 'Under Section 3.0 and Section 4.1.3 of the Students Loans Act 2024, the presence of any active disqualification bar prevents disbursement from the Fund. If any of the conditions flagged above was selected in error, uncheck the item in Section 3 to re-evaluate.'
                        : 'Your eligibility cannot be cleared yet because one or more core statutory requirements in Section 1 remain unfulfilled. Please ensure your admission is valid, that your institution is a public tertiary institution, and that your school management has uploaded student data to the NELFUND Student Verification System (SVS).',
                    style: NelfundTypography.footnote.copyWith(
                      fontSize: 12,
                      height: 1.35,
                      color: CupertinoDynamicColor.resolve(
                        NelfundColors.secondaryLabel,
                        context,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          // Action Button
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 13),
              color: isEligible
                  ? NelfundColors.emerald
                  : CupertinoColors.systemGrey,
              borderRadius: BorderRadius.circular(12),
              onPressed: () => _launchNelfundPortal(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isEligible
                        ? CupertinoIcons.globe
                        : CupertinoIcons.arrow_up_right_circle_fill,
                    size: 18,
                    color: CupertinoColors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEligible
                        ? 'Open NELFUND Portal (nelf.gov.ng)'
                        : 'Visit Official Portal for Guidelines',
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationSectionBox({
    required BuildContext context,
    required String title,
    required String statusTag,
    required bool isSuccess,
    bool isCriticalError = false,
    required Widget child,
  }) {
    final Color tagColor = isSuccess
        ? NelfundColors.emerald
        : (isCriticalError
            ? CupertinoColors.systemRed
            : CupertinoColors.systemOrange);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          const CupertinoDynamicColor.withBrightness(
            color: Color(0x60FFFFFF),
            darkColor: Color(0x301E1E1E),
          ),
          context,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: tagColor.withValues(alpha: 0.28),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: NelfundTypography.headline.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: tagColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: tagColor.withValues(alpha: 0.3),
                    width: 0.6,
                  ),
                ),
                child: Text(
                  statusTag,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: tagColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildLegalDisclaimer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        'Note: This eligibility checker evaluates your criteria against the published 2024 Guidelines for informational purposes. Final determination and clearance rests solely with NELFUND and your tertiary institution’s SVS confirmation.',
        style: NelfundTypography.caption.copyWith(
          color: CupertinoDynamicColor.resolve(
            NelfundColors.tertiaryLabel,
            context,
          ),
        ),
      ),
    );
  }
}
