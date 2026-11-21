import 'package:flutter/cupertino.dart';

import '../../../../core/theme/nelfund_colors.dart';

/// Search bar for filtering statutory FAQ entries by question, answer, or
/// Students Loans Act 2024 section keywords.
class FaqSearchBar extends StatelessWidget {
  /// Creates a [FaqSearchBar].
  const FaqSearchBar({
    super.key,
    required this.controller,
    required this.placeholder,
    required this.onChanged,
  });

  /// Controller backing the search text input.
  final TextEditingController controller;

  /// Localized placeholder text.
  final String placeholder;

  /// Called on every search query change.
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: CupertinoSearchTextField(
        controller: controller,
        placeholder: placeholder,
        onChanged: onChanged,
        backgroundColor: CupertinoDynamicColor.resolve(
          const CupertinoDynamicColor.withBrightness(
            color: Color(0xFFE9F0EC),
            darkColor: Color(0xFF1D2420),
          ),
          context,
        ),
        borderRadius: BorderRadius.circular(14),
        prefixInsets: const EdgeInsetsDirectional.fromSTEB(12, 0, 6, 0),
        padding: const EdgeInsetsDirectional.fromSTEB(4, 11, 10, 11),
        style: TextStyle(
          fontSize: 14.5,
          color: CupertinoDynamicColor.resolve(NelfundColors.label, context),
        ),
        placeholderStyle: TextStyle(
          fontSize: 14,
          color: isDark
              ? const Color(0xFF8E9992)
              : CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel,
                  context,
                ),
        ),
      ),
    );
  }
}
