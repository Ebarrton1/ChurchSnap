import 'package:flutter/material.dart';

import 'legacy_event_date_parser.dart';

class ChurchSnapDateFormatter {
  const ChurchSnapDateFormatter._();

  static String eventDateTime(
    BuildContext context,
    DateTime? value, {
    String fallback = '',
  }) {
    if (value != null) {
      return _formatDateTime(context, value.toLocal());
    }

    final parsed = LegacyEventDateParser.tryParse(fallback);

    if (parsed != null) {
      if (LegacyEventDateParser.hasExplicitTime(fallback)) {
        return _formatDateTime(context, parsed);
      }

      return fullDate(context, parsed);
    }

    return LegacyEventDateParser.normalizeLegacyText(fallback);
  }

  static String fullDate(
    BuildContext context,
    DateTime? value, {
    String fallback = 'Select date',
  }) {
    if (value == null) return fallback;

    return MaterialLocalizations.of(context).formatFullDate(value.toLocal());
  }

  static String _formatDateTime(BuildContext context, DateTime value) {
    final localizations = MaterialLocalizations.of(context);
    final dateLabel = localizations.formatFullDate(value);
    final timeLabel = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(value),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );

    return '$dateLabel • $timeLabel';
  }
}
