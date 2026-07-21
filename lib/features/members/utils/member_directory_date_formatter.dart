class MemberDirectoryDateFormatter {
  const MemberDirectoryDateFormatter._();

  static String format(DateTime? value, {String emptyValue = 'Not provided'}) {
    if (value == null) {
      return emptyValue;
    }

    final localDate = value.toLocal();
    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');

    return '$day/$month/${localDate.year}';
  }
}
