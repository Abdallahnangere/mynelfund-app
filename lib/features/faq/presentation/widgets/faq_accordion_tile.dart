import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../../core/localization/app_locale.dart';
import '../../../../core/theme/nelfund_colors.dart';
import '../../../../core/theme/nelfund_typography.dart';
import '../../../../shared/widgets/apple_frosted_card.dart';
import '../../domain/faq_model.dart';

/// Expandable frosted accordion tile presenting a statutory FAQ question,
/// authoritative answer, and Act 2024 reference pill.
class FaqAccordionTile extends StatelessWidget {
  /// Creates a [FaqAccordionTile].
  const FaqAccordionTile({
    super.key,
    required this.item,
    required this.isExpanded,
    required this.language,
    required this.onToggle,
  });

  /// FAQ record to render.
  final FaqItem item;

  /// Whether the answer drawer is currently open.
  final bool isExpanded;

  /// Active display language.
  final AppLanguage language;

  /// Called when the user taps the question header.
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final question = item.getQuestion(language);
    final answer = item.getAnswer(language);
    final reference = item.getStatutoryReference(language);
    final secondaryColor = CupertinoDynamicColor.resolve(
      NelfundColors.secondaryLabel,
      context,
    );

    return Semantics(
      button: true,
      expanded: isExpanded,
      label: question,
      child: AppleFrostedCard(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: EdgeInsets.zero,
        borderColor: isExpanded
            ? NelfundColors.emerald.withValues(alpha: 0.4)
            : null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            onToggle();
          },
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: NelfundColors.emerald.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.category.getShortLabel(language),
                        style: NelfundTypography.captionBold.copyWith(
                          color: NelfundColors.emerald,
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      child: Icon(
                        CupertinoIcons.chevron_down,
                        size: 16,
                        color: isExpanded
                            ? NelfundColors.emerald
                            : secondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  question,
                  style: NelfundTypography.headline.copyWith(
                    fontSize: 14.5,
                    height: 1.32,
                  ),
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 220),
                  sizeCurve: Curves.easeOutCubic,
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox(width: double.infinity, height: 0),
                  secondChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        height: 0.75,
                        color: NelfundColors.emerald.withValues(alpha: 0.16),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        answer,
                        style: NelfundTypography.body.copyWith(
                          fontSize: 13.5,
                          height: 1.45,
                          color: secondaryColor,
                        ),
                      ),
                      if (reference.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              CupertinoIcons.book_circle_fill,
                              size: 14,
                              color: NelfundColors.emerald,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                reference,
                                style: NelfundTypography.captionBold.copyWith(
                                  color: NelfundColors.emerald,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
