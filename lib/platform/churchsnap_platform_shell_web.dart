import 'package:flutter/material.dart';

import '../features/auth/state/auth_controller.dart';
import '../features/web_admin/screens/churchsnap_web_admin_shell.dart';

class ChurchSnapPlatformShell extends StatelessWidget {
  const ChurchSnapPlatformShell({super.key, required this.authController});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return ChurchSnapWebAdminShell(authController: authController);
  }
}
