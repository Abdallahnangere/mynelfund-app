import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EligibilityProvider>();
    final report = provider.report;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Eligibility Checker'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: provider.reset,
          child: const Text('Reset'),
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
            const SizedBox(height: 12),
            _buildAcademicStreamSelector(context, provider),
            const SizedBox(height: 16),
            _buildDiagnosticResultCard(context, report),
            const SizedBox(height: 16),
            _buildSectionHeader('1. Core Criteria (Section 2.0)'),
            _buildCoreCriteriaSection(context, provider),
            const SizedBox(height: 16),
            _buildSectionHeader('2. KYC Readiness (Section 2.3)'),
            _buildKycReadinessSection(context, provider),
            const SizedBox(height: 16),
            _buildSectionHeader('3. Disqualification Screener (Section 3.0)'),
            _buildDisqualificationSection(context, provider),
            const SizedBox(height: 16),
            _buildLegalDisclaimer(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Official Eligibility Audit',
            style: NelfundTypography.title2.copyWith(
              color: NelfundColors.emeraldTint,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Verify your qualification status against the Students Loans Act 2024. Check off your credentials and screen for statutory disqualifications below.',
            style: NelfundTypography.body.copyWith(
              color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel, context),
              fontSize: 14,
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
                  NelfundColors.label, context),
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
          if (isEligible) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: NelfundColors.emerald.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.arrow_right_circle_fill,
                    size: 16,
                    color: NelfundColors.emerald,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ready to apply! Visit official portal: nelf.gov.ng',
                      style: NelfundTypography.captionBold.copyWith(
                        color: NelfundColors.emerald,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
                  NelfundColors.secondaryLabel, context),
            ),
          ),
          const SizedBox(height: 12),
          _buildDisqualificationSwitchRow(
            title: 'Prior Education Loan Default',
            subtitle: 'Defaulted on any prior FG or state education loan.',
            value: provider.hasPriorLoanDefault,
            onChanged: provider.togglePriorLoanDefault,
          ),
          _buildDisqualificationSwitchRow(
            title: 'Concurrent Scholarship / Loan Beneficiary',
            subtitle: 'Currently receiving another FG or state education loan or scholarship.',
            value: provider.hasActiveScholarship,
            onChanged: provider.toggleActiveScholarship,
          ),
          _buildDisqualificationSwitchRow(
            title: 'Institutional Misconduct or Malpractice',
            subtitle: 'Found culpable of plagiarism, cultism, violence, exam malpractice dismissal, or forged papers.',
            value: provider.hasAcademicMisconduct,
            onChanged: provider.toggleAcademicMisconduct,
          ),
          _buildDisqualificationSwitchRow(
            title: 'Criminal Conviction',
            subtitle: 'Convicted of fraud, forgery, drug offences, felony, or dishonesty.',
            value: provider.hasCriminalConviction,
            onChanged: provider.toggleCriminalConviction,
          ),
          _buildDisqualificationSwitchRow(
            title: 'Holder of First Degree',
            subtitle: 'Already possesses a bachelor’s degree or higher equivalent.',
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
    return Container(
      decoration: BoxDecoration(
        border: !isLast
            ? const Border(
                bottom: BorderSide(color: Color(0x14000000), width: 0.5),
              )
            : null,
      ),
      child: CupertinoListTile(
        title: Text(title, style: NelfundTypography.headline.copyWith(fontSize: 14)),
        subtitle: Text(subtitle, style: NelfundTypography.footnote.copyWith(fontSize: 12)),
        trailing: CupertinoSwitch(
          activeTrackColor: NelfundColors.emerald,
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDisqualificationSwitchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: NelfundTypography.headline.copyWith(
                    fontSize: 14,
                    color: value ? CupertinoColors.systemRed : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: NelfundTypography.footnote.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          CupertinoSwitch(
            activeTrackColor: CupertinoColors.systemRed,
            value: value,
            onChanged: onChanged,
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
              NelfundColors.tertiaryLabel, context),
        ),
      ),
    );
  }
}
