import 'package:flutter/cupertino.dart';

import '../../../../core/localization/app_locale.dart';
import '../../../../core/theme/nelfund_colors.dart';
import '../../../../core/theme/nelfund_typography.dart';
import '../../../../shared/widgets/apple_frosted_card.dart';
import '../../domain/eligibility_model.dart';

/// Displays live diagnostic breakdown across Section 1 (Core Criteria), Section 2
/// (KYC Readiness), and Section 3 (Disqualification Record).
class EligibilityDiagnosticCard extends StatelessWidget {
  /// Creates an [EligibilityDiagnosticCard].
  const EligibilityDiagnosticCard({
    super.key,
    required this.report,
    required this.language,
    required this.onLaunchPortal,
  });

  /// Computed eligibility evaluation report.
  final EligibilityReport report;

  /// Active language.
  final AppLanguage language;

  /// Invoked when tapping the official portal CTA button.
  final VoidCallback onLaunchPortal;

  @override
  Widget build(BuildContext context) {
    final isEligible = report.isLikelyEligible;
    final hasDisqualifiers = report.hasDisqualifiers;
    final isHa = language == AppLanguage.hausa;

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
                    fontWeight: FontWeight.w600,
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
          _EvaluationSectionBox(
            title: isHa
                ? 'Sashe na 1: Muhimman Sharudda'
                : 'Section 1: Core Criteria',
            statusTag: isHa
                ? '${report.coreMetCount}/${report.coreTotalCount} Sun Cika'
                : '${report.coreMetCount}/${report.coreTotalCount} Met',
            isSuccess: report.coreMetCount == report.coreTotalCount,
            child: _PendingOrSuccessList(
              isEmptySuccess: report.coreMetCount == report.coreTotalCount,
              successText: isHa
                  ? '✓ Dukkan muhimman sharuddan doka 4 sun cika (Zama Ɗan Ƙasa, Makarantar Gwamnati, Matsayin Karatu, da Loda Bayanan SVS).'
                  : '✓ All 4 core statutory criteria satisfied (Citizenship, Public Institution, Admission, and SVS data uploaded).',
              pendingTitle: isHa
                  ? 'Sharuddan da ba a cika ba tukuna:'
                  : 'Pending Core Requirements:',
              items: report.pendingCoreCriteria,
              bulletPrefix: '! ',
              itemColor: CupertinoColors.systemOrange,
            ),
          ),
          const SizedBox(height: 12),
          _EvaluationSectionBox(
            title: isHa
                ? 'Sashe na 2: Shirye-shiryen KYC'
                : 'Section 2: KYC Readiness',
            statusTag: isHa
                ? '${report.kycMetCount}/${report.kycTotalCount} A Shirye'
                : '${report.kycMetCount}/${report.kycTotalCount} Ready',
            isSuccess: report.kycMetCount == report.kycTotalCount,
            child: _PendingOrSuccessList(
              isEmptySuccess: report.kycMetCount == report.kycTotalCount,
              successText: isHa
                  ? '✓ Dukkan takardun KYC 6 na wajibi an shirya su domin lodawa.'
                  : '✓ All 6 mandatory KYC documents prepared and ready for upload.',
              pendingTitle: isHa
                  ? 'Takardun da ba a kammala ba:'
                  : 'Documents Pending Preparation:',
              items: report.pendingKycItems,
              bulletPrefix: '• ',
              itemColor: CupertinoColors.systemOrange,
            ),
          ),
          const SizedBox(height: 12),
          _EvaluationSectionBox(
            title: isHa
                ? 'Sashe na 3: Shingen Doka Masu Hana Bashi'
                : 'Section 3: Disqualification Record',
            statusTag: hasDisqualifiers
                ? (isHa
                      ? '${report.disqualifierCount} Shinge Ya Hana'
                      : '${report.disqualifierCount} Active Bar(s)')
                : (isHa ? 'Tarihi Mai Kyau' : 'Clean Record'),
            isSuccess: !hasDisqualifiers,
            isCriticalError: hasDisqualifiers,
            child: _PendingOrSuccessList(
              isEmptySuccess: !hasDisqualifiers,
              successText: isHa
                  ? '✓ An Wanke: Babu wani dalili na hana bashi ƙarƙashin Sashe na 3.0 na Dokar 2024.'
                  : '✓ Cleared: 0 disqualification factors flagged under Section 3.0 of the 2024 Act.',
              pendingTitle: isHa
                  ? 'Abubuwan da suka hana cancanta:'
                  : 'Triggered Disqualification Factor(s):',
              items: report.activeDisqualifiers,
              bulletPrefix: '✕ ',
              itemColor: CupertinoColors.systemRed,
              tintItemsWithColor: true,
            ),
          ),
          if (!isEligible) ...[
            const SizedBox(height: 14),
            _IneligibleExplanationBox(
              isHa: isHa,
              hasDisqualifiers: hasDisqualifiers,
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 13),
              color: isEligible
                  ? NelfundColors.emerald
                  : CupertinoColors.systemGrey,
              borderRadius: BorderRadius.circular(12),
              onPressed: onLaunchPortal,
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
                  Flexible(
                    child: Text(
                      isEligible
                          ? (isHa
                                ? 'Bude Shafin Hukumar NELFUND (nelf.gov.ng)'
                                : 'Open NELFUND Portal (nelf.gov.ng)')
                          : (isHa
                                ? 'Ziyarci Shafin Hukuma domin Jagorori'
                                : 'Visit Official Portal for Guidelines'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
                      ),
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
}

class _EvaluationSectionBox extends StatelessWidget {
  const _EvaluationSectionBox({
    required this.title,
    required this.statusTag,
    required this.isSuccess,
    this.isCriticalError = false,
    required this.child,
  });

  final String title;
  final String statusTag;
  final bool isSuccess;
  final bool isCriticalError;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tagColor = isSuccess
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
        border: Border.all(color: tagColor.withValues(alpha: 0.28), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: NelfundTypography.headline.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
                    fontWeight: FontWeight.w600,
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
}

class _PendingOrSuccessList extends StatelessWidget {
  const _PendingOrSuccessList({
    required this.isEmptySuccess,
    required this.successText,
    required this.pendingTitle,
    required this.items,
    required this.bulletPrefix,
    required this.itemColor,
    this.tintItemsWithColor = false,
  });

  final bool isEmptySuccess;
  final String successText;
  final String pendingTitle;
  final List<String> items;
  final String bulletPrefix;
  final Color itemColor;
  final bool tintItemsWithColor;

  @override
  Widget build(BuildContext context) {
    if (isEmptySuccess) {
      return Text(
        successText,
        style: const TextStyle(
          color: NelfundColors.emerald,
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          pendingTitle,
          style: NelfundTypography.captionBold.copyWith(color: itemColor),
        ),
        const SizedBox(height: 4),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bulletPrefix,
                  style: TextStyle(
                    color: itemColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: NelfundTypography.footnote.copyWith(
                      fontSize: 12,
                      color: tintItemsWithColor ? itemColor : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _IneligibleExplanationBox extends StatelessWidget {
  const _IneligibleExplanationBox({
    required this.isHa,
    required this.hasDisqualifiers,
  });

  final bool isHa;
  final bool hasDisqualifiers;

  @override
  Widget build(BuildContext context) {
    final accent = hasDisqualifiers
        ? CupertinoColors.systemRed
        : CupertinoColors.systemOrange;

    return Container(
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
        border: Border.all(color: accent.withValues(alpha: 0.3), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.question_circle_fill,
                size: 16,
                color: accent,
              ),
              const SizedBox(width: 6),
              Text(
                isHa
                    ? 'Cikakken Bayani: Me Ya Faru?'
                    : 'Full Breakdown: What Happened?',
                style: NelfundTypography.headline.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            hasDisqualifiers
                ? (isHa
                      ? 'Ƙarƙashin Sashe na 3.0 da Sashe na 4.1.3 na Dokar Lamunin Ɗalibai ta 2024, kasancewar kowane shinge na hana bashi yana dakatar da bayar da kuɗi daga asusun. Idan an danna wani abu bisa kuskure a Sashe na 3, cire alamar domin sake dubawa.'
                      : 'Under Section 3.0 and Section 4.1.3 of the Students Loans Act 2024, the presence of any active disqualification bar prevents disbursement from the Fund. If any of the conditions flagged above was selected in error, uncheck the item in Section 3 to re-evaluate.')
                : (isHa
                      ? 'Ba a kai ga tabbatar da cancantarka ba saboda ba a kammala cika ɗaya ko fiye na muhimman sharuddan Sashe na 1 ba. Da fatan za a tabbatar da cewa shigar makarantarku ingantacciya ce, makarantarku ta gwamnati ce, kuma hukumar makarantarku ta loda bayananku a Tsarin Tabbatar da Ɗalibai na NELFUND (SVS).'
                      : 'Your eligibility cannot be cleared yet because one or more core statutory requirements in Section 1 remain unfulfilled. Please ensure your admission is valid, that your institution is a public tertiary institution, and that your school management has uploaded student data to the NELFUND Student Verification System (SVS).'),
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
    );
  }
}
