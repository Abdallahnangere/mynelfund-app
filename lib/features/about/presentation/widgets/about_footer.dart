import 'package:flutter/cupertino.dart';

import '../../../../core/localization/app_translations.dart';
import '../../../../core/theme/nelfund_colors.dart';
import '../../../../core/theme/nelfund_typography.dart';

/// Footer metadata displaying creator attribution, ABU Zaria education line,
/// and Students Loans Act 2024 release citation.
class AboutFooter extends StatelessWidget {
  /// Creates an [AboutFooter].
  const AboutFooter({super.key, required this.tr});

  /// Active translation bundle.
  final AppTranslations tr;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                tr.isHausa ? 'An samar da shi da ' : 'Built with ',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const Icon(
                CupertinoIcons.heart_fill,
                color: CupertinoColors.systemRed,
                size: 15,
              ),
              Text(
                tr.isHausa
                    ? ' domin Ɗaliban Najeriya'
                    : ' for Nigerian Students',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${tr.isHausa ? 'daga' : 'from'} ${tr.developerName}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: NelfundColors.emerald,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            tr.developerEducation,
            textAlign: TextAlign.center,
            style: NelfundTypography.caption.copyWith(
              color: CupertinoDynamicColor.resolve(
                NelfundColors.tertiaryLabel,
                context,
              ),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            tr.isHausa
                ? 'Siffa ta 2.2.7+13 • Dokar Bashin Ɗalibai domin samar da ilimi mai zurfi ta shekarar 2024'
                : 'Version 2.2.7+13 • Students Loans (Access to Higher Education) Act 2024',
            textAlign: TextAlign.center,
            style: NelfundTypography.caption.copyWith(
              color: CupertinoDynamicColor.resolve(
                NelfundColors.tertiaryLabel,
                context,
              ),
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}
