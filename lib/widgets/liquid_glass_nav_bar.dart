import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../core/theme/nelfund_colors.dart';

class LiquidGlassNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const LiquidGlassNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// A floating liquid glass navigation dock with liquid specular border refraction,
/// frosted backdrop blur, and an animated fluid active tab indicator.
class LiquidGlassNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<LiquidGlassNavItem> items;

  const LiquidGlassNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 50;

    // Translucent liquid glass colors
    final glassBg = isDark
        ? const Color(0x99161A18)
        : const Color(0x88F0F7F3);

    final borderTopColor = isDark
        ? const Color(0x80FFFFFF)
        : const Color(0xB3FFFFFF);

    final borderBottomColor = isDark
        ? NelfundColors.emerald.withValues(alpha: 0.40)
        : NelfundColors.emerald.withValues(alpha: 0.30);

    return IgnorePointer(
      ignoring: isKeyboardOpen,
      child: AnimatedSlide(
        offset: isKeyboardOpen ? const Offset(0, 1.4) : Offset.zero,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeInOutCubic,
        child: AnimatedOpacity(
          opacity: isKeyboardOpen ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? const Color(0x50000000)
                      : const Color(0x18002E1B),
                  blurRadius: 18,
                  spreadRadius: 0,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: NelfundColors.emerald.withValues(alpha: isDark ? 0.12 : 0.08),
                  blurRadius: 24,
                  spreadRadius: -2,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: glassBg,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: borderTopColor,
                      width: 0.8,
                    ),
                  ),
            child: CustomPaint(
              foregroundPainter: _LiquidGlassBorderPainter(
                borderTopColor: borderTopColor,
                borderBottomColor: borderBottomColor,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = constraints.maxWidth / items.length;
                    final activeAlignX = items.length > 1
                        ? -1.0 + (selectedIndex / (items.length - 1)) * 2.0
                        : 0.0;

                    return Stack(
                      children: [
                        // Fluid Active Pill Indicator
                        AnimatedAlign(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment(activeAlignX, 0),
                          child: Container(
                            width: itemWidth - 4,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: isDark
                                    ? [
                                        NelfundColors.emerald.withValues(alpha: 0.35),
                                        NelfundColors.emeraldDark.withValues(alpha: 0.25),
                                      ]
                                    : [
                                        NelfundColors.emerald.withValues(alpha: 0.22),
                                        NelfundColors.emeraldLight.withValues(alpha: 0.30),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0x4D68D391)
                                    : NelfundColors.emerald.withValues(alpha: 0.35),
                                width: 0.8,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: NelfundColors.emerald.withValues(alpha: 0.20),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Navigation Items
                        Row(
                          children: List.generate(items.length, (index) {
                            final item = items[index];
                            final isSelected = selectedIndex == index;

                            return Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  if (!isSelected) {
                                    HapticFeedback.selectionClick();
                                  }
                                  onTap(index);
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedScale(
                                      scale: isSelected ? 1.12 : 1.0,
                                      duration: const Duration(milliseconds: 200),
                                      curve: Curves.easeOut,
                                      child: Icon(
                                        isSelected ? item.activeIcon : item.icon,
                                        size: 21,
                                        color: isSelected
                                            ? (isDark
                                                ? const Color(0xFF68D391)
                                                : NelfundColors.emeraldDark)
                                            : CupertinoDynamicColor.resolve(
                                                CupertinoColors.secondaryLabel,
                                                context,
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 200),
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color: isSelected
                                            ? (isDark
                                                ? const Color(0xFF68D391)
                                                : NelfundColors.emeraldDark)
                                            : CupertinoDynamicColor.resolve(
                                                CupertinoColors.secondaryLabel,
                                                context,
                                              ),
                                      ),
                                      child: Text(
                                        item.label,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  ),
),
);
  }
}

class _LiquidGlassBorderPainter extends CustomPainter {
  final Color borderTopColor;
  final Color borderBottomColor;

  _LiquidGlassBorderPainter({
    required this.borderTopColor,
    required this.borderBottomColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(32));

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          borderTopColor,
          borderTopColor.withValues(alpha: 0.2),
          borderBottomColor,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _LiquidGlassBorderPainter oldDelegate) {
    return oldDelegate.borderTopColor != borderTopColor ||
        oldDelegate.borderBottomColor != borderBottomColor;
  }
}
