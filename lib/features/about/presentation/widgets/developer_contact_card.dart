import 'package:flutter/cupertino.dart';

import '../../../../core/localization/app_translations.dart';
import '../../../../core/theme/nelfund_colors.dart';
import '../../../../core/theme/nelfund_typography.dart';
import '../../../../shared/widgets/apple_frosted_card.dart';

/// Developer contact card routing loan enquiries to NELFUND's official email
/// and offering direct technical support phone call, copy, and WhatsApp links.
class DeveloperContactCard extends StatelessWidget {
  /// Creates a [DeveloperContactCard].
  const DeveloperContactCard({
    super.key,
    required this.tr,
    required this.directCallNumber,
    required this.nelfundEmail,
    required this.onOfficialEmailTap,
    required this.onDirectCallTap,
    required this.onCopyNumberTap,
    required this.onWhatsAppTap,
  });

  /// Active translation bundle.
  final AppTranslations tr;

  /// Public technical support phone number (`08164135836`).
  final String directCallNumber;

  /// Official NELFUND enquiry email (`info@nelf.gov.ng`).
  final String nelfundEmail;

  /// Invoked when tapping the official NELFUND email CTA.
  final VoidCallback onOfficialEmailTap;

  /// Invoked when tapping the Call button.
  final VoidCallback onDirectCallTap;

  /// Invoked when tapping Copy beside the phone number.
  final VoidCallback onCopyNumberTap;

  /// Invoked when tapping the WhatsApp button.
  final VoidCallback onWhatsAppTap;

  @override
  Widget build(BuildContext context) {
    final isHa = tr.isHausa;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppleFrostedCard(
        margin: EdgeInsets.zero,
        borderColor: NelfundColors.emerald.withValues(alpha: 0.35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  CupertinoIcons.person_crop_circle_badge_checkmark,
                  color: NelfundColors.emerald,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tr.contactDeveloperTitle,
                    style: NelfundTypography.headline.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              tr.contactDeveloperDesc,
              style: NelfundTypography.footnote.copyWith(
                color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel,
                  context,
                ),
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: CupertinoDynamicColor.resolve(
                  const CupertinoDynamicColor.withBrightness(
                    color: Color(0xFFF0F5FA),
                    darkColor: Color(0xFF14202C),
                  ),
                  context,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: CupertinoColors.systemBlue.withValues(alpha: 0.35),
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.info_circle_fill,
                        size: 15,
                        color: CupertinoColors.systemBlue,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          tr.loanInquiryNoticeTitle,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.systemBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tr.loanInquiryNoticeDesc,
                    style: NelfundTypography.footnote.copyWith(
                      fontSize: 11.5,
                      height: 1.35,
                      color: CupertinoDynamicColor.resolve(
                        NelfundColors.secondaryLabel,
                        context,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                        vertical: 9,
                        horizontal: 12,
                      ),
                      color: CupertinoColors.systemBlue,
                      borderRadius: BorderRadius.circular(10),
                      minimumSize: Size.zero,
                      onPressed: onOfficialEmailTap,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            CupertinoIcons.mail_solid,
                            size: 14,
                            color: CupertinoColors.white,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '${tr.contactOfficialNelfundEmailBtn} ($nelfundEmail)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
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
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: CupertinoDynamicColor.resolve(
                  const CupertinoDynamicColor.withBrightness(
                    color: Color(0xFFF0F7F3),
                    darkColor: Color(0xFF152A1C),
                  ),
                  context,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: NelfundColors.emerald.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: NelfundColors.emerald.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              CupertinoIcons.phone_fill,
                              size: 12,
                              color: NelfundColors.emerald,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isHa ? 'KIRA KAI-TSAYE' : 'DIRECT CALL & SUPPORT',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                                color: NelfundColors.emerald,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGreen.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: CupertinoColors.systemGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isHa ? 'A Buɗe' : 'Available',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.systemGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    directCallNumber,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: CupertinoDynamicColor.resolve(
                        NelfundColors.label,
                        context,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoButton(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          color: NelfundColors.emerald,
                          borderRadius: BorderRadius.circular(12),
                          minimumSize: Size.zero,
                          onPressed: onDirectCallTap,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                CupertinoIcons.phone_fill,
                                size: 15,
                                color: CupertinoColors.white,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                isHa
                                    ? 'Kira: $directCallNumber'
                                    : 'Call: $directCallNumber',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: CupertinoColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 11,
                        ),
                        color: CupertinoDynamicColor.resolve(
                          CupertinoColors.systemGrey5,
                          context,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        minimumSize: Size.zero,
                        onPressed: onCopyNumberTap,
                        child: const Icon(CupertinoIcons.doc_on_doc, size: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                  horizontal: 16,
                ),
                color: const Color(0xFF25D366),
                borderRadius: BorderRadius.circular(14),
                minimumSize: Size.zero,
                onPressed: onWhatsAppTap,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.chat_bubble_fill,
                      size: 20,
                      color: CupertinoColors.white,
                    ),
                    const SizedBox(width: 9),
                    Text(
                      tr.whatsappButtonLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
