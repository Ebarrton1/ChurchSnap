import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../features/auth/screens/guest_account_screen.dart';
import '../../features/auth/screens/guest_restricted_screen.dart';
import '../../features/auth/state/auth_controller.dart';
import '../admin/admin_dashboard_screen.dart';
import '../events/events_screen.dart';
import '../giving/giving_screen.dart';
import '../media/media_screen.dart';
import '../prayer/prayer_screen.dart';
import '../profile/profile_screen.dart';
import '../resources/resources_screen.dart';
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
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  int selectedIndex = 0;

  String get _lastTabPreferenceKey {
    final userId = widget.authController.currentUser?.id.trim() ?? '';
    final preferenceOwner = userId.isEmpty ? 'guest' : userId;

    return 'churchsnap_last_main_tab_$preferenceOwner';
  }

  @override
  void initState() {
    super.initState();
    unawaited(_restoreSelectedTab());
  }

  Future<void> _restoreSelectedTab() async {
    final savedIndex = await _preferences.getInt(_lastTabPreferenceKey) ?? 0;

    if (!mounted) {
      return;
    }

    final maximumIndex = pages.length - 1;
    final restoredIndex = savedIndex >= 0 && savedIndex <= maximumIndex
        ? savedIndex
        : 0;

    if (restoredIndex == selectedIndex) {
      return;
    }

    setState(() {
      selectedIndex = restoredIndex;
    });
  }

  Future<void> _saveSelectedTab(int index) {
    return _preferences.setInt(_lastTabPreferenceKey, index);
  }

  String get _churchId {
    final churchId = widget.authController.currentUser?.churchId.trim() ?? '';

    return churchId.isEmpty ? 'demo-church' : churchId;
  }

  bool get _isGuest => widget.authController.isGuest;

  List<Widget> get pages => [
    HomeScreen(authController: widget.authController, onSelectTab: _selectTab),
    SermonsScreen(churchId: _churchId),
    MediaScreen(churchId: _churchId),
    EventsScreen(authController: widget.authController),
    if (_isGuest)
      GuestRestrictedScreen(
        authController: widget.authController,
        title: 'Prayer',
        message:
            'Sign in with a verified account to submit or manage prayer requests.',
        icon: Icons.volunteer_activism_rounded,
      )
    else
      PrayerScreen(
        churchId: _churchId,
        canSubmitRequests: widget.authController.canAccessMemberPrivate,
      ),
    GivingScreen(authController: widget.authController),
    if (_isGuest)
      GuestAccountScreen(authController: widget.authController)
    else
      ProfileScreen(authController: widget.authController),
    ResourcesScreen(churchId: _churchId),
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
    _ShellDestination(
      label: _isGuest ? 'Account' : 'Profile',
      assetName: 'profile',
      fallbackIcon: _isGuest ? Icons.login_rounded : Icons.person_rounded,
    ),
    const _ShellDestination(
      label: 'Resources',
      assetName: 'bible',
      fallbackIcon: Icons.menu_book_rounded,
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

    if (index < 0 || index > maximumIndex || index == selectedIndex) {
      return;
    }

    setState(() {
      selectedIndex = index;
    });

    unawaited(_saveSelectedTab(index));
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
    final prominent = destination.label == 'Resources';
    final emphasized = selected || prominent;
    final foregroundColor = emphasized ? _shellAccent : Colors.white;
    final iconContainerWidth = prominent ? 54.0 : 46.0;
    final iconContainerHeight = prominent ? 56.0 : 48.0;
    final iconSize = selected
        ? (prominent ? 51.0 : 45.0)
        : (prominent ? 48.0 : 41.0);
    final fallbackIconSize = selected
        ? (prominent ? 41.0 : 35.0)
        : (prominent ? 38.0 : 32.0);

    return Semantics(
      selected: selected,
      button: true,
      label: destination.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(prominent ? 15 : 12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: iconContainerWidth,
                  height: iconContainerHeight,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(prominent ? 16 : 13),
                    color: selected
                        ? _shellAccent.withValues(alpha: 0.28)
                        : prominent
                        ? _shellAccent.withValues(alpha: 0.16)
                        : Colors.transparent,
                    border: prominent
                        ? Border.all(
                            color: Colors.white.withValues(
                              alpha: selected ? 1.0 : 0.88,
                            ),
                            width: selected ? 2.0 : 1.6,
                          )
                        : null,
                    boxShadow: const <BoxShadow>[],
                  ),
                  child: Image.asset(
                    'assets/icons/'
                    '${destination.assetName}.png',
                    width: iconSize,
                    height: iconSize,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (_, _, _) {
                      return Icon(
                        destination.fallbackIcon,
                        color: foregroundColor,
                        size: fallbackIconSize,
                      );
                    },
                  ),
                ),
                Text(
                  destination.label,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: prominent ? 9.75 : 8.5,
                    height: 1,
                    fontWeight: emphasized ? FontWeight.w900 : FontWeight.w600,
                    letterSpacing: prominent ? 0.10 : 0,
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
