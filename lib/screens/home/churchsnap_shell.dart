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

  List<Widget> get pages => [
    const HomeScreen(),
    const SermonsScreen(),
    const MediaScreen(),
    EventsScreen(authController: widget.authController),
    const PrayerScreen(),
    const GivingScreen(),
    ProfileScreen(authController: widget.authController),
    const AdminDashboardScreen(),
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
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
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
