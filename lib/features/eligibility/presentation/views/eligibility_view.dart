import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../app/app.dart';
import '../../../../core/localization/app_locale.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/theme/nelfund_colors.dart';
import '../../../../core/theme/nelfund_typography.dart';
import '../../../../shared/widgets/animated_help_button.dart';
import '../../../../shared/widgets/liquid_glass_header.dart';
import '../../../../shared/widgets/section_header.dart';
import '../providers/eligibility_provider.dart';
import '../widgets/core_criteria_card.dart';
import '../widgets/disqualifier_section.dart';
import '../widgets/eligibility_diagnostic_card.dart';
import '../widgets/eligibility_guide_modal.dart';
import '../widgets/eligibility_report_modal.dart';
import '../widgets/entry_type_selector.dart';
import '../widgets/kyc_readiness_card.dart';

/// Interactive Students Loans Act 2024 Eligibility & KYC Diagnostic tool.
class EligibilityView extends StatelessWidget {
  /// Creates an [EligibilityView].
  const EligibilityView({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProv = AppProviders.maybeRead<LocaleProvider>(context);
    final eligibilityProv = AppProviders.maybeRead<EligibilityProvider>(
      context,
    );

    if (localeProv == null || eligibilityProv == null) {
      return MultiProvider(
        providers: [
          if (localeProv == null)
            ChangeNotifierProvider<LocaleProvider>(
              create: (_) => LocaleProvider(),
            ),
          if (eligibilityProv == null)
            ChangeNotifierProvider<EligibilityProvider>(
              create: (_) => EligibilityProvider(),
            ),
        ],
        child: const _EligibilityViewContent(),
      );
    }

    return const _EligibilityViewContent();
  }
}

class _EligibilityViewContent extends StatelessWidget {
  const _EligibilityViewContent();

  @override
  Widget build(BuildContext context) {
    final lang = context.select<LocaleProvider, AppLanguage>(
      (p) => p.currentLanguage,
    );
    final tr = AppTranslations.from(lang);
    final provider = context.watch<EligibilityProvider>();
    final report = provider.getReport(lang);

    return CupertinoPageScaffold(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            LiquidGlassHeader(
              title: tr.eligibilityHeaderTitle,
              subtitle: tr.isHausa
                  ? 'Binciken Tabbatar da Cancanta'
                  : 'Statutory Diagnostic Checklist',
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
              trailing: AnimatedHelpButton(
                isHausa: tr.isHausa,
                onTap: () {
                  HapticFeedback.lightImpact();
                  showStudentEligibilityGuideModal(context, tr);
                },
              ),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 88),
                children: [
                  EntryTypeSelector(
                    selectedType: provider.academicType,
                    language: lang,
                    tr: tr,
                    onChanged: provider.setAcademicType,
                  ),
                  const SizedBox(height: 16),
                  SectionHeader(title: tr.coreCriteriaTitle),
                  CoreCriteriaCard(provider: provider, language: lang),
                  const SizedBox(height: 16),
                  SectionHeader(title: tr.kycChecklistTitle),
                  KycReadinessCard(provider: provider, language: lang),
                  const SizedBox(height: 16),
                  SectionHeader(title: tr.disqualificationBarsTitle),
                  DisqualifierSection(provider: provider, language: lang),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      color: NelfundColors.emerald,
                      borderRadius: BorderRadius.circular(14),
                      onPressed: () =>
                          showEligibilityReportModal(context, report, lang),
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
                  ),
                  const SizedBox(height: 20),
                  EligibilityDiagnosticCard(
                    report: report,
                    language: lang,
                    onLaunchPortal: () =>
                        unawaited(launchNelfundPortal(context)),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      tr.isHausa
                          ? "Lura: Wannan na'urar tantance cancanta tana auna bayananka ne da ƙa'idojin 2024 domin ilmantarwa kaɗai. Hukuncin ƙarshe da amincewa yana hannun NELFUND ne da kuma tabbatarwar tsarin SVS na makarantarka."
                          : 'Note: This eligibility checker evaluates your criteria against the published 2024 Guidelines for informational purposes. Final determination and clearance rests solely with NELFUND and your tertiary institution’s SVS confirmation.',
                      style: NelfundTypography.caption.copyWith(
                        color: CupertinoDynamicColor.resolve(
                          NelfundColors.tertiaryLabel,
                          context,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
