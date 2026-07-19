import 'package:flutter/material.dart';

import '../features/auth/state/auth_controller.dart';
import '../screens/home/churchsnap_shell.dart';

class ChurchSnapPlatformShell extends StatelessWidget {
  const ChurchSnapPlatformShell({super.key, required this.authController});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return ChurchSnapShell(authController: authController);
  }
}
