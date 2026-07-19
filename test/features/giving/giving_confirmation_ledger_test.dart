import 'package:churchsnap/features/giving/models/giving_currency.dart';
import 'package:churchsnap/features/giving/models/giving_submission.dart';
import 'package:churchsnap/features/giving/services/giving_confirmation_ledger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const submission = GivingSubmission(
    id: 'submission-123',
    giverId: 'member-42',
    giverName: 'Ada Member',
    fundId: 'missions',
    fundName: 'Missions',
    amountMinorUnits: 2500,
    currencyCode: 'USD',
    currencySymbol: r'$',
    recurring: true,
    status: GivingSubmissionStatus.pending,
  );

  test('uses the submission ID as the deterministic donation ID', () {
    expect(
      GivingConfirmationLedger.donationDocumentId(' submission-123 '),
      'submission-123',
    );
  });

  test('builds the canonical donation ledger fields', () {
    final fields = GivingConfirmationLedger.donationFields(
      submission: submission,
      confirmedAmountMinorUnits: 2600,
      confirmedCurrency: GivingCurrency.usd,
      confirmedByUid: 'admin-7',
      adminNote: ' Bank receipt checked. ',
    );

    expect(fields, <String, dynamic>{
      'memberId': 'member-42',
      'memberName': 'Ada Member',
      'fundId': 'missions',
      'fundName': 'Missions',
      'amountCents': 2600,
      'currency': 'USD',
      'status': 'completed',
      'recurring': true,
      'reference': 'giving-submission:submission-123',
      'sourceSubmissionId': 'submission-123',
      'confirmedByUid': 'admin-7',
      'adminNote': 'Bank receipt checked.',
    });
  });

  test('recognizes an exact retry of a confirmed submission', () {
    const confirmed = GivingSubmission(
      id: 'submission-123',
      giverId: 'member-42',
      giverName: 'Ada Member',
      fundId: 'missions',
      fundName: 'Missions',
      amountMinorUnits: 2500,
      currencyCode: 'USD',
      currencySymbol: r'$',
      recurring: true,
      status: GivingSubmissionStatus.confirmed,
      confirmedAmountMinorUnits: 2600,
      confirmedCurrencyCode: 'USD',
      confirmedCurrencySymbol: r'$',
      adminNote: 'Bank receipt checked.',
    );

    expect(
      GivingConfirmationLedger.matchesConfirmedSubmission(
        submission: confirmed,
        confirmedAmountMinorUnits: 2600,
        confirmedCurrency: GivingCurrency.usd,
        adminNote: ' Bank receipt checked. ',
      ),
      isTrue,
    );
  });

  test('rejects an empty submission ID', () {
    expect(
      () => GivingConfirmationLedger.donationDocumentId('  '),
      throwsArgumentError,
    );
  });
}
