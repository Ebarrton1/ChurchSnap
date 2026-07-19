import 'package:churchsnap/features/web_admin/widgets/web_admin_responsive_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final destinations = <Widget>[
    const NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Overview',
    ),
    const NavigationDestination(
      icon: Icon(Icons.people_outline),
      selectedIcon: Icon(Icons.people_rounded),
      label: 'Members',
    ),
    const NavigationDestination(
      icon: Icon(Icons.event_outlined),
      selectedIcon: Icon(Icons.event_rounded),
      label: 'Events',
    ),
    const NavigationDestination(
      icon: Icon(Icons.volunteer_activism_outlined),
      selectedIcon: Icon(Icons.volunteer_activism_rounded),
      label: 'Prayer',
    ),
    const NavigationDestination(
      icon: Icon(Icons.payments_outlined),
      selectedIcon: Icon(Icons.payments_rounded),
      label: 'Giving',
    ),
    const NavigationDestination(
      icon: Icon(Icons.task_alt_outlined),
      selectedIcon: Icon(Icons.task_alt_rounded),
      label: 'Action Center',
    ),
    const NavigationDestination(
      icon: Icon(Icons.analytics_outlined),
      selectedIcon: Icon(Icons.analytics_rounded),
      label: 'Reports',
    ),
  ];

  testWidgets('uses compact navigation below the breakpoint', (tester) async {
    tester.view
      ..physicalSize = const Size(480, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const SizedBox.expand(),
          bottomNavigationBar: WebAdminResponsiveNavigation(
            selectedIndex: 6,
            onDestinationSelected: (_) {},
            destinations: destinations,
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('compact-dashboard-navigation')),
      findsOneWidget,
    );
    expect(find.text('Reports'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the standard navigation at wider widths', (tester) async {
    tester.view
      ..physicalSize = const Size(900, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const SizedBox.expand(),
          bottomNavigationBar: WebAdminResponsiveNavigation(
            selectedIndex: 6,
            onDestinationSelected: (_) {},
            destinations: destinations,
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('standard-dashboard-navigation')),
      findsOneWidget,
    );
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
