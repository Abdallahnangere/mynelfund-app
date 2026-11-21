import 'package:flutter/cupertino.dart';

import '../../../../core/theme/nelfund_colors.dart';
import '../../../../core/theme/nelfund_typography.dart';
import '../../../../shared/widgets/apple_frosted_card.dart';

/// Highlighted statutory notice card detailing the mandatory 30-day
/// institutional refund rule under Section 4.1.2 of the NELFUND Guidelines.
class FaqRefundSpotlightCard extends StatelessWidget {
  /// Creates a [FaqRefundSpotlightCard].
  const FaqRefundSpotlightCard({super.key, required this.isHausa});

  /// Whether body guidance renders in Hausa.
  final bool isHausa;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: AppleFrostedCard(
        margin: EdgeInsets.zero,
        borderColor: NelfundColors.emerald.withValues(alpha: 0.35),
        backgroundColor: CupertinoDynamicColor.resolve(
          const CupertinoDynamicColor.withBrightness(
            color: Color(0xF5EBF8F1),
            darkColor: Color(0xD912291D),
          ),
          context,
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: NelfundColors.emerald.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                CupertinoIcons.shield_lefthalf_fill,
                color: NelfundColors.emerald,
                size: 19,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isHausa
                        ? "Dokar Mayar da Kudi ta Kwanaki 30 (Sashe 4.1.2)"
                        : '30-Day Institutional Refund Rule (Sec. 4.1.2)',
                    style: NelfundTypography.headline.copyWith(
                      fontSize: 13.5,
                      color: NelfundColors.emerald,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isHausa
                        ? 'Idan ka riga ka biya kudin makaranta kafin NELFUND ta biya makarantar ka, makarantar tana da alhakin mayar maka da kudinka cikin kwanaki 30 na aiki.'
                        : 'If you already paid tuition before NELFUND disbursed directly to your institution, the school must refund your personal payment within 30 working days.',
                    style: NelfundTypography.footnote.copyWith(
                      fontSize: 12,
                      height: 1.38,
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
        ),
      ),
    );
  }
}
