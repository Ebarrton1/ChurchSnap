import 'package:flutter/material.dart';

import '../events/events_screen.dart';
import '../giving/giving_screen.dart';
import '../home/home_screen.dart';
import '../prayer/prayer_screen.dart';
import '../profile/profile_screen.dart';
import '../sermons/sermons_screen.dart';
import '../../features/auth/state/auth_controller.dart';
import '../admin/admin_dashboard_screen.dart';
import '../media/media_screen.dart';

class ChurchSnapShell extends StatefulWidget {
  final AuthController authController;

  const ChurchSnapShell({super.key, required this.authController});

  @override
  State<ChurchSnapShell> createState() => _ChurchSnapShellState();
}

class _ChurchSnapShellState extends State<ChurchSnapShell> {
  int selectedIndex = 0;

  String get _churchId {
    final churchId = widget.authController.currentUser?.churchId.trim() ?? '';

    return churchId.isEmpty ? 'demo-church' : churchId;
  }

  List<Widget> get pages => [
    HomeScreen(authController: widget.authController),
    SermonsScreen(churchId: _churchId),
    const MediaScreen(),
    EventsScreen(authController: widget.authController),
    PrayerScreen(churchId: _churchId),
    const GivingScreen(),
    ProfileScreen(authController: widget.authController),

    if (widget.authController.isAdmin)
      AdminDashboardScreen(churchId: _churchId),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => setState(() => selectedIndex = index),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.play_circle_outline_rounded),
            selectedIcon: Icon(Icons.play_circle_fill_rounded),
            label: 'Sermons',
          ),

          const NavigationDestination(
            icon: Icon(Icons.video_library_outlined),
            selectedIcon: Icon(Icons.video_library_rounded),
            label: 'Media',
          ),
          const NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event_rounded),
            label: 'Events',
          ),
          const NavigationDestination(
            icon: _PrayerNavigationIcon(selected: false),
            selectedIcon: _PrayerNavigationIcon(selected: true),
            label: 'Prayer',
          ),
          const NavigationDestination(
            icon: Icon(Icons.volunteer_activism_outlined),
            selectedIcon: Icon(Icons.volunteer_activism_rounded),
            label: 'Giving',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
          if (widget.authController.isAdmin)
            const NavigationDestination(
              icon: Icon(Icons.admin_panel_settings_outlined),
              selectedIcon: Icon(Icons.admin_panel_settings_rounded),
              label: 'Admin',
            ),
        ],
      ),
    );
  }
}

class _PrayerNavigationIcon extends StatelessWidget {
  final bool selected;

  const _PrayerNavigationIcon({required this.selected});

  @override
  Widget build(BuildContext context) {
    final iconSize = selected ? 31.0 : 29.0;

    return SizedBox(
      width: 34,
      height: 34,
      child: ClipRect(
        child: Transform.scale(
          scale: 1.6,
          child: Image.asset(
            'assets/icons/prayer_hands.png',
            width: iconSize,
            height: iconSize,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Prayer icon failed to load: $error');

              return Icon(
                selected
                    ? Icons.volunteer_activism_rounded
                    : Icons.volunteer_activism_outlined,
                size: iconSize,
              );
            },
          ),
        ),
      ),
    );
  }
}
