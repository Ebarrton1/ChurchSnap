import 'package:churchsnap/screens/admin/admin_launch_readiness_screen.dart';
import 'package:churchsnap/screens/settings/help_legal_account_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _scrollToText(WidgetTester tester, String text) async {
  final finder = find.text(text);

  await tester.scrollUntilVisible(
    finder,
    300,
    scrollable: find.byType(Scrollable).first,
  );

  await tester.pumpAndSettle();

  expect(finder, findsOneWidget);
}

void main() {
  testWidgets('help center shows launch-readiness categories', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HelpLegalAccountScreen()));

    expect(find.text('Help, Legal & Account'), findsWidgets);
    expect(find.text('Getting Started'), findsOneWidget);

    await _scrollToText(tester, 'Privacy Policy');
    await _scrollToText(tester, 'Terms of Use');
    await _scrollToText(tester, 'Help and Support');
    await _scrollToText(tester, 'Account & Data Requests');
    await _scrollToText(tester, 'About ChurchSnap');
  });

  testWidgets('privacy policy opens from help center', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HelpLegalAccountScreen()));

    await _scrollToText(tester, 'Privacy Policy');

    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();

    expect(find.text('Information ChurchSnap may handle'), findsOneWidget);

    await _scrollToText(tester, 'Final release review');
  });

  testWidgets('admin launch readiness shows required release work', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: AdminLaunchReadinessScreen()),
    );

    expect(find.text('ChurchSnap Release Checklist'), findsOneWidget);

    await _scrollToText(tester, 'Privacy Policy and Terms');
    await _scrollToText(tester, 'Verified Account Deletion');
    await _scrollToText(tester, 'Published Support Contact');
    await _scrollToText(tester, 'Backup and Recovery');
  });
}
