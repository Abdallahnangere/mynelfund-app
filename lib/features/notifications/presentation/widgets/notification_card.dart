import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/nelfund_colors.dart';
import '../../../../core/theme/nelfund_typography.dart';
import '../../../../shared/widgets/apple_frosted_card.dart';
import '../../domain/notification_model.dart';

/// Frosted bulletin card displaying a localized notification announcement with
/// unread status dot, category pill, timestamp, and optional external action.
class NotificationCard extends StatelessWidget {
  /// Creates a [NotificationCard].
  const NotificationCard({
    super.key,
    required this.item,
    required this.isHausa,
    required this.openPortalLabel,
    required this.onTap,
    required this.onDelete,
  });

  /// Notification record rendered inside the card.
  final NotificationItem item;

  /// Whether localized title/body render in Hausa.
  final bool isHausa;

  /// Action label shown when [NotificationItem.actionUrl] is non-empty.
  final String openPortalLabel;

  /// Invoked when the user taps the bulletin card.
  final VoidCallback onTap;

  /// Invoked when the user deletes/dismisses the bulletin.
  final VoidCallback onDelete;

  Future<void> _launchActionUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return;
    }
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (error) {
      debugPrint('[NotificationCard] Launch error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final secondaryColor = CupertinoDynamicColor.resolve(
      NelfundColors.secondaryLabel,
      context,
    );
    final badgeColor = item.badgeColor;
    final hasAction =
        item.actionUrl != null && item.actionUrl!.trim().isNotEmpty;

    return AppleFrostedCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      borderColor: item.isRead
          ? null
          : NelfundColors.emerald.withValues(alpha: 0.42),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.badge,
                  style: NelfundTypography.captionBold.copyWith(
                    color: badgeColor,
                    fontSize: 10.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (!item.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: NelfundColors.emerald,
                    shape: BoxShape.circle,
                  ),
                ),
              const Spacer(),
              Text(
                item.timestamp,
                style: NelfundTypography.footnote.copyWith(
                  fontSize: 11,
                  color: secondaryColor,
                ),
              ),
              const SizedBox(width: 6),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size(24, 24),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onDelete();
                },
                child: Icon(
                  CupertinoIcons.trash,
                  size: 15,
                  color: secondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.getLocalizedTitle(isHausa),
            style: NelfundTypography.headline.copyWith(fontSize: 15),
          ),
          const SizedBox(height: 5),
          Text(
            item.getLocalizedBody(isHausa),
            style: NelfundTypography.footnote.copyWith(
              fontSize: 13,
              height: 1.4,
              color: secondaryColor,
            ),
          ),
          if (hasAction) ...[
            const SizedBox(height: 10),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              color: NelfundColors.emerald.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              onPressed: () {
                HapticFeedback.lightImpact();
                onTap();
                unawaited(_launchActionUrl(item.actionUrl!));
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    CupertinoIcons.arrow_up_right_square_fill,
                    size: 14,
                    color: NelfundColors.emerald,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    openPortalLabel,
                    style: const TextStyle(
                      color: NelfundColors.emerald,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
