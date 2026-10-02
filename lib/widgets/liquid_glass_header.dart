import 'dart:ui';
import 'package:flutter/cupertino.dart';
import '../core/theme/nelfund_colors.dart';
import '../core/theme/nelfund_typography.dart';

/// A reusable liquid glass header container with frosted backdrop blur,
/// specular edge refraction, and optional bottom slots for tab filters or search boxes.
class LiquidGlassHeader extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? bottom;
  final EdgeInsetsGeometry padding;

  const LiquidGlassHeader({
    super.key,
    required this.title,
    this.leading,
    this.subtitle,
    this.trailing,
    this.bottom,
    this.padding = const EdgeInsets.fromLTRB(16, 10, 16, 12),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    final headerBg = isDark
        ? const Color(0x99141816)
        : const Color(0x8CF0F5F2);

    final borderBottomColor = isDark
        ? const Color(0x4068D391)
        : NelfundColors.emerald.withValues(alpha: 0.28);

    final borderTopColor = isDark
        ? const Color(0x66FFFFFF)
        : const Color(0x99FFFFFF);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: headerBg,
            border: Border(
              bottom: BorderSide(
                color: borderBottomColor,
                width: 0.8,
              ),
              top: BorderSide(
                color: borderTopColor,
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? const Color(0x33000000)
                    : const Color(0x0A000000),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: NelfundTypography.title2.copyWith(
                            fontSize: 19.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null && subtitle!.isNotEmpty) ...[
                          const SizedBox(height: 1),
                          Text(
                            subtitle!,
                            style: NelfundTypography.footnote.copyWith(
                              color: CupertinoDynamicColor.resolve(
                                NelfundColors.secondaryLabel,
                                context,
                              ),
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
    );
  }
}
