import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/localization/app_locale.dart';
import '../../core/localization/app_translations.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/services/analytics_service.dart';
import '../../core/theme/nelfund_colors.dart';
import '../../core/theme/nelfund_typography.dart';
import '../../models/eligibility_model.dart';
import '../../providers/eligibility_provider.dart';
import '../../widgets/apple_frosted_card.dart';
import '../../widgets/liquid_glass_header.dart';

class EligibilityView extends StatelessWidget {
  const EligibilityView({super.key});

  @override
  Widget build(BuildContext context) {
    LocaleProvider? localeProv;
    try {
      localeProv = Provider.of<LocaleProvider?>(context, listen: false);
    } catch (_) {}

    final content = ChangeNotifierProvider(
      create: (_) => EligibilityProvider(),
      child: const _EligibilityContent(),
    );

    if (localeProv == null) {
      return ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: content,
      );
    }
    return content;
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
    final tr = AppTranslations.of(context);
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(tr.isHausa ? 'Shafin Hukumar NELFUND' : 'Official Portal'),
        content: Text(
          tr.isHausa
              ? 'Da fatan za a ziyarci shafin cika bashi na hukumar NELFUND a manhajar bincikenka a: https://nelf.gov.ng'
              : 'Please visit the official NELFUND application portal in your browser at: https://nelf.gov.ng',
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(tr.isHausa ? 'Toh' : 'OK'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  void _showEligibilityModal(
    BuildContext context,
    EligibilityReport report,
    AppLanguage lang,
  ) {
    final bool isEligible = report.isLikelyEligible;
    final bool hasDisqualifiers = report.hasDisqualifiers;
    final isHa = lang == AppLanguage.hausa;

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
                      ? (isHa ? 'Sharuddan Doka Sun Cika' : 'Statutory Criteria Satisfied')
                      : (hasDisqualifiers
                          ? (isHa ? 'Shingen Doka Ya Hana Cancanta' : 'Statutory Disqualification')
                          : (isHa ? 'Bayanai Ba Su Kammala Ba' : 'Incomplete Requirements')),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
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
                  isHa
                      ? '1. Muhimman Sharudda (${report.coreMetCount}/${report.coreTotalCount} Sun Cika)'
                      : '1. Core Criteria (${report.coreMetCount}/${report.coreTotalCount} Met)',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 4),
                if (report.pendingCoreCriteria.isEmpty)
                  Text(
                    isHa
                        ? '✓ Dukkan muhimman sharuddan doka an tabbatar da su.'
                        : '✓ All statutory core criteria confirmed.',
                    style: const TextStyle(
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
                              fontWeight: FontWeight.w600,
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
                  isHa
                      ? '2. Shirye-shiryen KYC (${report.kycMetCount}/${report.kycTotalCount} A Shirye)'
                      : '2. KYC Readiness (${report.kycMetCount}/${report.kycTotalCount} Ready)',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 4),
                if (report.pendingKycItems.isEmpty)
                  Text(
                    isHa
                        ? '✓ Dukkan takardun KYC na wajibi an tabbatar da su.'
                        : '✓ All mandatory KYC documents verified.',
                    style: const TextStyle(
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
                              fontWeight: FontWeight.w600,
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
                Text(
                  isHa ? '3. Shingen Doka Masu Hana Bashi' : '3. Disqualification Bars',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 4),
                if (!hasDisqualifiers)
                  Text(
                    isHa
                        ? '✓ Tarihi Mai Kyau: Babu wani shingen doka da ya shafe ka.'
                        : '✓ Clean Record: 0 active disqualification bars.',
                    style: const TextStyle(
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
                              fontWeight: FontWeight.w600,
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
                child: Text(
                  isHa
                      ? 'Bude Shafin Hukumar NELFUND (nelf.gov.ng)'
                      : 'Proceed to Portal (nelf.gov.ng)',
                  style: const TextStyle(
                    color: NelfundColors.emerald,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            CupertinoDialogAction(
              isDestructiveAction: !isEligible,
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                isEligible
                    ? (isHa ? 'Rufe' : 'Close')
                    : (isHa ? 'Duba Jerin Abubuwan da Ake Bukata' : 'Review Checklist'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeProv = context.watch<LocaleProvider>();
    final lang = localeProv.currentLanguage;
    final tr = AppTranslations.of(context);
    final provider = context.watch<EligibilityProvider>();
    final report = provider.getReport(lang);

    return CupertinoPageScaffold(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildFintechHeader(context, tr),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 88),
                children: [
                  _buildAcademicStreamSelector(context, provider, lang, tr),
                  const SizedBox(height: 16),
                  _buildSectionHeader(tr.coreCriteriaTitle),
                  _buildCoreCriteriaSection(context, provider, lang, tr),
                  const SizedBox(height: 16),
                  _buildSectionHeader(tr.kycChecklistTitle),
                  _buildKycReadinessSection(context, provider, lang),
                  const SizedBox(height: 16),
                  _buildSectionHeader(tr.disqualificationBarsTitle),
                  _buildDisqualificationSection(context, provider, lang),
                  const SizedBox(height: 20),
                  _buildEvaluateButton(context, report, lang, tr),
                  const SizedBox(height: 20),
                  _buildDiagnosticResultCard(context, report, lang, tr),
                  const SizedBox(height: 16),
                  _buildLegalDisclaimer(context, tr),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFintechHeader(BuildContext context, AppTranslations tr) {
    return LiquidGlassHeader(
      title: tr.eligibilityHeaderTitle,
      subtitle: tr.isHausa ? 'Binciken Tabbatar da Cancanta' : 'Statutory Diagnostic Checklist',
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: NelfundColors.emerald.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          CupertinoIcons.checkmark_seal_fill,
          color: NelfundColors.emerald,
          size: 22,
        ),
      ),
      trailing: _AnimatedHelpButton(
        isHausa: tr.isHausa,
        onTap: () {
          HapticFeedback.lightImpact();
          _showStudentEligibilityGuideModal(context, tr);
        },
      ),
    );
  }

  void _showStudentEligibilityGuideModal(BuildContext context, AppTranslations tr) {
    final isHa = tr.isHausa;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: isHa ? 'Jagoran Cancantar Dalibi' : 'Student Eligibility Guide',
      barrierColor: CupertinoColors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curvedValue = Curves.easeOutBack.transform(anim1.value);
        return Transform.scale(
          scale: 0.90 + (0.10 * curvedValue),
          child: Opacity(
            opacity: anim1.value.clamp(0.0, 1.0),
            child: Stack(
              children: [
                // 1. Full-window BackdropFilter blur
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(
                      color: CupertinoColors.black.withValues(alpha: 0.20),
                    ),
                  ),
                ),

                // 2. Centered Frosted Liquid Glass Modal Dialog
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 420,
                        maxHeight: MediaQuery.sizeOf(ctx).height * 0.82,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: CupertinoDynamicColor.resolve(
                            const CupertinoDynamicColor.withBrightness(
                              color: Color(0xF2FFFFFF),
                              darkColor: Color(0xF018241C),
                            ),
                            context,
                          ),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: NelfundColors.emerald.withValues(alpha: 0.40),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: NelfundColors.emerald.withValues(alpha: 0.14),
                              blurRadius: 28,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Modal Header Bar with Close Icon
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 18, 16, 12),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: NelfundColors.emerald.withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.checkmark_shield_fill,
                                      size: 20,
                                      color: NelfundColors.emerald,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      isHa ? 'Jagoran Cancantar Dalibi' : 'Student Eligibility Guide',
                                      style: NelfundTypography.headline.copyWith(
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      Navigator.of(ctx).pop();
                                    },
                                    child: Icon(
                                      CupertinoIcons.xmark_circle_fill,
                                      size: 26,
                                      color: CupertinoDynamicColor.resolve(
                                        NelfundColors.secondaryLabel,
                                        context,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              height: 0.8,
                              color: CupertinoDynamicColor.resolve(
                                const CupertinoDynamicColor.withBrightness(
                                  color: Color(0x1F000000),
                                  darkColor: Color(0x2EFFFFFF),
                                ),
                                context,
                              ),
                            ),

                            // Scrollable Guide Steps Body
                            Flexible(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isHa
                                          ? 'Bi wadannan matakai domin duba ko ka cancanci samun bashin NELFUND:'
                                          : 'Follow through the following steps to check if you are eligible for the NELFund Student Loan:',
                                      style: NelfundTypography.body.copyWith(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w400,
                                        color: CupertinoDynamicColor.resolve(
                                          NelfundColors.label,
                                          context,
                                        ),
                                        height: 1.35,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    _buildGuideStepItem(
                                      context: context,
                                      stepNumber: '1',
                                      title: isHa ? 'Zabi Rukunin Karatu' : 'Select Academic Stream',
                                      description: isHa
                                          ? 'Zabi ko kai sabon shiga ne (100L ta JAMB), shigar kai-tsaye (Direct Entry/200L), ko mai ci gaba da karatu.'
                                          : 'Choose whether you are Fresh Entry (100L via JAMB), Direct Entry (200L/DE), or Returning Undergraduate.',
                                      stepColor: NelfundColors.emerald,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildGuideStepItem(
                                      context: context,
                                      stepNumber: '2',
                                      title: isHa ? 'Cika Sashe na 1 da na 2' : 'Fill Sections 1 & 2',
                                      description: isHa
                                          ? 'Danna kowacce alama inda ka cika sharuddan doka a Sashe na 1 tare da shirya takardun KYC a Sashe na 2.'
                                          : 'Tick every box where you have met the statutory criteria in Section 1 and prepared the required KYC documents in Section 2.',
                                      stepColor: NelfundColors.emerald,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildGuideStepItem(
                                      context: context,
                                      stepNumber: '3',
                                      title: isHa
                                          ? 'Sashe na 3 (Gargadi — Abubuwan da Ke Hana Bashi)'
                                          : 'Section 3 (Caution — Disqualifications)',
                                      description: isHa
                                          ? 'KADA ka danna kowane akwati a Sashe na 3 sai dai idan da gaske kana da daya daga cikin abubuwan da ke hana samun bashi (kamar kin biyan wani bashi a baya, magudin jarrabawa, ko aikata babban laifi).'
                                          : 'Do NOT fill or check any box in Section 3 unless you actually have the disqualifying condition stated therein (such as prior loan default, exam malpractice, or felony).',
                                      stepColor: CupertinoColors.systemOrange,
                                      isWarning: true,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Modal Footer Action
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                              child: CupertinoButton(
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                color: NelfundColors.emerald,
                                borderRadius: BorderRadius.circular(16),
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.of(ctx).pop();
                                },
                                child: Center(
                                  child: Text(
                                    isHa ? 'Na Fahimta, Bincika' : 'Got It, Let’s Begin',
                                    style: NelfundTypography.headline.copyWith(
                                      color: CupertinoColors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
                  fontWeight: FontWeight.w600,
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
                    fontWeight: FontWeight.w600,
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
    BuildContext context,
    EligibilityProvider provider,
    AppLanguage lang,
    AppTranslations tr,
  ) {
    return AppleFrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr.academicStreamTitle,
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
                  child: Text(
                    AcademicEntryType.freshEntry.getLocalizedName(lang),
                    style: NelfundTypography.footnote,
                  ),
                ),
                AcademicEntryType.directEntry: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    AcademicEntryType.directEntry.getLocalizedName(lang),
                    style: NelfundTypography.footnote,
                  ),
                ),
                AcademicEntryType.undergraduate: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    AcademicEntryType.undergraduate.getLocalizedName(lang),
                    style: NelfundTypography.footnote,
                  ),
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
              provider.academicType.getLocalizedDescription(lang),
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
    BuildContext context,
    EligibilityProvider provider,
    AppLanguage lang,
    AppTranslations tr,
  ) {
    final isHa = lang == AppLanguage.hausa;

    return AppleFrostedCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildCheckRow(
            context: context,
            title: isHa
                ? 'Ɗan Ƙasa ne na Najeriya (Tantance NIN da BVN)'
                : 'Nigerian Citizen (NIN & BVN Verified)',
            subtitle: isHa
                ? 'Tabbatar da zama ɗan Najeriya ta hanyar lambobin ɗan ƙasa NIN da kuma na banki BVN (Sashe na 2.1)'
                : 'Must be a Nigerian citizen as defined by the Constitution.',
            value: provider.isNigerianCitizen,
            onChanged: provider.toggleNigerianCitizen,
            isFirst: true,
          ),
          _buildCheckRow(
            context: context,
            title: isHa
                ? 'Makarantar Gwamnati da Aka Amince da Ita'
                : 'Approved Public Tertiary Institution',
            subtitle: isHa
                ? 'Kasancewa ɗalibi a jami\'a, kwalejin foliteknik ko kwalejin ilimi ta gwamnatin tarayya ko jiha (Sashe na 2.2)'
                : 'Enrolled in an eligible Federal/State public university, polytechnic, or college.',
            value: provider.isEnrolledInPublicEti,
            onChanged: provider.toggleEnrolledInPublicEti,
          ),
          _buildCheckRow(
            context: context,
            title: isHa
                ? 'Tabbatar da Matsayin Karatu'
                : 'Academic Status Verified',
            subtitle: provider.academicType.getLocalizedAcademicRequirementLabel(lang),
            value: provider.isAcademicAdmissionVerified,
            onChanged: provider.toggleAcademicAdmissionVerified,
          ),
          _buildCheckRow(
            context: context,
            title: isHa
                ? 'Makarantarku ta Loda Bayananku a Tsarin SVS'
                : 'Uploaded to Student Verification System (SVS)',
            subtitle: isHa
                ? 'Makarantarku ta loda cikakkun bayanan ɗalibanta zuwa tsarin NELFUND (SVS) domin tantancewa.'
                : 'Your tertiary institution has uploaded your student profile to NELFUND.',
            value: provider.isSchoolDataUploaded,
            onChanged: provider.toggleSchoolDataUploaded,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildKycReadinessSection(
    BuildContext context,
    EligibilityProvider provider,
    AppLanguage lang,
  ) {
    final isHa = lang == AppLanguage.hausa;

    return AppleFrostedCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildCheckRow(
            context: context,
            title: isHa ? 'Lambar Rajistar JAMB' : 'JAMB Registration Number',
            subtitle: isHa
                ? 'Ingantacciyar lambar JAMB da aka tantance tare da hukumar JAMB.'
                : 'Validated with the Joint Admissions & Matriculation Board.',
            value: provider.hasJambNumber,
            onChanged: provider.toggleJambNumber,
            isFirst: true,
          ),
          _buildCheckRow(
            context: context,
            title: isHa
                ? 'Lambar Tabbatar da Asusun Banki (BVN)'
                : 'Bank Verification Number (BVN)',
            subtitle: isHa
                ? 'Dole ne ga dukkan masu neman bashi masu shekaru 18 ko sama da haka (NIBSS).'
                : 'Mandatory for all applicants aged 18 years and above (NIBSS).',
            value: provider.hasBvn,
            onChanged: provider.toggleBvn,
          ),
          _buildCheckRow(
            context: context,
            title: isHa
                ? 'Lambar Shaidar Ɗan Ƙasa (NIN)'
                : 'National Identity Number (NIN)',
            subtitle: isHa
                ? 'Wadda aka tantance a rumbun adana bayanai na NIMC.'
                : 'Verified through NIMC database.',
            value: provider.hasNin,
            onChanged: provider.toggleNin,
          ),
          _buildCheckRow(
            context: context,
            title: isHa
                ? 'Bayanin Adireshin Zama da Lambar Waya'
                : 'Personal Contact & Residential Info',
            subtitle: isHa
                ? 'Ingantacciyar lambar waya, adireshin gida, shekaru, jinsi da imel mai aiki.'
                : 'Valid phone number, residential address, age, gender, and active email.',
            value: provider.hasPersonalInfo,
            onChanged: provider.togglePersonalInfo,
          ),
          _buildCheckRow(
            context: context,
            title: isHa
                ? 'Hoton Fasfo na Zamani'
                : 'Recent Passport Photograph',
            subtitle: isHa
                ? 'Hoton fasfo na zamani mai farin baya a shirye yake.'
                : 'Clear digital headshot for identity verification.',
            value: provider.hasPassportPhoto,
            onChanged: provider.togglePassportPhoto,
          ),
          _buildCheckRow(
            context: context,
            title: isHa
                ? 'Takardar Shaidar Karatu ko Katin Ɗalibi'
                : 'Valid Admission Letter or Student ID',
            subtitle: isHa
                ? 'Shaidar zama ɗalibi a babbar makarantar gwamnati da ta cancanta.'
                : 'Official proof of studentship from an Eligible Tertiary Institution (ETI).',
            value: provider.hasAdmissionOrStudentId,
            onChanged: provider.toggleAdmissionOrStudentId,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDisqualificationSection(
    BuildContext context,
    EligibilityProvider provider,
    AppLanguage lang,
  ) {
    final isHa = lang == AppLanguage.hausa;

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
                        isHa
                            ? 'Shingen Doka Masu Hana Bashi'
                            : 'Statutory Disqualification Bars',
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
                  isHa
                      ? 'Ƙarƙashin Sashe na 3.0 na Ƙa\'idojin, kasancewar kowane ɗaya daga cikin waɗannan zai hana samun bashi kai-tsaye:'
                      : 'Under Section 3.0 of the Guidelines, having any of these conditions will automatically disqualify an applicant:',
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
            title: isHa
                ? 'Ƙin Biyan Wani Bashin Karatu a Baya'
                : 'Prior Education Loan Default',
            subtitle: isHa
                ? 'Wanda ya gaza biyan wani bashin karatu na gwamnatin tarayya ko jiha a baya.'
                : 'Defaulted on any prior FG or state education loan.',
            value: provider.hasPriorLoanDefault,
            onChanged: provider.togglePriorLoanDefault,
          ),
          _buildDisqualificationCheckRow(
            context: context,
            title: isHa
                ? 'Mai Ƙarɓar Wani Tallafin Karatu / Bashi a Halin Yanzu'
                : 'Concurrent Scholarship / Loan Beneficiary',
            subtitle: isHa
                ? 'Duk wanda a yanzu yake cin gajiyar wani tallafin karatu ko lamuni na gwamnati.'
                : 'Currently receiving another FG or state education loan or scholarship.',
            value: provider.hasActiveScholarship,
            onChanged: provider.toggleActiveScholarship,
          ),
          _buildDisqualificationCheckRow(
            context: context,
            title: isHa
                ? 'Laifin Maguɗin Jarrabawa ko Halayyar Makaranta'
                : 'Institutional Misconduct or Malpractice',
            subtitle: isHa
                ? 'Wanda makaranta ta kama da satar fasaha, ƙungiyar asiri, tashin hankali, ko ƙorar maguɗin jarrabawa.'
                : 'Found culpable of plagiarism, cultism, violence, exam malpractice dismissal, or forged papers.',
            value: provider.hasAcademicMisconduct,
            onChanged: provider.toggleAcademicMisconduct,
          ),
          _buildDisqualificationCheckRow(
            context: context,
            title: isHa
                ? 'Hukuncin Kotu Kan Aikata Laifi'
                : 'Criminal Conviction',
            subtitle: isHa
                ? 'Wanda kotu ta taɓa yanke wa hukunci kan damfara, jabu, miyagun ƙwayoyi, ko rashin gaskiya.'
                : 'Convicted of fraud, forgery, drug offences, felony, or dishonesty.',
            value: provider.hasCriminalConviction,
            onChanged: provider.toggleCriminalConviction,
          ),
          _buildDisqualificationCheckRow(
            context: context,
            title: isHa
                ? 'Mai Shaidar Digiri na Farko'
                : 'Holder of First Degree',
            subtitle: isHa
                ? 'Wanda ya riga ya mallaki digiri na farko (B.Sc/B.A) ko makamancin haka.'
                : 'Already possesses a bachelor’s degree or higher equivalent.',
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

  Widget _buildEvaluateButton(
    BuildContext context,
    EligibilityReport report,
    AppLanguage lang,
    AppTranslations tr,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 14),
        color: NelfundColors.emerald,
        borderRadius: BorderRadius.circular(14),
        onPressed: () => _showEligibilityModal(context, report, lang),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.checkmark_shield_fill,
              size: 20,
              color: CupertinoColors.white,
            ),
            const SizedBox(width: 8),
            Text(
              tr.checkStatusButton,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosticResultCard(
    BuildContext context,
    EligibilityReport report,
    AppLanguage lang,
    AppTranslations tr,
  ) {
    final bool isEligible = report.isLikelyEligible;
    final bool hasDisqualifiers = report.hasDisqualifiers;
    final isHa = lang == AppLanguage.hausa;

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

          // SECTION 1 BREAKDOWN
          _buildEvaluationSectionBox(
            context: context,
            title: isHa ? 'Sashe na 1: Muhimman Sharudda' : 'Section 1: Core Criteria',
            statusTag: isHa
                ? '${report.coreMetCount}/${report.coreTotalCount} Sun Cika'
                : '${report.coreMetCount}/${report.coreTotalCount} Met',
            isSuccess: report.coreMetCount == report.coreTotalCount,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (report.coreMetCount == report.coreTotalCount)
                  Text(
                    isHa
                        ? '✓ Dukkan muhimman sharuddan doka 4 sun cika (Zama Ɗan Ƙasa, Makarantar Gwamnati, Matsayin Karatu, da Loda Bayanan SVS).'
                        : '✓ All 4 core statutory criteria satisfied (Citizenship, Public Institution, Admission, and SVS data uploaded).',
                    style: const TextStyle(
                      color: NelfundColors.emerald,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else ...[
                  Text(
                    isHa ? 'Sharuddan da ba a cika ba tukuna:' : 'Pending Core Requirements:',
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
                              fontWeight: FontWeight.w600,
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

          // SECTION 2 BREAKDOWN
          _buildEvaluationSectionBox(
            context: context,
            title: isHa ? 'Sashe na 2: Shirye-shiryen KYC' : 'Section 2: KYC Readiness',
            statusTag: isHa
                ? '${report.kycMetCount}/${report.kycTotalCount} A Shirye'
                : '${report.kycMetCount}/${report.kycTotalCount} Ready',
            isSuccess: report.kycMetCount == report.kycTotalCount,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (report.kycMetCount == report.kycTotalCount)
                  Text(
                    isHa
                        ? '✓ Dukkan takardun KYC 6 na wajibi an shirya su domin lodawa.'
                        : '✓ All 6 mandatory KYC documents prepared and ready for upload.',
                    style: const TextStyle(
                      color: NelfundColors.emerald,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else ...[
                  Text(
                    isHa ? 'Takardun da ba a kammala ba:' : 'Documents Pending Preparation:',
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
                              fontWeight: FontWeight.w600,
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

          // SECTION 3 BREAKDOWN
          _buildEvaluationSectionBox(
            context: context,
            title: isHa ? 'Sashe na 3: Shingen Doka Masu Hana Bashi' : 'Section 3: Disqualification Record',
            statusTag: hasDisqualifiers
                ? (isHa ? '${report.disqualifierCount} Shinge Ya Hana' : '${report.disqualifierCount} Active Bar(s)')
                : (isHa ? 'Tarihi Mai Kyau' : 'Clean Record'),
            isSuccess: !hasDisqualifiers,
            isCriticalError: hasDisqualifiers,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!hasDisqualifiers)
                  Text(
                    isHa
                        ? '✓ An Wanke: Babu wani dalili na hana bashi ƙarƙashin Sashe na 3.0 na Dokar 2024.'
                        : '✓ Cleared: 0 disqualification factors flagged under Section 3.0 of the 2024 Act.',
                    style: const TextStyle(
                      color: NelfundColors.emerald,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else ...[
                  Text(
                    isHa ? 'Abubuwan da suka hana cancanta:' : 'Triggered Disqualification Factor(s):',
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
                              fontWeight: FontWeight.w600,
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
                        isHa ? 'Cikakken Bayani: Me Ya Faru?' : 'Full Breakdown: What Happened?',
                        style: NelfundTypography.headline.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
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
                        ? (isHa ? 'Bude Shafin Hukumar NELFUND (nelf.gov.ng)' : 'Open NELFUND Portal (nelf.gov.ng)')
                        : (isHa ? 'Ziyarci Shafin Hukuma domin Jagorori' : 'Visit Official Portal for Guidelines'),
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
                  fontWeight: FontWeight.w600,
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

  Widget _buildLegalDisclaimer(BuildContext context, AppTranslations tr) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        tr.isHausa
            ? 'Lura: Wannan na\'urar tantance cancanta tana auna bayananka ne da ƙa\'idojin 2024 domin ilmantarwa kaɗai. Hukuncin ƙarshe da amincewa yana hannun NELFUND ne da kuma tabbatarwar tsarin SVS na makarantarka.'
            : 'Note: This eligibility checker evaluates your criteria against the published 2024 Guidelines for informational purposes. Final determination and clearance rests solely with NELFUND and your tertiary institution’s SVS confirmation.',
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

class _AnimatedHelpButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isHausa;

  const _AnimatedHelpButton({
    required this.onTap,
    required this.isHausa,
  });

  @override
  State<_AnimatedHelpButton> createState() => _AnimatedHelpButtonState();
}

class _AnimatedHelpButtonState extends State<_AnimatedHelpButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.08, end: 0.95)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.05)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
    ]).animate(_pulseController);

    _pulseController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          _pulseController.forward(from: 0.0);
          widget.onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: NelfundColors.emerald.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: NelfundColors.emerald.withValues(alpha: 0.38),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: NelfundColors.emerald.withValues(alpha: 0.15),
                blurRadius: 8,
                spreadRadius: 0.5,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.question_circle_fill,
                color: NelfundColors.emerald,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                widget.isHausa ? 'Jagora' : 'Help Guide',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: NelfundColors.emerald,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

