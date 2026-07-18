import 'package:churchsnap/core/navigation/churchsnap_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'closeAllWindows dismisses stacked dialogs and keeps the page open',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (pageContext) {
                return Center(
                  child: FilledButton(
                    onPressed: () {
                      showDialog<void>(
                        context: pageContext,
                        builder: (firstDialogContext) {
                          return AlertDialog(
                            title: const Text('First window'),
                            actions: [
                              FilledButton(
                                onPressed: () {
                                  showDialog<void>(
                                    context: firstDialogContext,
                                    builder: (secondDialogContext) {
                                      return AlertDialog(
                                        title: const Text('Second window'),
                                        actions: [
                                          FilledButton(
                                            onPressed: () {
                                              ChurchSnapNavigation.closeAllWindows(
                                                secondDialogContext,
                                              );
                                            },
                                            child: const Text('Save'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: const Text('Open another window'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text('Open windows'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open windows'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open another window'));
      await tester.pumpAndSettle();

      expect(find.text('First window'), findsOneWidget);
      expect(find.text('Second window'), findsOneWidget);

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('First window'), findsNothing);
      expect(find.text('Second window'), findsNothing);
      expect(find.text('Open windows'), findsOneWidget);
    },
  );
}
