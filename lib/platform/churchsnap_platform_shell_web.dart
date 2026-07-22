import 'package:flutter/material.dart';

import '../features/auth/state/auth_controller.dart';
import '../features/web_admin/screens/churchsnap_web_admin_shell.dart';
import '../screens/home/churchsnap_shell.dart';

class ChurchSnapPlatformShell extends StatelessWidget {
  const ChurchSnapPlatformShell({super.key, required this.authController});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ChurchSnapShell(authController: authController),
        if (authController.isAdmin)
          Positioned(
            right: 24,
            bottom: 96,
            child: SafeArea(
              top: false,
              left: false,
              child: FloatingActionButton.extended(
                heroTag: 'openChurchSnapWindowsDashboard',
                tooltip: 'Open Windows Dashboard',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          _WebAdminRoute(authController: authController),
                    ),
                  );
                },
                icon: const Icon(Icons.desktop_windows_rounded),
                label: const Text('Windows Dashboard'),
              ),
            ),
          ),
      ],
    );
  }
}

class _WebAdminRoute extends StatelessWidget {
  const _WebAdminRoute({required this.authController});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return ChurchSnapWebAdminShell(
      authController: authController,
      onReturnHome: () => Navigator.of(context).pop(),
    );
  }
}
