import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../../core/localization/app_locale.dart';
import '../../../../core/theme/nelfund_colors.dart';
import '../../domain/faq_model.dart';

/// Horizontal scrollable category pill bar filtering [FaqCategory] topics.
class FaqCategoryFilter extends StatelessWidget {
  /// Creates a [FaqCategoryFilter].
  const FaqCategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.language,
    required this.onSelected,
  });

  /// Currently active filter category.
  final FaqCategory selectedCategory;

  /// Active UI language.
  final AppLanguage language;

  /// Called when a user taps a category chip.
  final ValueChanged<FaqCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: FaqCategory.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = FaqCategory.values[index];
          final isSelected = category == selectedCategory;
          final label = category.getShortLabel(language);

          return Semantics(
            button: true,
            selected: isSelected,
            label: category.getTitle(language),
            child: GestureDetector(
              onTap: () {
                if (!isSelected) {
                  HapticFeedback.selectionClick();
                  onSelected(category);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? NelfundColors.emerald
                      : (isDark
                            ? const Color(0xFF1E2521)
                            : const Color(0xFFFFFFFF)),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected
                        ? NelfundColors.emerald
                        : NelfundColors.emerald.withValues(alpha: 0.25),
                    width: 0.85,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: NelfundColors.emerald.withValues(
                              alpha: 0.28,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? CupertinoColors.white
                          : CupertinoDynamicColor.resolve(
                              NelfundColors.label,
                              context,
                            ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
