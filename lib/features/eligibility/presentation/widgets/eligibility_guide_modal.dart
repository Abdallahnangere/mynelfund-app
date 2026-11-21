import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../../core/localization/app_translations.dart';
import '../../../../core/theme/nelfund_colors.dart';
import '../../../../core/theme/nelfund_typography.dart';

/// Displays the frosted step-by-step guide modal explaining how students should
/// complete the 3-part eligibility diagnostic safely.
Future<void> showStudentEligibilityGuideModal(
  BuildContext context,
  AppTranslations tr,
) {
  final isHa = tr.isHausa;

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: isHa
        ? 'Jagoran Cancantar Dalibi'
        : 'Student Eligibility Guide',
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
                    child: _GuideDialogSurface(
                      isHa: isHa,
                      onClose: () => Navigator.of(ctx).pop(),
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

class _GuideDialogSurface extends StatelessWidget {
  const _GuideDialogSurface({required this.isHa, required this.onClose});

  final bool isHa;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    isHa
                        ? 'Jagoran Cancantar Dalibi'
                        : 'Student Eligibility Guide',
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
                    onClose();
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
                  _GuideStepCard(
                    stepNumber: '1',
                    title: isHa
                        ? 'Zabi Rukunin Karatu'
                        : 'Select Academic Stream',
                    description: isHa
                        ? 'Zabi ko kai sabon shiga ne (100L ta JAMB), shigar kai-tsaye (Direct Entry/200L), ko mai ci gaba da karatu.'
                        : 'Choose whether you are Fresh Entry (100L via JAMB), Direct Entry (200L/DE), or Returning Undergraduate.',
                    stepColor: NelfundColors.emerald,
                  ),
                  const SizedBox(height: 12),
                  _GuideStepCard(
                    stepNumber: '2',
                    title: isHa
                        ? 'Cika Sashe na 1 da na 2'
                        : 'Fill Sections 1 & 2',
                    description: isHa
                        ? 'Danna kowacce alama inda ka cika sharuddan doka a Sashe na 1 tare da shirya takardun KYC a Sashe na 2.'
                        : 'Tick every box where you have met the statutory criteria in Section 1 and prepared the required KYC documents in Section 2.',
                    stepColor: NelfundColors.emerald,
                  ),
                  const SizedBox(height: 12),
                  _GuideStepCard(
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 13),
              color: NelfundColors.emerald,
              borderRadius: BorderRadius.circular(16),
              onPressed: () {
                HapticFeedback.lightImpact();
                onClose();
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
    );
  }
}

class _GuideStepCard extends StatelessWidget {
  const _GuideStepCard({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.stepColor,
    this.isWarning = false,
  });

  final String stepNumber;
  final String title;
  final String description;
  final Color stepColor;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          CupertinoDynamicColor.withBrightness(
            color: isWarning
                ? const Color(0x0CFF9500)
                : const Color(0x0C008751),
            darkColor: isWarning
                ? const Color(0x18FF9500)
                : const Color(0x18008751),
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
            decoration: BoxDecoration(color: stepColor, shape: BoxShape.circle),
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
}
