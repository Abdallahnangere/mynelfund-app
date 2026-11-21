import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/nelfund_colors.dart';
import '../../../../core/theme/nelfund_typography.dart';
import '../../../../shared/widgets/apple_frosted_card.dart';

/// Empty-state card displayed in [NotificationsView] when no bulletins match
/// the active query or no announcements are cached yet.
class NotificationEmptyState extends StatelessWidget {
  /// Creates a [NotificationEmptyState].
  const NotificationEmptyState({
    super.key,
    required this.title,
    required this.description,
    required this.onRefresh,
    required this.isHausa,
  });

  /// Primary empty state headline.
  final String title;

  /// Supporting explanation description.
  final String description;

  /// Called when the user triggers manual sync.
  final VoidCallback onRefresh;

  /// Whether action button renders in Hausa.
  final bool isHausa;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: AppleFrostedCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: NelfundColors.emerald.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.bell_slash_fill,
                color: NelfundColors.emerald,
                size: 26,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: NelfundTypography.headline.copyWith(fontSize: 16.5),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              textAlign: TextAlign.center,
              style: NelfundTypography.footnote.copyWith(
                height: 1.4,
                color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel,
                  context,
                ),
              ),
            ),
            const SizedBox(height: 16),
            CupertinoButton(
              color: NelfundColors.emerald,
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              onPressed: () {
                HapticFeedback.lightImpact();
                onRefresh();
              },
              child: Text(
                isHausa ? 'Sabunta Labarai' : 'Refresh Bulletins',
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
