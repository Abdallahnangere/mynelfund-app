import 'package:flutter/cupertino.dart';
import 'nelfund_colors.dart';
import 'nelfund_typography.dart';

class NelfundTheme {
  NelfundTheme._();

  static CupertinoThemeData get lightTheme {
    return const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: NelfundColors.emerald,
      primaryContrastingColor: CupertinoColors.white,
      barBackgroundColor: Color(0xCCF8FAF8),
      scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
      textTheme: CupertinoTextThemeData(
        primaryColor: NelfundColors.emerald,
        navLargeTitleTextStyle: NelfundTypography.largeTitle,
        navTitleTextStyle: NelfundTypography.headline,
        textStyle: NelfundTypography.body,
        actionTextStyle: TextStyle(
          color: NelfundColors.emerald,
          fontWeight: FontWeight.w500,
          fontSize: 17,
        ),
        tabLabelTextStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  static CupertinoThemeData get darkTheme {
    return const CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: Color(0xFF2FD18B),
      primaryContrastingColor: CupertinoColors.black,
      barBackgroundColor: Color(0xCC161718),
      scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
      textTheme: CupertinoTextThemeData(
        primaryColor: Color(0xFF2FD18B),
        navLargeTitleTextStyle: NelfundTypography.largeTitle,
        navTitleTextStyle: NelfundTypography.headline,
        textStyle: NelfundTypography.body,
        actionTextStyle: TextStyle(
          color: Color(0xFF2FD18B),
          fontWeight: FontWeight.w500,
          fontSize: 17,
        ),
        tabLabelTextStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
