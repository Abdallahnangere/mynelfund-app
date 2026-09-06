import 'dart:ui';
import 'package:flutter/cupertino.dart';
import '../core/theme/nelfund_colors.dart';

/// An authentic Apple HIG frosted glass card with subtle border and blur.
class AppleFrostedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool hasBlur;
  final bool showShadow;

  const AppleFrostedCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.borderRadius = 16,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
    this.hasBlur = true,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = backgroundColor ??
        CupertinoDynamicColor.resolve(NelfundColors.frostedCard, context);
    final borderCol = borderColor ??
        CupertinoDynamicColor.resolve(NelfundColors.glassBorder, context);
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderCol,
          width: 0.8,
        ),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: isDark
                      ? const Color(0x33000000)
                      : const Color(0x0D000000),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: child,
    );

    if (hasBlur) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: content,
        ),
      );
    } else {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: content,
      );
    }

    if (margin != EdgeInsets.zero) {
      content = Padding(
        padding: margin,
        child: content,
      );
    }

    if (onTap != null) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        onPressed: onTap,
        child: content,
      );
    }

    return content;
  }
}
