import 'package:churchsnap/features/web_admin/models/web_admin_value_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WebAdminValueFormatter', () {
    test('uses the first populated field', () {
      final value = WebAdminValueFormatter.text(
        const <String, dynamic>{'title': '', 'name': 'Church Family Night'},
        const ['title', 'name'],
      );

      expect(value, 'Church Family Night');
    });

    test('formats numeric and text money values', () {
      expect(WebAdminValueFormatter.money(25, currency: 'usd'), 'USD 25.00');
      expect(
        WebAdminValueFormatter.money('42.5', currency: 'JMD'),
        'JMD 42.50',
      );
    });

    test('formats DateTime values predictably', () {
      final value = WebAdminValueFormatter.date(DateTime(2026, 7, 18, 14, 5));

      expect(value, '2026-07-18 14:05');
    });
  });
}
