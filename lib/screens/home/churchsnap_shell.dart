import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../features/auth/state/auth_controller.dart';
import '../admin/admin_dashboard_screen.dart';
import '../events/events_screen.dart';
import '../giving/giving_screen.dart';
import '../media/media_screen.dart';
import '../prayer/prayer_screen.dart';
import '../profile/profile_screen.dart';
import '../sermons/sermons_screen.dart';
import 'home_screen.dart';

const Color _shellNavy = Color(0xFF031A2E);
const Color _shellAccent = Color(0xFF35B8FF);

class ChurchSnapShell extends StatefulWidget {
  const ChurchSnapShell({super.key, required this.authController});

  final AuthController authController;

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
    HomeScreen(authController: widget.authController, onSelectTab: _selectTab),
    SermonsScreen(churchId: _churchId),
    MediaScreen(churchId: _churchId),
    EventsScreen(authController: widget.authController),
    PrayerScreen(churchId: _churchId),
    const GivingScreen(),
    ProfileScreen(authController: widget.authController),
    if (widget.authController.isAdmin)
      AdminDashboardScreen(churchId: _churchId),
  ];

  List<_ShellDestination> get destinations => [
    const _ShellDestination(
      label: 'Home',
      assetName: 'home_camera',
      fallbackIcon: Icons.home_rounded,
    ),
    const _ShellDestination(
      label: 'Sermons',
      assetName: 'sermons',
      fallbackIcon: Icons.play_circle_fill_rounded,
    ),
    const _ShellDestination(
      label: 'Media',
      assetName: 'live_stream',
      fallbackIcon: Icons.video_library_rounded,
    ),
    const _ShellDestination(
      label: 'Events',
      assetName: 'events',
      fallbackIcon: Icons.event_rounded,
    ),
    const _ShellDestination(
      label: 'Prayer',
      assetName: 'prayer_hands',
      fallbackIcon: Icons.volunteer_activism_rounded,
    ),
    const _ShellDestination(
      label: 'Giving',
      assetName: 'giving',
      fallbackIcon: Icons.favorite_rounded,
    ),
    const _ShellDestination(
      label: 'Profile',
      assetName: 'profile',
      fallbackIcon: Icons.person_rounded,
    ),
    if (widget.authController.isAdmin)
      const _ShellDestination(
        label: 'Admin',
        assetName: 'admin',
        fallbackIcon: Icons.admin_panel_settings_rounded,
      ),
  ];

  void _selectTab(int index) {
    final maximumIndex = pages.length - 1;

    if (index < 0 || index > maximumIndex) {
      return;
    }

    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activePages = pages;
    final activeDestinations = destinations;

    if (selectedIndex >= activePages.length) {
      selectedIndex = 0;
    }

    return Scaffold(
      backgroundColor: selectedIndex == 0 ? _shellNavy : AppTheme.background,
      body: IndexedStack(index: selectedIndex, children: activePages),
      bottomNavigationBar: _ChurchSnapBottomBar(
        selectedIndex: selectedIndex,
        destinations: activeDestinations,
        onSelected: _selectTab,
      ),
    );
  }
}

class _ShellDestination {
  const _ShellDestination({
    required this.label,
    required this.assetName,
    required this.fallbackIcon,
  });

  final String label;
  final String assetName;
  final IconData fallbackIcon;
}

class _ChurchSnapBottomBar extends StatelessWidget {
  const _ChurchSnapBottomBar({
    required this.selectedIndex,
    required this.destinations,
    required this.onSelected,
  });

  final int selectedIndex;
  final List<_ShellDestination> destinations;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _shellNavy,
      elevation: 22,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: _shellNavy,
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(1, 4, 1, 3),
          child: Row(
            children: List.generate(destinations.length, (index) {
              return Expanded(
                child: _BottomDestination(
                  destination: destinations[index],
                  selected: selectedIndex == index,
                  onTap: () => onSelected(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _BottomDestination extends StatelessWidget {
  const _BottomDestination({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _ShellDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      label: destination.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 46,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    color: selected
                        ? _shellAccent.withValues(alpha: 0.10)
                        : Colors.transparent,
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: _shellAccent.withValues(alpha: 0.55),
                              blurRadius: 15,
                              spreadRadius: 1,
                            ),
                          ]
                        : const [],
                  ),
                  child: Image.asset(
                    'assets/icons/'
                    '${destination.assetName}.png',
                    width: selected ? 45 : 41,
                    height: selected ? 45 : 41,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (_, _, _) {
                      return Icon(
                        destination.fallbackIcon,
                        color: selected ? _shellAccent : Colors.white,
                        size: selected ? 35 : 32,
                      );
                    },
                  ),
                ),
                Text(
                  destination.label,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    color: selected ? _shellAccent : Colors.white,
                    fontSize: 8.5,
                    height: 1,
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
