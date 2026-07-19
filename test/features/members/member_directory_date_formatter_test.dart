import 'package:churchsnap/features/members/utils/member_directory_date_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MemberDirectoryDateFormatter', () {
    test('shows day and month as two-digit numbers', () {
      expect(
        MemberDirectoryDateFormatter.format(DateTime(2026, 7, 5)),
        '05/07/2026',
      );
    });

    test('shows a two-digit day later in the month', () {
      expect(
        MemberDirectoryDateFormatter.format(DateTime(2026, 12, 19)),
        '19/12/2026',
      );
    });

    test('uses the requested empty value when no date is stored', () {
      expect(MemberDirectoryDateFormatter.format(null), 'Not provided');
      expect(
        MemberDirectoryDateFormatter.format(
          null,
          emptyValue: 'Date unavailable',
        ),
        'Date unavailable',
      );
    });
  });
}
