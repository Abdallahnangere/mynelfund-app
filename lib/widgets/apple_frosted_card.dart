import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../core/theme/nelfund_colors.dart';

/// An authentic Apple HIG & Liquid Glass frosted card with specular light border,
/// glass reflection sheen, and hardware-accelerated backdrop blur.
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
  final bool showSpecularShine;

  const AppleFrostedCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.borderRadius = 16,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
    this.hasBlur = false,
    this.showShadow = true,
    this.showSpecularShine = true,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = backgroundColor ??
        CupertinoDynamicColor.resolve(NelfundColors.frostedCard, context);
    final borderCol = borderColor ??
        CupertinoDynamicColor.resolve(NelfundColors.glassBorder, context);
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    Widget cardBody = Container(
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
                      ? const Color(0x40000000)
                      : const Color(0x0F002E1B),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
                if (showSpecularShine)
                  BoxShadow(
                    color: NelfundColors.emerald.withValues(alpha: isDark ? 0.08 : 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 2),
                    spreadRadius: -2,
                  ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          if (showSpecularShine)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        (isDark ? CupertinoColors.white : CupertinoColors.white)
                            .withValues(alpha: isDark ? 0.06 : 0.25),
                        CupertinoColors.white.withValues(alpha: 0.0),
                        (isDark ? NelfundColors.emerald : NelfundColors.emerald)
                            .withValues(alpha: isDark ? 0.04 : 0.03),
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          child,
        ],
      ),
    );

    if (hasBlur) {
      cardBody = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: cardBody,
        ),
      );
    } else {
      cardBody = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: cardBody,
      );
    }

    if (margin != EdgeInsets.zero) {
      cardBody = Padding(
        padding: margin,
        child: cardBody,
      );
    }

    if (onTap != null) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        onPressed: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        child: cardBody,
      );
    }

    return cardBody;
  }
}
