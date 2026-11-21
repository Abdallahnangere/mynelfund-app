import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../core/theme/nelfund_colors.dart';

/// Navigation item configuration rendered inside [LiquidGlassNavBar].
class LiquidGlassNavItem {
  /// Creates a [LiquidGlassNavItem].
  const LiquidGlassNavItem({
    required this.icon,
    required this.label,
    this.activeIcon,
  });

  /// Outline icon shown in the navigation tab.
  final IconData icon;

  /// Optional alternate icon for active emphasis; defaults to [icon].
  final IconData? activeIcon;

  /// Short tab label displayed beneath the icon.
  final String label;
}

/// Floating Apple-style translucent capsule bottom navigation bar.
///
/// Isolates blur rendering with a [RepaintBoundary] and preserves consistent
/// icon identifiers and haptic feedback across tab transitions.
class LiquidGlassNavBar extends StatelessWidget {
  /// Creates a [LiquidGlassNavBar].
  const LiquidGlassNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  /// Zero-based index of the currently active destination.
  final int currentIndex;

  /// Called with the selected tab index when the user taps an item.
  final ValueChanged<int> onTap;

  /// Ordered navigation destinations rendered across the capsule bar.
  final List<LiquidGlassNavItem> items;

  static const CupertinoDynamicColor _surfaceTint =
      CupertinoDynamicColor.withBrightness(
        color: Color(0xE8FFFFFF),
        darkColor: Color(0xDE1B1F1D),
      );

  static const CupertinoDynamicColor _borderTint =
      CupertinoDynamicColor.withBrightness(
        color: Color(0x1E000000),
        darkColor: Color(0x28FFFFFF),
      );

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final resolvedSurface = CupertinoDynamicColor.resolve(
      _surfaceTint,
      context,
    );
    final resolvedBorder = CupertinoDynamicColor.resolve(_borderTint, context);
    final inactiveColor = CupertinoDynamicColor.resolve(
      NelfundColors.secondaryLabel,
      context,
    );
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        14,
        0,
        14,
        bottomInset > 0 ? bottomInset + 6 : 12,
      ),
      child: RepaintBoundary(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: isDark
                ? const [
                    BoxShadow(
                      color: Color(0x52000000),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: Color(0x18000000),
                      blurRadius: 22,
                      offset: Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: resolvedSurface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: resolvedBorder, width: 0.75),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      for (var i = 0; i < items.length; i++)
                        Expanded(
                          child: _NavBarItemTile(
                            item: items[i],
                            isSelected: i == currentIndex,
                            inactiveColor: inactiveColor,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              onTap(i);
                            },
                          ),
                        ),
                    ],
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

class _NavBarItemTile extends StatelessWidget {
  const _NavBarItemTile({
    required this.item,
    required this.isSelected,
    required this.inactiveColor,
    required this.onTap,
  });

  final LiquidGlassNavItem item;
  final bool isSelected;
  final Color inactiveColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const activeTextColor = NelfundColors.emerald;
    final foregroundColor = isSelected ? activeTextColor : inactiveColor;

    return Semantics(
      button: true,
      selected: isSelected,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? NelfundColors.emerald.withValues(alpha: 0.14)
                : CupertinoColors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.06 : 1.0,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                child: Icon(
                  isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                  size: 21,
                  color: foregroundColor,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: foregroundColor,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
