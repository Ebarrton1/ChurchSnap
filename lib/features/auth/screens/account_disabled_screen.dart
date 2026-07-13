import 'package:flutter/material.dart';

import '../state/auth_controller.dart';

class AccountDisabledScreen extends StatelessWidget {
  const AccountDisabledScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    final user = authController.currentUser;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            const SizedBox(height: 56),
            Center(
              child: Container(
                width: 94,
                height: 94,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.no_accounts_rounded,
                  size: 48,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Account access paused',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Text(
              user?.email ?? '',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            const Text(
              'This ChurchSnap member account is currently inactive. '
              'Contact a church administrator if you believe this was a '
              'mistake.',
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.5),
            ),
            if (authController.errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                authController.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: authController.status == AuthStatus.loading
                  ? null
                  : authController.signOut,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Return to sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
