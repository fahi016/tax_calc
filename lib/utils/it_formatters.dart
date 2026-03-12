import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ItFormatters {
  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _amount = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '\u20B9', // ₹ as Unicode escape — safe for both Flutter UI and PDF
    decimalDigits: 0,
  );

  static final DateFormat _month = DateFormat('MMM-yyyy');

  /// Use in Flutter UI widgets
  static String formatCurrency(num value) => _currency.format(value);

  /// Use in PDF — same output but defined explicitly with Unicode escape
  /// so it's clear the ₹ glyph is intentional and font must support U+20B9
  static String formatAmount(num value) => _amount.format(value);

  static String formatMonth(DateTime date) => _month.format(date);
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}