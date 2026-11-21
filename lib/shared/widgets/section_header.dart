import 'package:flutter/cupertino.dart';

import '../../core/theme/nelfund_colors.dart';
import '../../core/theme/nelfund_typography.dart';

/// Consistent grouped section title header following Apple Human Interface
/// Guidelines with optional subtitle and trailing badge or action widget.
class SectionHeader extends StatelessWidget {
  /// Creates a [SectionHeader].
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(20, 4, 20, 8),
  });

  /// Primary section title text.
  final String title;

  /// Optional supporting explanation displayed beneath [title].
  final String? subtitle;

  /// Optional widget aligned to the trailing edge (e.g., count pill or CTA).
  final Widget? trailing;

  /// Outer padding around the section header.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final secondaryColor = CupertinoDynamicColor.resolve(
      NelfundColors.secondaryLabel,
      context,
    );

    return Semantics(
      header: true,
      label: title,
      child: Padding(
        padding: padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: NelfundTypography.headline.copyWith(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.25,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: NelfundTypography.footnote.copyWith(
                        fontSize: 12.5,
                        color: secondaryColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ),
    );
  }
}
