import 'package:flutter/material.dart';

import '../../../core/widgets/churchsnap_screen.dart';
import '../state/auth_controller.dart';

class GuestRestrictedScreen extends StatelessWidget {
  const GuestRestrictedScreen({
    super.key,
    required this.authController,
    required this.title,
    required this.message,
    required this.icon,
  });

  final AuthController authController;
  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ChurchSnapScreen(
        title: title,
        subtitle: 'Member account required',
        children: [
          AppCard(
            child: ListTile(
              leading: CircleAvatar(child: Icon(icon)),
              title: Text(
                '$title is protected',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(message),
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
