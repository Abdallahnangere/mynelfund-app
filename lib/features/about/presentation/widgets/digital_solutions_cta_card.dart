import 'package:flutter/cupertino.dart';

import '../../../../core/localization/app_translations.dart';
import '../../../../core/theme/nelfund_colors.dart';
import '../../../../core/theme/nelfund_typography.dart';
import '../../../../shared/widgets/apple_frosted_card.dart';

/// Custom digital solutions invitation card with capability tags and direct
/// WhatsApp outreach button.
class DigitalSolutionsCtaCard extends StatelessWidget {
  /// Creates a [DigitalSolutionsCtaCard].
  const DigitalSolutionsCtaCard({
    super.key,
    required this.tr,
    required this.onWhatsAppTap,
  });

  /// Active translation bundle.
  final AppTranslations tr;

  /// Invoked when the user taps the WhatsApp inquiry CTA.
  final VoidCallback onWhatsAppTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppleFrostedCard(
        margin: EdgeInsets.zero,
        borderColor: NelfundColors.emerald.withValues(alpha: 0.45),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: NelfundColors.emerald.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: NelfundColors.emerald.withValues(alpha: 0.3),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    CupertinoIcons.sparkles,
                    size: 13,
                    color: NelfundColors.emerald,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    tr.digitalSolutionsBadge,
                    style: NelfundTypography.captionBold.copyWith(
                      color: NelfundColors.emerald,
                      fontSize: 10.5,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              tr.digitalSolutionsTitle,
              style: NelfundTypography.title2.copyWith(
                fontSize: 16.5,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              tr.digitalSolutionsDesc,
              style: NelfundTypography.footnote.copyWith(
                color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel,
                  context,
                ),
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _CapabilityPill(emoji: '📱', text: tr.digitalSolutionsPill1),
                _CapabilityPill(emoji: '⚡', text: tr.digitalSolutionsPill2),
                _CapabilityPill(emoji: '💡', text: tr.digitalSolutionsPill3),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                color: const Color(0xFF25D366),
                borderRadius: BorderRadius.circular(13),
                minimumSize: Size.zero,
                onPressed: onWhatsAppTap,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.chat_bubble_2_fill,
                      size: 18,
                      color: CupertinoColors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tr.digitalSolutionsCtaButton,
                      style: const TextStyle(
                        fontSize: 13.5,
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

class _CapabilityPill extends StatelessWidget {
  const _CapabilityPill({required this.emoji, required this.text});

  final String emoji;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          CupertinoColors.systemGrey6,
          context,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: CupertinoDynamicColor.resolve(
            CupertinoColors.systemGrey4,
            context,
          ).withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
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
