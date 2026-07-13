class LegacyEventDateParser {
  const LegacyEventDateParser._();

  static final RegExp _numericDatePattern = RegExp(
    r'(?<!\d)(\d{1,2})[/-](\d{1,2})[/-](\d{4})(?!\d)',
  );

  static final RegExp _namedDatePattern = RegExp(
    r'\b(January|February|March|April|May|June|July|August|September|October|November|December)\s+(\d{1,2}),\s*(\d{4})\b',
    caseSensitive: false,
  );

  static final RegExp _timePattern = RegExp(
    r'(?<!\d)(\d{1,2}):(\d{2})\s*([AP])\.?\s*M\.?(?!\w)',
    caseSensitive: false,
  );

  static DateTime? tryParse(String value) {
    final raw = value.trim();
    if (raw.isEmpty) return null;

    final numericMatch = _numericDatePattern.firstMatch(raw);
    final namedMatch = _namedDatePattern.firstMatch(raw);
    final timeMatch = _timePattern.firstMatch(raw);

    int? year;
    int? month;
    int? day;

    if (numericMatch != null) {
      month = int.tryParse(numericMatch.group(1) ?? '');
      day = int.tryParse(numericMatch.group(2) ?? '');
      year = int.tryParse(numericMatch.group(3) ?? '');
    } else if (namedMatch != null) {
      month = _monthNumber(namedMatch.group(1) ?? '');
      day = int.tryParse(namedMatch.group(2) ?? '');
      year = int.tryParse(namedMatch.group(3) ?? '');
    }

    if (year == null || month == null || day == null) {
      return null;
    }

    var hour = 0;
    var minute = 0;

    if (timeMatch != null) {
      final parsedHour = int.tryParse(timeMatch.group(1) ?? '');
      final parsedMinute = int.tryParse(timeMatch.group(2) ?? '');
      final meridiem = (timeMatch.group(3) ?? '').toUpperCase();

      if (parsedHour == null ||
          parsedMinute == null ||
          parsedHour < 1 ||
          parsedHour > 12 ||
          parsedMinute < 0 ||
          parsedMinute > 59) {
        return null;
      }

      hour = parsedHour % 12;
      if (meridiem == 'P') hour += 12;
      minute = parsedMinute;
    }

    try {
      final parsed = DateTime(year, month, day, hour, minute);

      if (parsed.year != year ||
          parsed.month != month ||
          parsed.day != day ||
          parsed.hour != hour ||
          parsed.minute != minute) {
        return null;
      }

      return parsed;
    } on ArgumentError {
      return null;
    }
  }

  static bool hasExplicitTime(String value) {
    return _timePattern.hasMatch(value);
  }

  static String normalizeLegacyText(String value) {
    final raw = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (raw.isEmpty) return 'Date not provided';

    final numericMatch = _numericDatePattern.firstMatch(raw);
    final namedMatch = _namedDatePattern.firstMatch(raw);
    final timeMatch = _timePattern.firstMatch(raw);

    final dateMatch = numericMatch ?? namedMatch;

    if (dateMatch != null && timeMatch != null) {
      return '${dateMatch.group(0)} • ${timeMatch.group(0)}';
    }

    return raw
        .replaceAll('ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢', '•')
        .replaceAll('Ã¢â‚¬Â¢', '•')
        .replaceAll('â€¢', '•')
        .replaceAll(RegExp(r'\s*•\s*'), ' • ')
        .trim();
  }

  static int? _monthNumber(String value) {
    switch (value.toLowerCase()) {
      case 'january':
        return 1;
      case 'february':
        return 2;
      case 'march':
        return 3;
      case 'april':
        return 4;
      case 'may':
        return 5;
      case 'june':
        return 6;
      case 'july':
        return 7;
      case 'august':
        return 8;
      case 'september':
        return 9;
      case 'october':
        return 10;
      case 'november':
        return 11;
      case 'december':
        return 12;
    }

    return null;
  }
}
