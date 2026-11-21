import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../core/theme/nelfund_colors.dart';
import '../../core/theme/nelfund_typography.dart';

/// Translucent Cupertino glass top header bar with optional leading slot,
/// back navigation button, subtitle, and trailing action widget.
///
/// Wraps its blurred backdrop in a [RepaintBoundary] to isolate compositing
/// layers from scrolling page content below it.
class LiquidGlassHeader extends StatelessWidget {
  /// Creates a [LiquidGlassHeader].
  const LiquidGlassHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.bottom,
    this.showBackButton = false,
    this.onBack,
    this.padding = const EdgeInsets.fromLTRB(16, 10, 16, 12),
  });

  /// Primary screen heading displayed in prominent iOS navigation typography.
  final String title;

  /// Optional secondary descriptor shown beneath [title].
  final String? subtitle;

  /// Optional custom leading widget (ignored when [showBackButton] is true).
  final Widget? leading;

  /// Optional trailing action control (e.g., help button or status pill).
  final Widget? trailing;

  /// Optional secondary bar rendered directly beneath the primary header row.
  final Widget? bottom;

  /// Whether to show a Cupertino back button in the leading slot.
  final bool showBackButton;

  /// Optional custom handler when the back button is tapped.
  final VoidCallback? onBack;

  /// Internal header padding.
  final EdgeInsetsGeometry padding;

  static const CupertinoDynamicColor _glassTint =
      CupertinoDynamicColor.withBrightness(
        color: Color(0xDCF7FAF8),
        darkColor: Color(0xD6121614),
      );

  static const CupertinoDynamicColor _hairline =
      CupertinoDynamicColor.withBrightness(
        color: Color(0x18000000),
        darkColor: Color(0x26FFFFFF),
      );

  @override
  Widget build(BuildContext context) {
    final tint = CupertinoDynamicColor.resolve(_glassTint, context);
    final hairlineColor = CupertinoDynamicColor.resolve(_hairline, context);
    final secondaryColor = CupertinoDynamicColor.resolve(
      NelfundColors.secondaryLabel,
      context,
    );

    final Widget? effectiveLeading = showBackButton
        ? Semantics(
            button: true,
            label: 'Back',
            child: CupertinoButton(
              padding: const EdgeInsets.only(right: 6),
              minimumSize: const Size(36, 36),
              onPressed: () {
                HapticFeedback.lightImpact();
                if (onBack != null) {
                  onBack!();
                } else {
                  Navigator.of(context).maybePop();
                }
              },
              child: const Icon(
                CupertinoIcons.back,
                color: NelfundColors.emerald,
                size: 24,
              ),
            ),
          )
        : leading;

    return RepaintBoundary(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: tint,
              border: Border(
                bottom: BorderSide(color: hairlineColor, width: 0.75),
              ),
            ),
            child: Semantics(
              header: true,
              label: title,
              child: Padding(
                padding: padding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        if (effectiveLeading != null) ...[
                          effectiveLeading,
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: NelfundTypography.headline.copyWith(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.35,
                                ),
                              ),
                              if (subtitle != null && subtitle!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: NelfundTypography.footnote.copyWith(
                                    fontSize: 12,
                                    color: secondaryColor,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (trailing != null) ...[
                          const SizedBox(width: 8),
                          trailing!,
                        ],
                      ],
                    ),
                    if (bottom != null) ...[
                      const SizedBox(height: 10),
                      bottom!,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
