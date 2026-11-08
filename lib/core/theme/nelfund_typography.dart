import 'package:flutter/cupertino.dart';
import 'nelfund_colors.dart';

/// Apple Human Interface Guidelines Typography Scale
class NelfundTypography {
  NelfundTypography._();

  static const TextStyle largeTitle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.37,
    color: NelfundColors.label,
  );

  static const TextStyle title1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.36,
    color: NelfundColors.label,
  );

  static const TextStyle title2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.35,
    color: NelfundColors.label,
  );

  static const TextStyle title3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.38,
    color: NelfundColors.label,
  );

  static const TextStyle headline = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.41,
    color: NelfundColors.label,
  );

  static const TextStyle body = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.41,
    height: 1.35,
    color: NelfundColors.label,
  );

  static const TextStyle callout = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.32,
    color: NelfundColors.label,
  );

  static const TextStyle subhead = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.24,
    color: NelfundColors.secondaryLabel,
  );

  static const TextStyle footnote = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.08,
    color: NelfundColors.secondaryLabel,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    color: NelfundColors.tertiaryLabel,
  );

  static const TextStyle captionBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.0,
    color: NelfundColors.secondaryLabel,
  );
}
