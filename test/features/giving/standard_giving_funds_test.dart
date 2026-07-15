import 'package:churchsnap/features/giving/models/giving_fund.dart';
import 'package:churchsnap/features/giving/models/standard_giving_funds.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StandardGivingFunds', () {
    test('keeps tithe, offering, and donation separate', () {
      expect(StandardGivingFunds.tithe.id, 'tithe');
      expect(StandardGivingFunds.tithe.name, 'Tithe');

      expect(StandardGivingFunds.offering.id, 'offering');
      expect(StandardGivingFunds.offering.name, 'Offering');

      expect(StandardGivingFunds.donation.id, 'donation');
      expect(StandardGivingFunds.donation.name, 'Donation');
    });

    test('replaces a legacy combined fund with separate standard funds', () {
      const legacyFunds = <GivingFund>[
        GivingFund(
          id: 'tithe-offering',
          name: 'Tithe & Offering',
          description: 'Legacy combined fund.',
          sortOrder: 10,
        ),
        GivingFund(
          id: 'missions',
          name: 'Missions',
          description: 'Mission support.',
          sortOrder: 20,
        ),
      ];

      final result = StandardGivingFunds.separateLegacyFund(legacyFunds);

      expect(result.any((fund) => fund.name == 'Tithe & Offering'), isFalse);
      expect(result.where((fund) => fund.id == 'tithe'), hasLength(1));
      expect(result.where((fund) => fund.id == 'offering'), hasLength(1));
      expect(result.where((fund) => fund.id == 'donation'), hasLength(1));
      expect(result.where((fund) => fund.id == 'missions'), hasLength(1));
    });

    test('does not duplicate existing standard funds', () {
      const existingFunds = <GivingFund>[
        GivingFund(
          id: 'custom-tithe',
          name: 'Tithe',
          description: 'Existing tithe.',
          sortOrder: 5,
        ),
        GivingFund(
          id: 'custom-offering',
          name: 'Offering',
          description: 'Existing offering.',
          sortOrder: 6,
        ),
        GivingFund(
          id: 'custom-donation',
          name: 'Donation',
          description: 'Existing donation.',
          sortOrder: 7,
        ),
      ];

      final result = StandardGivingFunds.separateLegacyFund(existingFunds);

      expect(result.where((fund) => fund.name == 'Tithe'), hasLength(1));
      expect(result.where((fund) => fund.name == 'Offering'), hasLength(1));
      expect(result.where((fund) => fund.name == 'Donation'), hasLength(1));
    });
  });
}
