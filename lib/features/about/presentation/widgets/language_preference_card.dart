import 'package:flutter/cupertino.dart';

import '../../../../core/localization/app_locale.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/theme/nelfund_colors.dart';
import '../../../../core/theme/nelfund_typography.dart';
import '../../../../shared/widgets/apple_frosted_card.dart';

/// Bilingual English / Hausa language preference card in [AboutView].
class LanguagePreferenceCard extends StatelessWidget {
  /// Creates a [LanguagePreferenceCard].
  const LanguagePreferenceCard({
    super.key,
    required this.localeProvider,
    required this.tr,
  });

  /// Active locale state provider.
  final LocaleProvider localeProvider;

  /// Active translation bundle.
  final AppTranslations tr;

  @override
  Widget build(BuildContext context) {
    final currentLang = localeProvider.currentLanguage;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppleFrostedCard(
        margin: EdgeInsets.zero,
        borderColor: NelfundColors.emerald.withValues(alpha: 0.35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: NelfundColors.emerald.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    CupertinoIcons.globe,
                    size: 18,
                    color: NelfundColors.emerald,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr.languageCardTitle,
                        style: NelfundTypography.headline.copyWith(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        tr.languageCardDesc,
                        style: NelfundTypography.caption.copyWith(
                          color: CupertinoDynamicColor.resolve(
                            NelfundColors.secondaryLabel,
                            context,
                          ),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _LanguageOptionTile(
                    flag: '🇬🇧',
                    label: 'English',
                    isSelected: currentLang == AppLanguage.english,
                    onTap: () =>
                        localeProvider.setLanguage(AppLanguage.english),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _LanguageOptionTile(
                    flag: '🇳🇬',
                    label: 'Hausa',
                    isSelected: currentLang == AppLanguage.hausa,
                    onTap: () => localeProvider.setLanguage(AppLanguage.hausa),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.flag,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String flag;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? NelfundColors.emerald.withValues(alpha: 0.15)
              : CupertinoDynamicColor.resolve(
                  CupertinoColors.systemGrey6,
                  context,
                ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? NelfundColors.emerald
                : CupertinoColors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(flag, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? NelfundColors.emerald
                    : CupertinoDynamicColor.resolve(
                        NelfundColors.label,
                        context,
                      ),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              const Icon(
                CupertinoIcons.checkmark_alt_circle_fill,
                color: NelfundColors.emerald,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
