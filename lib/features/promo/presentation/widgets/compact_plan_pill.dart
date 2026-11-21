import 'package:flutter/cupertino.dart';

/// Compact pill showcasing a highlighted mobile data bundle offer inside
/// Sauki Go promo cards and dialogs.
class CompactPlanPill extends StatelessWidget {
  /// Creates a [CompactPlanPill].
  const CompactPlanPill({
    super.key,
    required this.dataLabel,
    required this.priceLabel,
    required this.periodLabel,
  });

  /// Data bundle size (e.g., `'1GB'`, `'5GB'`).
  final String dataLabel;

  /// Formatted bundle price (e.g., `'₦400'`, `'₦1,500'`).
  final String priceLabel;

  /// Validity window descriptor (e.g., `'Monthly'`, `'Na Wata'`).
  final String periodLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x18FFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x30FFFFFF), width: 0.75),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dataLabel,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(width: 6),
          Container(width: 1, height: 14, color: const Color(0x40FFFFFF)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                priceLabel,
                style: const TextStyle(
                  color: Color(0xFF6EE7B7),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  height: 1.05,
                ),
              ),
              Text(
                periodLabel,
                style: const TextStyle(
                  color: Color(0xC2FFFFFF),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
