import 'package:flutter/material.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/auth/state/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  final AuthController authController;

  const ProfileScreen({super.key, required this.authController});

  @override
  Widget build(BuildContext context) {
    final user = authController.currentUser;

    return ChurchSnapScreen(
      title: 'Profile',
      subtitle: 'Your ChurchSnap member hub.',
      children: [
        AppCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(
              radius: 28,
              child: Icon(Icons.person_rounded),
            ),
            title: Text(user?.displayName ?? 'ChurchSnap Member'),
            subtitle: Text(
              '${user?.role ?? 'member'} • ${user?.churchId ?? 'demo-church'}',
            ),
          ),
        ),
        const SectionTitle(title: 'Account'),
        AppCard(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.email_rounded),
                title: Text(user?.email ?? 'No email'),
              ),
              ListTile(
                leading: const Icon(Icons.verified_user_rounded),
                title: const Text('Role'),
                trailing: Text(user?.role ?? 'member'),
              ),
              ListTile(
                leading: const Icon(Icons.admin_panel_settings_rounded),
                title: const Text('Admin access'),
                trailing: Text(authController.isAdmin ? 'Enabled' : 'No'),
              ),
            ],
          ),
        ),
        const SectionTitle(title: 'Activity'),
        const AppCard(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.bookmark_rounded),
                title: Text('Saved sermons'),
                trailing: Text('3'),
              ),
              ListTile(
                leading: Icon(Icons.event_available_rounded),
                title: Text('Upcoming RSVPs'),
                trailing: Text('2'),
              ),
              ListTile(
                leading: Icon(Icons.volunteer_activism_rounded),
                title: Text('Volunteer interests'),
                trailing: Text('4'),
              ),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: authController.signOut,
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Sign Out'),
        ),
      ],
    );
  }
}
