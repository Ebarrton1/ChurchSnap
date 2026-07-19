import 'package:cloud_firestore/cloud_firestore.dart';

class WebAdminValueFormatter {
  const WebAdminValueFormatter._();

  static String text(
    Map<String, dynamic> data,
    List<String> keys, {
    String fallback = 'Not provided',
  }) {
    for (final key in keys) {
      final value = data[key];
      final normalized = value?.toString().trim() ?? '';

      if (normalized.isNotEmpty) {
        return normalized;
      }
    }

    return fallback;
  }

  static DateTime? dateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  static String date(dynamic value, {String fallback = 'Date not set'}) {
    final parsed = dateTime(value);

    if (parsed == null) {
      return fallback;
    }

    final local = parsed.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '${local.year}-$month-$day $hour:$minute';
  }

  static String money(
    dynamic value, {
    String currency = 'USD',
    String fallback = 'Amount not set',
  }) {
    final amount = switch (value) {
      num number => number.toDouble(),
      String text => double.tryParse(text.trim()),
      _ => null,
    };

    if (amount == null) {
      return fallback;
    }

    final normalizedCurrency = currency.trim().isEmpty
        ? 'USD'
        : currency.trim().toUpperCase();

    return '$normalizedCurrency ${amount.toStringAsFixed(2)}';
  }
}
