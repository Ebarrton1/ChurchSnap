import 'package:churchsnap/features/web_admin/models/web_admin_donation_amount.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WebAdminDonationAmount', () {
    test('reads the canonical amountCents field as major currency units', () {
      expect(
        WebAdminDonationAmount.read(const <String, dynamic>{
          'amountCents': 1234,
        }),
        12.34,
      );
    });

    test('keeps supporting the legacy amount field', () {
      expect(
        WebAdminDonationAmount.read(const <String, dynamic>{
          'amount': 45.67,
          'amountCents': 4567,
        }),
        45.67,
      );
    });

    test('supports amountMinorUnits as a compatibility fallback', () {
      expect(
        WebAdminDonationAmount.read(const <String, dynamic>{
          'amountMinorUnits': '2500',
        }),
        25,
      );
    });

    test('returns null when no supported amount is stored', () {
      expect(WebAdminDonationAmount.read(const <String, dynamic>{}), isNull);
    });
  });
}
