import 'package:flutter/material.dart';

import '../../../core/widgets/churchsnap_screen.dart';
import '../state/auth_controller.dart';

class GuestAccountScreen extends StatelessWidget {
  const GuestAccountScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ChurchSnapScreen(
        title: 'Guest Access',
        subtitle: 'Browse ChurchSnap without a member account.',
        children: [
          const AppCard(
            child: ListTile(
              leading: CircleAvatar(child: Icon(Icons.explore_rounded)),
              title: Text(
                'You are browsing as a guest',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(
                'Published sermons, media, announcements, events, and giving '
                'funds remain available.',
              ),
            ),
          ),
          const SectionTitle(title: 'Member features'),
          const AppCard(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.event_available_rounded),
                  title: Text('RSVP and event check-in'),
                  subtitle: Text('Requires a verified member account.'),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.volunteer_activism_rounded),
                  title: Text('Prayer requests and volunteer tools'),
                  subtitle: Text('Requires a verified member account.'),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.person_rounded),
                  title: Text('Profile, history, and administration'),
                  subtitle: Text(
                    'Private account access is never available to guests.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () async {
              await authController.signOut();
            },
            icon: const Icon(Icons.login_rounded),
            label: const Text('Sign in or create an account'),
          ),
        ],
      ),
    );
  }
}
