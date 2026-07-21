import 'dart:io';

import 'package:churchsnap/features/giving/models/donation_record.dart';
import 'package:churchsnap/features/giving/models/giving_submission.dart';
import 'package:churchsnap/features/giving/models/giving_currency.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('legacy donations remain valid without a description', () {
    final donation =
        DonationRecord.fromMap('legacy-donation', const <String, dynamic>{
          'memberId': 'member-1',
          'memberName': 'Legacy Member',
          'fundId': 'general',
          'fundName': 'General Giving',
          'amountCents': 2500,
        });

    expect(donation.description, isEmpty);
  });

  test('donation descriptions are trimmed and serialized', () {
    final donation =
        DonationRecord.fromMap('described-donation', const <String, dynamic>{
          'memberId': 'member-2',
          'memberName': 'Described Member',
          'fundId': 'missions',
          'fundName': 'Missions',
          'amountCents': 4000,
          'description': '  In memory of a loved one.  ',
        });

    expect(donation.description, 'In memory of a loved one.');

    final saved = DonationRecord(
      memberId: 'member-2',
      memberName: 'Described Member',
      fundId: 'missions',
      fundName: 'Missions',
      amountCents: 4000,
      description: '  Youth outreach supplies.  ',
    ).toMap();

    expect(saved['description'], 'Youth outreach supplies.');
  });

  test('giving submissions default to an empty description', () {
    const submission = GivingSubmission(
      id: 'submission-1',
      giverId: 'member-1',
      giverName: 'Member One',
      fundId: 'general',
      fundName: 'General Giving',
      amountMinorUnits: 1000,
      currencyCode: 'USD',
      currencySymbol: r'$',
      recurring: false,
      status: GivingSubmissionStatus.pending,
    );

    expect(submission.description, isEmpty);
    expect(submission.submittedCurrency, GivingCurrency.usd);
  });

  test('Firestore rules allow and limit the optional description', () {
    final rules = File('firestore.rules').readAsStringSync();

    expect(rules, contains("'description',"));
    expect(
      rules,
      contains("request.resource.data.get('description', '') is string"),
    );
    expect(
      rules,
      contains("request.resource.data.get('description', '').size() <= 500"),
    );
  });

  test('member, admin, and web giving views display descriptions', () {
    final givingScreen = File(
      'lib/screens/giving/giving_screen.dart',
    ).readAsStringSync();
    final memberHistory = File(
      'lib/screens/profile/giving_history_screen.dart',
    ).readAsStringSync();
    final adminGiving = File(
      'lib/screens/admin/admin_giving_screen.dart',
    ).readAsStringSync();
    final webGiving = File(
      'lib/features/web_admin/screens/churchsnap_web_admin_shell.dart',
    ).readAsStringSync();

    expect(
      givingScreen,
      contains("labelText: 'Donation description (optional)'"),
    );
    expect(memberHistory, contains("'Description: \${record.description}'"));
    expect(adminGiving, contains("'Description: \${record.description}'"));
    expect(
      webGiving,
      contains('final description = WebAdminValueFormatter.text'),
    );
    expect(webGiving, contains("'description',"));
    expect(webGiving, contains("'donationDescription',"));
    expect(webGiving, contains("'memo',"));
  });
}
