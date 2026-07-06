import 'package:flutter/material.dart';

import '../../../screens/home/churchsnap_shell.dart';
import '../state/auth_controller.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthController authController;

  @override
  void initState() {
    super.initState();
    authController = AuthController();
  }

  @override
  void dispose() {
    authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: authController,
      builder: (context, _) {
        if (authController.status == AuthStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!authController.isSignedIn) {
          return LoginScreen(authController: authController);
        }

        return ChurchSnapShell(authController: authController);
      },
    );
  }
}
