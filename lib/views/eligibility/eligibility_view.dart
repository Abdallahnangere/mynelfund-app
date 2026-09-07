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
    final bool hasDisqualifiers = report.disqualificationReasons.isNotEmpty;

    AnalyticsService.instance.logEligibilityCheck(
      isEligible: isEligible,
      metCriteriaCount: report.passedCriteria.length,
      unmetCount: report.pendingRequirements.length,
      disqualifierCount: report.disqualificationReasons.length,
    );

    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              children: [
                Icon(
                  isEligible
                      ? CupertinoIcons.checkmark_seal_fill
                      : (hasDisqualifiers
                          ? CupertinoIcons.xmark_octagon_fill
                          : CupertinoIcons.exclamationmark_triangle_fill),
                  size: 42,
                  color: isEligible
                      ? NelfundColors.emerald
                      : (hasDisqualifiers
                          ? CupertinoColors.systemRed
                          : CupertinoColors.systemOrange),
                ),
                const SizedBox(height: 10),
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
                  isEligible
                      ? 'Congratulations! You have satisfied all statutory criteria and mandatory KYC prerequisites under the Students Loans Act 2024 with zero disqualifying records.'
                      : (hasDisqualifiers
                          ? 'You are currently ineligible due to statutory disqualification bar(s) under Section 3.0 of the Act:'
                          : 'You have not yet met all mandatory criteria under the Act. The following requirements remain pending:'),
                  style: const TextStyle(fontSize: 13, height: 1.35),
                ),
                if (hasDisqualifiers) ...[
                  const SizedBox(height: 10),
                  ...report.disqualificationReasons.map(
                    (reason) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
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
                if (!hasDisqualifiers && report.pendingRequirements.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ...report.pendingRequirements.map(
                    (req) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
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
                              req,
                              style: const TextStyle(
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
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          'Eligibility Checker',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            fontSize: 17,
          ),
        ),
        backgroundColor: CupertinoDynamicColor.resolve(
          const CupertinoDynamicColor.withBrightness(
            color: Color(0xCCF8FAF8),
            darkColor: Color(0xCC161718),
          ),
          context,
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            _buildIntroHeader(context),
            const SizedBox(height: 14),
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
    );
  }

  Widget _buildIntroHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        'Assess your statutory eligibility under the Student Loans Act 2024 across admissions criteria, KYC documentation, and legal disqualification bars. Check all verified requirements that you satisfy.',
        style: NelfundTypography.body.copyWith(
          color: CupertinoDynamicColor.resolve(
            NelfundColors.secondaryLabel,
            context,
          ),
          fontSize: 14.5,
          height: 1.4,
        ),
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
    final bool hasDisqualifiers = report.disqualificationReasons.isNotEmpty;

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
      borderColor: badgeColor.withValues(alpha: 0.4),
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
          Row(
            children: [
              Icon(badgeIcon, color: badgeColor, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  report.summaryTitle,
                  style: NelfundTypography.headline.copyWith(
                    color: badgeColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            report.summaryMessage,
            style: NelfundTypography.body.copyWith(
              fontSize: 14,
              color: CupertinoDynamicColor.resolve(
                NelfundColors.label,
                context,
              ),
            ),
          ),
          if (hasDisqualifiers) ...[
            const SizedBox(height: 10),
            Text(
              'Disqualifying Trigger(s):',
              style: NelfundTypography.captionBold.copyWith(
                color: CupertinoColors.systemRed,
              ),
            ),
            const SizedBox(height: 4),
            ...report.disqualificationReasons.map(
              (reason) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('✕ ',
                        style: TextStyle(color: CupertinoColors.systemRed)),
                    Expanded(
                      child: Text(
                        reason,
                        style: NelfundTypography.footnote.copyWith(
                          color: CupertinoColors.systemRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (!hasDisqualifiers && report.pendingRequirements.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Pending Requirements:',
              style: NelfundTypography.captionBold.copyWith(
                color: CupertinoColors.systemOrange,
              ),
            ),
            const SizedBox(height: 4),
            ...report.pendingRequirements.map(
              (req) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('! ',
                        style: TextStyle(color: CupertinoColors.systemOrange)),
                    Expanded(
                      child: Text(
                        req,
                        style: NelfundTypography.footnote,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: isEligible
                  ? NelfundColors.emerald
                  : CupertinoColors.systemGrey,
              borderRadius: BorderRadius.circular(10),
              onPressed: () => _launchNelfundPortal(context),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.globe,
                    size: 18,
                    color: CupertinoColors.white,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Open NELFUND Portal (nelf.gov.ng)',
                    style: TextStyle(
                      fontSize: 14,
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
