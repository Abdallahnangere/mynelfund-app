import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Shared Nigerian Naira currency and numeric formatting utilities.
///
/// Reuses static cached [NumberFormat] instances to avoid allocating formatters
/// inside widget build methods and tight calculation loops.
abstract final class CurrencyFormatter {
  static final NumberFormat _nairaDecimalFormat = NumberFormat(
    '#,##0.00',
    'en_US',
  );
  static final NumberFormat _groupedIntegerFormat = NumberFormat(
    '#,##0',
    'en_US',
  );

  /// Formats [amount] as Nigerian Naira, defaulting to two decimal places
  /// (e.g. `₦70,000.00`).
  static String formatNaira(num amount, {bool includeDecimals = true}) {
    final value = amount.toDouble();
    if (!value.isFinite) {
      return includeDecimals ? '₦0.00' : '₦0';
    }

    final prefix = value < 0 ? '-₦' : '₦';
    final magnitude = value.abs();

    if (includeDecimals) {
      return '$prefix${_nairaDecimalFormat.format(magnitude)}';
    }
    return '$prefix${_groupedIntegerFormat.format(magnitude.round())}';
  }

  /// Formats an integer or numeric value with thousands grouping separators
  /// without a currency prefix (e.g. `70,000`).
  static String formatGrouped(num value) {
    final numeric = value.toDouble();
    if (!numeric.isFinite) {
      return '0';
    }
    final prefix = numeric < 0 ? '-' : '';
    return '$prefix${_groupedIntegerFormat.format(numeric.abs().round())}';
  }

  /// Parses a user-entered formatted currency string (e.g. `'₦70,000'`) into
  /// a finite non-negative `double`, returning `0.0` for invalid inputs.
  static double parseAmount(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleaned.isEmpty) {
      return 0.0;
    }
    final firstDot = cleaned.indexOf('.');
    final normalized = firstDot == -1
        ? cleaned
        : '${cleaned.substring(0, firstDot + 1)}'
              '${cleaned.substring(firstDot + 1).replaceAll('.', '')}';
    final parsed = double.tryParse(normalized);
    if (parsed == null || !parsed.isFinite) {
      return 0.0;
    }
    return parsed;
  }
}

/// Formats numeric text field input with thousands separators (`12345` ->
/// `12,345`) while preserving the logical cursor position after editing.
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  /// Creates a [ThousandsSeparatorInputFormatter] optionally capped at
  /// [maxDigits] numeric characters.
  const ThousandsSeparatorInputFormatter({this.maxDigits = 12});

  /// Maximum number of raw numeric digits permitted.
  final int maxDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final selectionEnd = newValue.selection.end.clamp(0, newValue.text.length);
    final digitsBeforeCursor = newValue.text
        .substring(0, selectionEnd)
        .replaceAll(RegExp(r'[^0-9]'), '')
        .length;

    var rawDigits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (rawDigits.length > maxDigits) {
      rawDigits = rawDigits.substring(0, maxDigits);
    }

    if (rawDigits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final parsed = int.tryParse(rawDigits);
    if (parsed == null) {
      return oldValue;
    }

    final formatted = CurrencyFormatter.formatGrouped(parsed);

    var targetOffset = 0;
    var seenDigits = 0;
    while (targetOffset < formatted.length && seenDigits < digitsBeforeCursor) {
      if (RegExp(r'[0-9]').hasMatch(formatted[targetOffset])) {
        seenDigits++;
      }
      targetOffset++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: targetOffset),
    );
  }
}
