import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/nelfund_colors.dart';
import '../../../../core/theme/nelfund_typography.dart';
import '../../../../shared/widgets/apple_frosted_card.dart';

/// Loading indicator rendered when remote FAQs are being fetched without
/// cached items yet available.
class FaqLoadingView extends StatelessWidget {
  /// Creates a [FaqLoadingView].
  const FaqLoadingView({super.key, required this.isHausa});

  /// Whether label renders in Hausa.
  final bool isHausa;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CupertinoActivityIndicator(radius: 13),
          const SizedBox(height: 12),
          Text(
            isHausa ? 'Ana loda tambayoyi...' : 'Loading official FAQs...',
            style: NelfundTypography.footnote.copyWith(
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

/// Empty state card displayed when search/category filters return no FAQ items.
class FaqEmptyView extends StatelessWidget {
  /// Creates a [FaqEmptyView].
  const FaqEmptyView({
    super.key,
    required this.title,
    required this.description,
    required this.resetLabel,
    required this.onReset,
  });

  /// Empty state title.
  final String title;

  /// Supporting explanation text.
  final String description;

  /// Button label to clear active filters.
  final String resetLabel;

  /// Callback clearing search query and resetting category to all.
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: AppleFrostedCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: NelfundColors.emerald.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.search,
                color: NelfundColors.emerald,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: NelfundTypography.headline.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              textAlign: TextAlign.center,
              style: NelfundTypography.footnote.copyWith(
                color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel,
                  context,
                ),
              ),
            ),
            const SizedBox(height: 14),
            CupertinoButton(
              color: NelfundColors.emerald,
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              onPressed: () {
                HapticFeedback.lightImpact();
                onReset();
              },
              child: Text(
                resetLabel,
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
