import 'package:churchsnap/features/giving/models/giving_currency.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  GivingCurrency currency(String code) {
    return GivingCurrency.supported.firstWhere((item) => item.code == code);
  }

  group('GivingCurrency', () {
    test('formats all supported currency symbols correctly', () {
      const expected = <String, String>{
        'USD': r'$1,250.00',
        'JMD': r'J$1,250.00',
        'CAD': r'CA$1,250.00',
        'GBP': '\u00A31,250.00',
        'EUR': '\u20AC1,250.00',
        'TTD': r'TT$1,250.00',
        'BSD': r'B$1,250.00',
        'BBD': r'Bds$1,250.00',
        'XCD': r'EC$1,250.00',
        'GYD': r'G$1,250.00',
        'NGN': '\u20A61,250.00',
        'GHS': 'GH\u20B51,250.00',
        'ZAR': 'R1,250.00',
      };

      for (final entry in expected.entries) {
        expect(
          currency(entry.key).formatMajorUnits(1250),
          entry.value,
          reason: 'Incorrect formatting for ${entry.key}',
        );
      }
    });

    test('loads legacy single-currency settings', () {
      final settings = GivingCurrencySettings.fromMap({'currencyCode': 'JMD'});

      expect(settings.defaultCurrencyCode, 'JMD');
      expect(settings.enabledCurrencyCodes, ['JMD']);
    });

    test('normalizes default into enabled currencies', () {
      const settings = GivingCurrencySettings(
        defaultCurrencyCode: 'GBP',
        enabledCurrencyCodes: ['USD', 'EUR'],
      );

      final normalized = settings.normalized();

      expect(normalized.defaultCurrencyCode, 'USD');
      expect(normalized.enabledCurrencyCodes, ['USD', 'EUR']);
    });

    test('removes duplicate and unsupported enabled currencies', () {
      const settings = GivingCurrencySettings(
        defaultCurrencyCode: 'EUR',
        enabledCurrencyCodes: ['EUR', 'EUR', 'BAD', 'GBP'],
      );

      final normalized = settings.normalized();

      expect(normalized.defaultCurrencyCode, 'EUR');
      expect(normalized.enabledCurrencyCodes, ['EUR', 'USD', 'GBP']);
    });
  });
}
