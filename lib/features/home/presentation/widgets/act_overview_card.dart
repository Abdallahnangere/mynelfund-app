import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../../app/app.dart';
import '../../../../core/constants/nelfund_data.dart';
import '../../../../core/localization/app_locale.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/theme/nelfund_colors.dart';
import '../../../../core/theme/nelfund_typography.dart';
import '../../../../shared/widgets/apple_frosted_card.dart';

/// Displays the statutory Students Loans (Access to Higher Education) Act 2024
/// overview and its primary student loan protection provisions.
class ActOverviewCard extends StatelessWidget {
  /// Creates an [ActOverviewCard].
  const ActOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLang = AppProviders.maybeRead<LocaleProvider>(context) != null
        ? context.select<LocaleProvider, AppLanguage>((p) => p.currentLanguage)
        : AppLanguage.english;
    final tr = AppTranslations.of(context);
    final actTitle = NelfundData.getActTitle(currentLang);
    final actSummary = NelfundData.getActSummary(currentLang);

    return AppleFrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.book_fill,
                color: NelfundColors.emerald,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  actTitle,
                  style: NelfundTypography.headline.copyWith(fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            actSummary,
            style: NelfundTypography.body.copyWith(
              fontSize: 14,
              color: CupertinoDynamicColor.resolve(
                NelfundColors.secondaryLabel,
                context,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            tr.primaryLegalProvisionsTitle,
            style: NelfundTypography.captionBold.copyWith(
              color: CupertinoDynamicColor.resolve(
                NelfundColors.label,
                context,
              ),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          _BulletItem(text: tr.provisionRepealedAct),
          _BulletItem(text: tr.provisionNoGuarantor),
          _BulletItem(text: tr.provisionTwoYearGrace),
          _BulletItem(text: tr.provisionUnemploymentForgiveness),
        ],
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  const _BulletItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: NelfundColors.emerald)),
          Expanded(child: Text(text, style: NelfundTypography.footnote)),
        ],
      ),
    );
  }
}
