import 'package:flutter/cupertino.dart';

import '../../../../core/localization/app_translations.dart';
import '../../../../core/theme/nelfund_colors.dart';
import '../../../../core/theme/nelfund_typography.dart';
import '../../../../shared/widgets/apple_frosted_card.dart';

/// Card presenting direct links to official NELFUND portal and enquiries email.
class OfficialChannelsCard extends StatelessWidget {
  /// Creates an [OfficialChannelsCard].
  const OfficialChannelsCard({
    super.key,
    required this.tr,
    required this.nelfundEmail,
    required this.onOpenPortalTap,
    required this.onSendEmailTap,
  });

  /// Active translation bundle.
  final AppTranslations tr;

  /// Official NELFUND email address.
  final String nelfundEmail;

  /// Handler for opening `https://nelf.gov.ng`.
  final VoidCallback onOpenPortalTap;

  /// Handler for opening email client.
  final VoidCallback onSendEmailTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppleFrostedCard(
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  CupertinoIcons.building_2_fill,
                  color: NelfundColors.emerald,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tr.officialChannelsTitle,
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
              tr.officialChannelsDesc,
              style: NelfundTypography.footnote.copyWith(
                color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel,
                  context,
                ),
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 14),
            _OfficialChannelRow(
              icon: CupertinoIcons.globe,
              iconColor: NelfundColors.emerald,
              title: tr.officialPortalTitle,
              subtitle: 'nelf.gov.ng',
              buttonLabel: tr.isHausa ? 'Buɗe Shafin' : 'Open Portal',
              onTap: onOpenPortalTap,
            ),
            const SizedBox(height: 10),
            _OfficialChannelRow(
              icon: CupertinoIcons.mail_solid,
              iconColor: CupertinoColors.systemBlue,
              title: tr.officialEmailTitle,
              subtitle: nelfundEmail,
              buttonLabel: tr.isHausa ? 'Tura Imel' : 'Send Email',
              onTap: onSendEmailTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _OfficialChannelRow extends StatelessWidget {
  const _OfficialChannelRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          CupertinoColors.systemGrey6,
          context,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: NelfundTypography.headline.copyWith(fontSize: 13.5),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: NelfundTypography.captionBold.copyWith(
                    color: iconColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            color: iconColor,
            borderRadius: BorderRadius.circular(16),
            minimumSize: Size.zero,
            onPressed: onTap,
            child: Text(
              buttonLabel,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
