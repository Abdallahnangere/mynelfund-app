import 'package:flutter/cupertino.dart';

/// Sovereign Nigerian Emerald + Apple Cupertino HIG Color System
class NelfundColors {
  NelfundColors._();

  // Sovereign Brand Colors
  static const Color emerald = Color(0xFF008751);
  static const Color emeraldDark = Color(0xFF005C36);
  static const Color emeraldLight = Color(0xFFE1F5EC);
  static const Color emeraldAccent = Color(0xFF10B981);
  static const Color goldAccent = Color(0xFFC89A3B);

  // Dynamic Cupertino Surfaces
  static const CupertinoDynamicColor background =
      CupertinoColors.systemGroupedBackground;

  static const CupertinoDynamicColor secondaryBackground =
      CupertinoColors.secondarySystemGroupedBackground;

  static const CupertinoDynamicColor frostedCard =
      CupertinoDynamicColor.withBrightness(
        color: Color(0xE6FFFFFF),
        darkColor: Color(0xCC1E1E20),
      );

  static const CupertinoDynamicColor glassBorder =
      CupertinoDynamicColor.withBrightness(
        color: Color(0x14000000),
        darkColor: Color(0x26FFFFFF),
      );

  static const CupertinoDynamicColor emeraldTint =
      CupertinoDynamicColor.withBrightness(
        color: Color(0xFF008751),
        darkColor: Color(0xFF2FD18B),
      );

  // Typography Tokens
  static const CupertinoDynamicColor label = CupertinoColors.label;
  static const CupertinoDynamicColor secondaryLabel =
      CupertinoColors.secondaryLabel;
  static const CupertinoDynamicColor tertiaryLabel =
      CupertinoColors.tertiaryLabel;

  // Semantic Status Colors
  static const CupertinoDynamicColor success = CupertinoColors.systemGreen;
  static const CupertinoDynamicColor warning = CupertinoColors.systemOrange;
  static const CupertinoDynamicColor destructive = CupertinoColors.systemRed;
  static const CupertinoDynamicColor info = CupertinoColors.systemBlue;
}
