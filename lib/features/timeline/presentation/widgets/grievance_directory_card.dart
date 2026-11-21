import 'package:flutter/cupertino.dart';

import '../../../../core/localization/app_translations.dart';
import '../../../../core/theme/nelfund_colors.dart';
import '../../../../core/theme/nelfund_typography.dart';
import '../../../../shared/widgets/apple_frosted_card.dart';

/// Displays Section 6.0 official escalation channels when an application
/// exceeds statutory SLA turnaround limits.
class GrievanceDirectoryCard extends StatelessWidget {
  /// Creates a [GrievanceDirectoryCard].
  const GrievanceDirectoryCard({super.key, required this.tr});

  /// Active translation bundle.
  final AppTranslations tr;

  @override
  Widget build(BuildContext context) {
    final isHa = tr.isHausa;

    return AppleFrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.speaker_2_fill,
                color: NelfundColors.emerald,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isHa
                      ? 'Hanyoyin Tuntuba da Shigar da Ƙorafi na Hukuma'
                      : 'Official Support & Complaints Channels',
                  style: NelfundTypography.headline.copyWith(fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isHa
                ? "Ƙarƙashin Sashe na 6.0 na Dokar, idan aikace-aikacenka ya wuce wa'adin da doka ta ƙayyade ba tare da wani bayani a rubuce ba, shigar da bincike a hukumance tare da lambar aikace-aikacenka:"
                : 'Under Section 6.0 of the Act, if your application exceeds statutory turnaround times without written explanation, lodge an official inquiry with your Application ID:',
            style: NelfundTypography.footnote.copyWith(
              color: CupertinoDynamicColor.resolve(
                NelfundColors.secondaryLabel,
                context,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _DirectoryItem(
            icon: CupertinoIcons.globe,
            title: isHa ? 'Shafin Yanar Gizo na Hukuma' : 'Official Portal',
            value: 'nelf.gov.ng',
          ),
          _DirectoryItem(
            icon: CupertinoIcons.mail_solid,
            title: isHa ? 'Imel na Ƙorafi' : 'Grievance Email',
            value: 'support@nelf.gov.ng',
          ),
          _DirectoryItem(
            icon: CupertinoIcons.building_2_fill,
            title: isHa ? 'Tallafin Makaranta' : 'Campus Support',
            value: isHa
                ? "Ofishin Dean na Harkokin Ɗalibai / Jami'in NELFUND na Makaranta"
                : 'Dean of Student Affairs / NELFUND Desk Officer',
          ),
        ],
      ),
    );
  }
}

class _DirectoryItem extends StatelessWidget {
  const _DirectoryItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: NelfundColors.emerald),
          const SizedBox(width: 8),
          Text(
            '$title: ',
            style: NelfundTypography.captionBold.copyWith(fontSize: 12),
          ),
          Expanded(
            child: Text(
              value,
              style: NelfundTypography.footnote.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
