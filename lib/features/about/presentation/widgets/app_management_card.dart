import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../../core/localization/app_translations.dart';
import '../../../../core/services/review_service.dart';
import '../../../../core/services/update_service.dart';
import '../../../../core/theme/nelfund_colors.dart';
import '../../../../core/theme/nelfund_typography.dart';
import '../../../../shared/widgets/apple_frosted_card.dart';

/// Card managing store rating prompts, manual update checks, and release
/// changelog inspection.
class AppManagementCard extends StatelessWidget {
  /// Creates an [AppManagementCard].
  const AppManagementCard({super.key, required this.tr});

  /// Active translation bundle.
  final AppTranslations tr;

  @override
  Widget build(BuildContext context) {
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    final storeTitle = isIOS
        ? 'App Store & Community'
        : 'Play Store & Community';
    final rateButtonLabel = isIOS
        ? (tr.isHausa ? 'Bada Ƙima a App Store' : 'Rate on App Store')
        : (tr.isHausa ? 'Bada Ƙima a Play Store' : 'Rate on Play Store');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppleFrostedCard(
        margin: EdgeInsets.zero,
        borderColor: NelfundColors.emerald.withValues(alpha: 0.3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  CupertinoIcons.sparkles,
                  color: NelfundColors.emerald,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    storeTitle,
                    style: NelfundTypography.headline.copyWith(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => showVersionHistorySheet(context, tr),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: NelfundColors.emerald.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'v2.2.7+13',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: NelfundColors.emerald,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              tr.isHausa
                  ? 'Taimaka wa sauran ɗaliban Najeriya samun wannan bashi mara ruwa ta hanyar bayar da ƙyakkyawar ƙima ga manhajar, ko duba sabbin sauye-sauye.'
                  : 'Help other Nigerian students discover zero-interest financing by rating the app, or check for the latest official updates.',
              style: NelfundTypography.footnote.copyWith(
                color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel,
                  context,
                ),
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    color: NelfundColors.emerald,
                    borderRadius: BorderRadius.circular(12),
                    minimumSize: Size.zero,
                    onPressed: () => ReviewService.instance.openStoreListing(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          CupertinoIcons.star_fill,
                          size: 15,
                          color: Color(0xFFFFD700),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          rateButtonLabel,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    color: CupertinoDynamicColor.resolve(
                      CupertinoColors.systemGrey5,
                      context,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    minimumSize: Size.zero,
                    onPressed: () => UpdateService.instance.checkForUpdates(
                      context,
                      userInitiated: true,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.arrow_clockwise_circle_fill,
                          size: 16,
                          color: CupertinoDynamicColor.resolve(
                            NelfundColors.label,
                            context,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          tr.isHausa ? 'Duba Sabuntawa' : 'Check Update',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: CupertinoDynamicColor.resolve(
                              NelfundColors.label,
                              context,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 10),
              color: CupertinoDynamicColor.resolve(
                CupertinoColors.systemGrey6,
                context,
              ),
              borderRadius: BorderRadius.circular(12),
              minimumSize: Size.zero,
              onPressed: () => showVersionHistorySheet(context, tr),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.doc_text_search,
                    size: 15,
                    color: NelfundColors.emerald,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    tr.isHausa
                        ? 'Duba Tarihin Sabuntawa (Changelog)'
                        : "What's New / Version History",
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: CupertinoDynamicColor.resolve(
                        NelfundColors.label,
                        context,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Package: com.mynelfund.app',
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: CupertinoDynamicColor.resolve(
                    NelfundColors.tertiaryLabel,
                    context,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opens a scrollable Cupertino bottom sheet presenting release notes from
/// v1.0.0 through v2.2.7.
void showVersionHistorySheet(BuildContext context, AppTranslations tr) {
  HapticFeedback.lightImpact();

  showCupertinoModalPopup<void>(
    context: context,
    builder: (sheetCtx) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(sheetCtx).height * 0.86,
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        decoration: BoxDecoration(
          color: CupertinoDynamicColor.resolve(
            CupertinoColors.systemBackground,
            sheetCtx,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey4,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: NelfundColors.emerald.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      CupertinoIcons.doc_text_search,
                      color: NelfundColors.emerald,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr.isHausa
                              ? 'Tarihin Sauye-sauye'
                              : 'Version History',
                          style: NelfundTypography.headline.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tr.isHausa
                              ? 'Bayanan abubuwan da aka sabunta'
                              : 'Release notes and system updates',
                          style: NelfundTypography.caption.copyWith(
                            color: CupertinoDynamicColor.resolve(
                              NelfundColors.secondaryLabel,
                              sheetCtx,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: NelfundColors.emerald.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'v2.2.7+13',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: NelfundColors.emerald,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ChangelogEntryCard(
                        tr: tr,
                        version: 'v2.2.7',
                        buildLabel: 'Build 13',
                        date: 'Nov 2026',
                        isCurrent: true,
                        title: tr.isHausa
                            ? 'Tsarin Rubutu Mai Kyau & Haɗin Sauki Go'
                            : 'Refined Apple HIG Typography & Sauki Go Integration',
                        highlights: tr.isHausa
                            ? const [
                                'Daidaita kaurin rubutu a duk shafukan manhajar don sauƙin karantawa da tsari mai haske.',
                                'Sabon katin amintacciyar manhajar Sauki Go don sayen data da katin waya mai rahusa na wata-wata.',
                                'Gyaran girman allon waya a harshen Hausa da Turanci ba tare da cunkoso ba.',
                              ]
                            : const [
                                'Balanced Apple HIG typography weights across every screen for cleaner, lighter readability.',
                                'Integrated Sauki Go companion app access for affordable monthly student data & airtime plans.',
                                'Responsive bilingual layout improvements across compact and large displays.',
                              ],
                      ),
                      const SizedBox(height: 12),
                      _ChangelogEntryCard(
                        tr: tr,
                        version: 'v2.2.5',
                        buildLabel: 'Build 11',
                        date: 'Oct 2026',
                        isCurrent: false,
                        title: tr.isHausa
                            ? 'Gyaran Bayanan Mai Haɓakawa & Katin Tuntuɓar WhatsApp'
                            : 'Developer Bio Refinement & Custom Digital Solutions CTA',
                        highlights: tr.isHausa
                            ? const [
                                "Sabunta bayanan mai haɓakawa zuwa matsayin ɗalibi a Jami'ar Ahmadu Bello (ABU), Zaria.",
                                'Keɓance hanyar tuntuɓar mai haɓakawa don batutuwan manhaja kaɗai, tare da tura tambayoyin lamuni zuwa info@nelf.gov.ng.',
                                'Sabon katin frosted glass na tuntuɓar WhatsApp don haɓaka manhajoji ko tsarin dijital na kasuwanci da ƙungiyoyi.',
                              ]
                            : const [
                                'Developer profile refined to academic status as an Ahmadu Bello University (ABU) undergraduate.',
                                'Explicit separation of technical app feedback from official loan support with direct info@nelf.gov.ng deeplink.',
                                'Bespoke Apple frosted glass CTA card for custom mobile apps, web platforms, and digital solutions via WhatsApp.',
                              ],
                      ),
                      const SizedBox(height: 12),
                      _ChangelogEntryCard(
                        tr: tr,
                        version: 'v2.2.4',
                        buildLabel: 'Build 9',
                        date: 'Oct 2026',
                        isCurrent: false,
                        title: tr.isHausa
                            ? 'Isar da Sanarwa ta Harshe & Rumbun FAQs Ba Intanet'
                            : 'Targeted Push Routing & Resilient Offline FAQs',
                        highlights: tr.isHausa
                            ? const [
                                'Sanarwar gaggawa ta wayar hannu tana isa da Hausa ko Turanci daidai da zaɓin harshenka.',
                                'Rumbun tambayoyin hukuma yana aiki 100% koda ba intanet, tare da sabuntawa ta atomatik.',
                                "Sanarwar sabunta ka’idojin lamuni ta atomatik a wayarka lokacin da aka gyara FAQ.",
                              ]
                            : const [
                                'Language-targeted push notifications dispatched via dedicated FCM channels (English and Hausa).',
                                'Resilient offline FAQ knowledge base with automatic reconnect sync and offline retry action.',
                                'Automated push notifications triggered on statutory FAQ additions or policy updates.',
                              ],
                      ),
                      const SizedBox(height: 12),
                      _ChangelogEntryCard(
                        tr: tr,
                        version: 'v2.2.3',
                        buildLabel: 'Build 8',
                        date: 'Oct 2026',
                        isCurrent: false,
                        title: tr.isHausa
                            ? 'Ajiye Bayanan Lamuni & Cikakken Rumbun Firestore'
                            : 'Device Storage Persistence & Full Firestore Sync',
                        highlights: tr.isHausa
                            ? const [
                                'Ajiyar bayanan lissafin lamuni a ma’adanar waya koda an rufe manhaja.',
                                'Tabbatar da adana dukkan tambayoyin hukuma 19 a Cloud Firestore.',
                              ]
                            : const [
                                'Persistent storage for customized loan calculations and notification inbox across app restarts.',
                                'Synchronized all 19 statutory FAQs directly with Cloud Firestore.',
                              ],
                      ),
                      const SizedBox(height: 12),
                      _ChangelogEntryCard(
                        tr: tr,
                        version: 'v2.2.0',
                        buildLabel: 'Build 7',
                        date: 'Oct 2026',
                        isCurrent: false,
                        title: tr.isHausa
                            ? 'Sabon Splash na ABU & Tsarin Alawus'
                            : 'ABU Dual-Crest Splash & Upkeep Calendar',
                        highlights: tr.isHausa
                            ? const [
                                'Sabon shafin maraba mai tambarin ABU Zaria da NELFUND tare da roket mai motsi.',
                                'Lissafin kudin alawus na kowane wata tare da zabin kwanakin wata.',
                              ]
                            : const [
                                'ABU Zaria & NELFUND dual-logo animated splash with rocket flight trajectory.',
                                'Upkeep month calendar selector and voluntary prepayment configurator.',
                              ],
                      ),
                      const SizedBox(height: 12),
                      _ChangelogEntryCard(
                        tr: tr,
                        version: 'v2.1.0',
                        buildLabel: 'Build 4',
                        date: 'Sep 2026',
                        isCurrent: false,
                        title: tr.isHausa
                            ? 'Fassarar Cikakken Harshen Hausa'
                            : 'Full Bilingual Hausa Localization',
                        highlights: tr.isHausa
                            ? const [
                                'Cikakken goyon bayan harshen Hausa a dukkan shafuka da bayanai.',
                                'Maballin sauya harshe cikin sauki a saman babban shafi.',
                              ]
                            : const [
                                'Full bilingual Hausa language support across all 5 core application tabs.',
                                'Real-time language switch toggle in the Home header.',
                              ],
                      ),
                      const SizedBox(height: 12),
                      _ChangelogEntryCard(
                        tr: tr,
                        version: 'v1.0.0',
                        buildLabel: 'Build 1',
                        date: 'Sep 2026',
                        isCurrent: false,
                        title: tr.isHausa
                            ? 'Kaddamarwar Farko ta Manhaja'
                            : 'Initial Official Launch',
                        highlights: tr.isHausa
                            ? const [
                                'Babban shafi mai kunshe da ginshikan lamuni 3 (0% ruwa, biyan kudin makaranta, alawus na N20,000).',
                                "Na’urar tantance cancanta da kuma lissafin biyan kudi na 10%.",
                                'Rumbun tambayoyin doka da mai bin diddigin lokutan aiki (SLA).',
                              ]
                            : const [
                                'Apple Cupertino Human Interface Guidelines design foundation.',
                                'Core tools: Eligibility Checker, Repayment Calculator, FAQ Knowledge Base, and SLA Timeline Tracker.',
                              ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: NelfundColors.emerald,
                borderRadius: BorderRadius.circular(12),
                onPressed: () => Navigator.of(sheetCtx).pop(),
                child: Center(
                  child: Text(
                    tr.isHausa ? 'Rufe' : 'Close',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.white,
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

class _ChangelogEntryCard extends StatelessWidget {
  const _ChangelogEntryCard({
    required this.tr,
    required this.version,
    required this.buildLabel,
    required this.date,
    required this.isCurrent,
    required this.title,
    required this.highlights,
  });

  final AppTranslations tr;
  final String version;
  final String buildLabel;
  final String date;
  final bool isCurrent;
  final String title;
  final List<String> highlights;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          CupertinoColors.systemGrey6,
          context,
        ),
        borderRadius: BorderRadius.circular(14),
        border: isCurrent
            ? Border.all(
                color: NelfundColors.emerald.withValues(alpha: 0.45),
                width: 1.5,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                version,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: NelfundColors.emerald,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey5,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  buildLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (isCurrent) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: NelfundColors.emerald,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tr.isHausa ? 'Na Yanzu' : 'Current',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                date,
                style: TextStyle(
                  fontSize: 11.5,
                  color: CupertinoDynamicColor.resolve(
                    NelfundColors.tertiaryLabel,
                    context,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: NelfundTypography.subhead.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          for (final point in highlights)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      color: NelfundColors.emerald,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      point,
                      style: NelfundTypography.footnote.copyWith(
                        fontSize: 12,
                        height: 1.35,
                        color: CupertinoDynamicColor.resolve(
                          NelfundColors.secondaryLabel,
                          context,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
