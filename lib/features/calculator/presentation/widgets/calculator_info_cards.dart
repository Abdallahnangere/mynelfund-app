import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../../../../core/localization/app_translations.dart';
import '../../../../core/theme/nelfund_colors.dart';
import '../../../../core/theme/nelfund_typography.dart';
import '../../../../shared/widgets/apple_frosted_card.dart';

/// Helpful contextual tip banner displayed at the top of [CalculatorView].
class CalculatorTipBanner extends StatelessWidget {
  /// Creates a [CalculatorTipBanner].
  const CalculatorTipBanner({super.key, required this.tr});

  /// Active translation bundle.
  final AppTranslations tr;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppleFrostedCard(
        margin: EdgeInsets.zero,
        borderColor: NelfundColors.emerald.withValues(alpha: 0.35),
        backgroundColor: CupertinoDynamicColor.resolve(
          const CupertinoDynamicColor.withBrightness(
            color: Color(0xF2F0FBF5),
            darkColor: Color(0xD0132B1D),
          ),
          context,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(
                CupertinoIcons.lightbulb_fill,
                color: NelfundColors.emerald,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                tr.calcTipBannerText,
                style: NelfundTypography.footnote.copyWith(
                  fontSize: 13,
                  height: 1.35,
                  color: CupertinoDynamicColor.resolve(
                    NelfundColors.label,
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

/// Educational card detailing beneficiary hardship deferrals, 30-day
/// pre-escalation grace windows, and GSI bank safeguards.
class FriendlyComplianceCard extends StatelessWidget {
  /// Creates a [FriendlyComplianceCard].
  const FriendlyComplianceCard({super.key, required this.tr});

  /// Active translation bundle.
  final AppTranslations tr;

  @override
  Widget build(BuildContext context) {
    final isHa = tr.isHausa;

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
                  CupertinoIcons.shield_lefthalf_fill,
                  color: NelfundColors.emerald,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tr.complianceGuideTitle,
                    style: NelfundTypography.headline.copyWith(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              tr.complianceGuideDesc,
              style: NelfundTypography.footnote.copyWith(
                color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel,
                  context,
                ),
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 14),
            _SupportPointRow(
              icon: CupertinoIcons.person_crop_circle_badge_checkmark,
              iconColor: NelfundColors.emerald,
              title: isHa
                  ? 'Kariyar Dalibai & Dakatar da Biya Saboda Lalura'
                  : 'Student Safety Nets & Hardship Deferrals',
              detail: isHa
                  ? 'Duk wanda ya tsinci kansa a rashin aikin yi ko matsin tattalin arziki zai iya neman a dakatar da biyan bashi a hukumance. Babu wani kudin ruwa ko tara da zai karu a lokacin da aka amince da dakatarwar.'
                  : 'Beneficiaries facing genuine unemployment or economic hardship can easily apply for formal repayment suspension. No interest or penalty ever accumulates during approved pauses.',
            ),
            _SupportPointRow(
              icon: CupertinoIcons.chat_bubble_2_fill,
              iconColor: CupertinoColors.systemBlue,
              title: isHa
                  ? 'Ci gaba da Kasancewa tare da NELFUND'
                  : 'Stay Connected with NELFUND',
              detail: isHa
                  ? 'Kula da martabarka abu ne mai sauki: ka tabbatar da cewa adireshinka na gida, lambar waya, da halin aikinka na zamani ne a shafin dalibai na hukuma.'
                  : 'Maintaining your good standing is simple: keep your residential address, phone number, and employer status current on the official student portal.',
            ),
            _SupportPointRow(
              icon: CupertinoIcons.bell_fill,
              iconColor: CupertinoColors.systemOrange,
              title: isHa
                  ? "Wa'adin Jan Kunne na Kwanaki 30"
                  : '30-Day Pre-Escalation Grace Windows',
              detail: isHa
                  ? "Kafin daukar kowane mataki na gudanarwa, NELFUND tana tura takardun tunatarwa masu wa'adin kwanaki 30 domin bayar da damar fayyace matsayi ko tsara biya."
                  : 'Before any formal administrative escalation, NELFUND issues written reminder notices with 30-day resolution windows to allow beneficiaries to clarify status or set up payment plans.',
            ),
            _SupportPointRow(
              icon: CupertinoIcons.arrow_2_circlepath_circle_fill,
              iconColor: NelfundColors.emerald,
              title: isHa
                  ? 'Fayyace Umarnin Banki na GSI'
                  : 'Global Standing Instruction (GSI) Clarification',
              detail: isHa
                  ? 'Tsarin GSI umarni ne na babban banki a fadin Najeriya. Dangane da bashin dalibai, ana amfani da shi ne a matsayin mataki na karshe ga wanda ya ki biya da gangan ba tare da sanarwa ba. Sadarwa ta gaskiya tana ba ka kariya kai-tsaye.'
                  : 'GSI is a standard interbank mechanism across Nigerian banking. For student loans, it is only invoked as a last-resort safeguard for extended unnotified non-remittance. Transparent communication protects your account automatically.',
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportPointRow extends StatelessWidget {
  const _SupportPointRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.detail,
    this.isLast = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String detail;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
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
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: NelfundTypography.footnote.copyWith(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
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
}

/// Footer statutory 0% zero-interest disclaimer caption inside [CalculatorView].
class StatutoryNoticeText extends StatelessWidget {
  /// Creates a [StatutoryNoticeText].
  const StatutoryNoticeText({super.key, required this.tr});

  /// Active translation bundle.
  final AppTranslations tr;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        tr.isHausa
            ? 'Sanarwar Doka: Dukkan lissafin an yi shi ne bisa tsarin 0% ba kudin ruwa ko kobo karkashin Dokar Lamunin Dalibai ta 2024. Biyan bashi kafin lokaci ko karawa ba shi da wani caji ko tara.'
            : 'Legal Notice: All simulations are modeled strictly at 0% zero interest under the Students Loans (Access to Higher Education) Act 2024. Voluntary prepayments or accelerated installments incur zero penalty fees.',
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

/// Opens the frosted guide modal explaining loan sessions, moratorium, and
/// voluntary repayment configuration.
Future<void> showCalculatorGuideModal(
  BuildContext context,
  AppTranslations tr,
) {
  final isHa = tr.isHausa;

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: isHa ? "Jagoran Na'urar Lissafi" : 'Calculator Guide',
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
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    color: CupertinoColors.black.withValues(alpha: 0.20),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
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
                            color: NelfundColors.emerald.withValues(
                              alpha: 0.14,
                            ),
                            blurRadius: 28,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 18, 16, 12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: NelfundColors.emerald.withValues(
                                      alpha: 0.15,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.creditcard_fill,
                                    color: NelfundColors.emerald,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tr.calcGuideTitle,
                                        style: NelfundTypography.headline
                                            .copyWith(
                                              fontSize: 16.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      Text(
                                        isHa
                                            ? 'Tsarin Lamuni & Biyan Bashi'
                                            : 'Loan & Repayment Architecture',
                                        style: NelfundTypography.caption
                                            .copyWith(
                                              color:
                                                  CupertinoDynamicColor.resolve(
                                                    NelfundColors
                                                        .secondaryLabel,
                                                    context,
                                                  ),
                                              fontSize: 11.5,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Icon(
                                    CupertinoIcons.xmark_circle_fill,
                                    color: CupertinoColors.systemGrey3,
                                    size: 26,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 0.8,
                            color: NelfundColors.emerald.withValues(
                              alpha: 0.18,
                            ),
                          ),
                          Flexible(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                14,
                                20,
                                14,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tr.calcGuideIntro,
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
                                  _GuideStepRow(
                                    stepNumber: '1',
                                    title: tr.calcGuideStep1Title,
                                    description: tr.calcGuideStep1Desc,
                                    stepColor: NelfundColors.emerald,
                                  ),
                                  const SizedBox(height: 12),
                                  _GuideStepRow(
                                    stepNumber: '2',
                                    title: tr.calcGuideStep2Title,
                                    description: tr.calcGuideStep2Desc,
                                    stepColor: CupertinoColors.systemBlue,
                                  ),
                                  const SizedBox(height: 12),
                                  _GuideStepRow(
                                    stepNumber: '3',
                                    title: tr.calcGuideStep3Title,
                                    description: tr.calcGuideStep3Desc,
                                    stepColor: NelfundColors.emerald,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                            child: CupertinoButton(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              color: NelfundColors.emerald,
                              borderRadius: BorderRadius.circular(14),
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: Text(
                                tr.calcGuideDismiss,
                                style: const TextStyle(
                                  color: CupertinoColors.white,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
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

class _GuideStepRow extends StatelessWidget {
  const _GuideStepRow({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.stepColor,
  });

  final String stepNumber;
  final String title;
  final String description;
  final Color stepColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          CupertinoColors.systemBackground,
          context,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: stepColor.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: stepColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              stepNumber,
              style: TextStyle(
                color: stepColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
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
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: NelfundTypography.footnote.copyWith(
                    color: CupertinoDynamicColor.resolve(
                      NelfundColors.secondaryLabel,
                      context,
                    ),
                    fontSize: 12,
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
}
