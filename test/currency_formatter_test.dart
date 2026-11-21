import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_nelfund/core/formatters/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test(
      'formats Nigerian Naira amounts with two decimal places by default',
      () {
        expect(CurrencyFormatter.formatNaira(0), equals('₦0.00'));
        expect(CurrencyFormatter.formatNaira(20000), equals('₦20,000.00'));
        expect(CurrencyFormatter.formatNaira(70000), equals('₦70,000.00'));
        expect(CurrencyFormatter.formatNaira(-1500.5), equals('-₦1,500.50'));
      },
    );

    test('formats whole Naira amounts when includeDecimals is false', () {
      expect(
        CurrencyFormatter.formatNaira(150000, includeDecimals: false),
        equals('₦150,000'),
      );
      expect(
        CurrencyFormatter.formatNaira(double.nan, includeDecimals: false),
        equals('₦0'),
      );
    });

    test('formats grouped integers and handles non-finite inputs safely', () {
      expect(CurrencyFormatter.formatGrouped(1250000), equals('1,250,000'));
      expect(CurrencyFormatter.formatGrouped(double.infinity), equals('0'));
    });

    test('parses formatted strings back into numeric values', () {
      expect(CurrencyFormatter.parseAmount('₦150,000.50'), equals(150000.5));
      expect(CurrencyFormatter.parseAmount('invalid'), equals(0.0));
      expect(CurrencyFormatter.parseAmount(''), equals(0.0));
    });
  });

  group('ThousandsSeparatorInputFormatter', () {
    const formatter = ThousandsSeparatorInputFormatter();

    test('inserts thousands separators while keeping cursor aligned', () {
      const oldVal = TextEditingValue(
        text: '1,234',
        selection: TextSelection.collapsed(offset: 5),
      );
      const newVal = TextEditingValue(
        text: '1,2345',
        selection: TextSelection.collapsed(offset: 6),
      );

      final formatted = formatter.formatEditUpdate(oldVal, newVal);
      expect(formatted.text, equals('12,345'));
      expect(formatted.selection.baseOffset, equals(6));
    });

    test('clears cleanly when text becomes empty', () {
      const oldVal = TextEditingValue(text: '1');
      const newVal = TextEditingValue(text: '');

      final formatted = formatter.formatEditUpdate(oldVal, newVal);
      expect(formatted.text, isEmpty);
      expect(formatted.selection.baseOffset, equals(0));
    });
  });
}
