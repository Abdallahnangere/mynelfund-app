import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// A Cupertino-styled frosted container with a continuous squircle radius,
/// crisp hairline border, and soft two-layer ambient elevation shadow.
///
/// Deliberately avoids per-card [BackdropFilter] layers inside scrollable
/// lists so 120Hz ProMotion scrolling stays jank-free while preserving the
/// signature Apple frosted aesthetic.
class AppleFrostedCard extends StatelessWidget {
  /// Creates an [AppleFrostedCard].
  const AppleFrostedCard({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 18.0,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0.75,
    this.onTap,
    this.semanticLabel,
  });

  /// Content displayed inside the card.
  final Widget child;

  /// Outer margin around the card container.
  final EdgeInsetsGeometry? margin;

  /// Inner padding around [child].
  final EdgeInsetsGeometry? padding;

  /// Corner radius for the continuous squircle silhouette.
  final double borderRadius;

  /// Optional custom card fill override.
  final Color? backgroundColor;

  /// Optional custom hairline border color override.
  final Color? borderColor;

  /// Thickness of the perimeter hairline border in logical pixels.
  final double borderWidth;

  /// Optional tap callback enabling gentle haptic feedback and semantic role.
  final VoidCallback? onTap;

  /// Optional accessibility label announced when [onTap] or semantics apply.
  final String? semanticLabel;

  static const CupertinoDynamicColor _defaultFill =
      CupertinoDynamicColor.withBrightness(
        color: Color(0xF5FFFFFF),
        darkColor: Color(0xEB1C1C1E),
      );

  static const CupertinoDynamicColor _defaultBorder =
      CupertinoDynamicColor.withBrightness(
        color: Color(0x16000000),
        darkColor: Color(0x26FFFFFF),
      );

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final resolvedFill =
        backgroundColor ?? CupertinoDynamicColor.resolve(_defaultFill, context);
    final resolvedBorder =
        borderColor ?? CupertinoDynamicColor.resolve(_defaultBorder, context);

    final decoration = BoxDecoration(
      color: resolvedFill,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: resolvedBorder, width: borderWidth),
      boxShadow: isDark
          ? const [
              BoxShadow(
                color: Color(0x3D000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ]
          : const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
              BoxShadow(
                color: Color(0x05000000),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
    );

    Widget content = Container(
      margin: margin,
      decoration: decoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      content = Semantics(
        button: true,
        label: semanticLabel,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            onTap!();
          },
          child: content,
        ),
      );
    } else if (semanticLabel != null) {
      content = Semantics(label: semanticLabel, child: content);
    }

    return content;
  }
}
