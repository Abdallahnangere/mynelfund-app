import 'package:flutter/cupertino.dart';

import '../../../../core/localization/app_locale.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/theme/nelfund_colors.dart';
import '../../../../core/theme/nelfund_typography.dart';
import '../../../../shared/widgets/apple_frosted_card.dart';
import '../../domain/eligibility_model.dart';

/// Segmented stream selector distinguishing Fresh Entry (100L JAMB), Direct
/// Entry (200L/DE), and Returning Undergraduates.
class EntryTypeSelector extends StatelessWidget {
  /// Creates an [EntryTypeSelector].
  const EntryTypeSelector({
    super.key,
    required this.selectedType,
    required this.language,
    required this.tr,
    required this.onChanged,
  });

  /// Currently active academic stream.
  final AcademicEntryType selectedType;

  /// Active language.
  final AppLanguage language;

  /// Active translations.
  final AppTranslations tr;

  /// Invoked when the user switches academic stream.
  final ValueChanged<AcademicEntryType> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppleFrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr.academicStreamTitle,
            style: NelfundTypography.headline.copyWith(fontSize: 15),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: CupertinoSlidingSegmentedControl<AcademicEntryType>(
              groupValue: selectedType,
              children: {
                AcademicEntryType.freshEntry: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    AcademicEntryType.freshEntry.getLocalizedName(language),
                    style: NelfundTypography.footnote,
                  ),
                ),
                AcademicEntryType.directEntry: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    AcademicEntryType.directEntry.getLocalizedName(language),
                    style: NelfundTypography.footnote,
                  ),
                ),
                AcademicEntryType.undergraduate: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    AcademicEntryType.undergraduate.getLocalizedName(language),
                    style: NelfundTypography.footnote,
                  ),
                ),
              },
              onValueChanged: (value) {
                if (value != null) {
                  onChanged(value);
                }
              },
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: CupertinoDynamicColor.resolve(
                const CupertinoDynamicColor.withBrightness(
                  color: Color(0x0C008751),
                  darkColor: Color(0x1F008751),
                ),
                context,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              selectedType.getLocalizedDescription(language),
              style: NelfundTypography.footnote.copyWith(
                color: NelfundColors.emerald,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
