import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../screens/home/churchsnap_shell.dart';
import '../../notifications/repositories/notification_repository.dart';
import '../../notifications/services/notification_service.dart';
import '../models/churchsnap_user.dart';
import '../state/auth_controller.dart';
import 'account_disabled_screen.dart';
import 'email_verification_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthController authController;
  String? _notificationUserId;

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
          _notificationUserId = null;
          return LoginScreen(authController: authController);
        }

        final user = authController.currentUser!;

        if (!user.isActive) {
          _notificationUserId = null;
          return AccountDisabledScreen(authController: authController);
        }

        if (!user.isEmailVerified) {
          _notificationUserId = null;
          return EmailVerificationScreen(authController: authController);
        }

        _scheduleNotificationInitialization(user);
        return ChurchSnapShell(authController: authController);
      },
    );
  }

  void _scheduleNotificationInitialization(ChurchSnapUser user) {
    if (_notificationUserId == user.id) {
      return;
    }

    _notificationUserId = user.id;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await NotificationService(
          NotificationRepository(
            FirebaseFirestore.instance,
            churchId: user.churchId,
          ),
        ).initializeMessaging(userId: user.id, churchId: user.churchId);
      } catch (error) {
        debugPrint('Notification initialization failed: $error');
      }
    });
  }
}
