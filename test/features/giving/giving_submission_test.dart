import 'package:churchsnap/features/giving/models/giving_currency.dart';
import 'package:churchsnap/features/giving/models/giving_submission.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GivingSubmission', () {
    test('keeps submitted and confirmed currencies separate', () {
      const submission = GivingSubmission(
        id: 'gift-1',
        giverId: 'member-1',
        giverName: 'Member One',
        fundId: 'tithe',
        fundName: 'Tithe',
        amountMinorUnits: 10000,
        currencyCode: 'USD',
        currencySymbol: r'$',
        recurring: false,
        status: GivingSubmissionStatus.confirmed,
        confirmedAmountMinorUnits: 1570000,
        confirmedCurrencyCode: 'JMD',
        confirmedCurrencySymbol: r'J$',
      );

      expect(submission.submittedAmountLabel, r'$100.00');
      expect(submission.confirmedAmountLabel, r'J$15,700.00');
    });

    test('does not perform exchange-rate conversion', () {
      const submission = GivingSubmission(
        id: 'gift-2',
        giverId: 'member-2',
        giverName: 'Member Two',
        fundId: 'missions',
        fundName: 'Missions',
        amountMinorUnits: 500000,
        currencyCode: 'JMD',
        currencySymbol: r'J$',
        recurring: false,
        status: GivingSubmissionStatus.pending,
      );

      expect(submission.submittedAmountLabel, r'J$5,000.00');
      expect(submission.confirmedAmountLabel, isNull);
      expect(submission.submittedCurrency, GivingCurrency.byCode('JMD'));
    });
  });
}
