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
import 'required_name_gate.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthController authController;

  String? _notificationUserId;
  NotificationService? _notificationService;

  @override
  void initState() {
    super.initState();
    authController = AuthController();
  }

  @override
  void dispose() {
    _notificationService?.dispose();
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
          _clearNotificationService();
          return LoginScreen(authController: authController);
        }

        final user = authController.currentUser!;

        if (!user.isGuest && !user.isActive) {
          _clearNotificationService();
          return AccountDisabledScreen(authController: authController);
        }

        if (!user.isGuest && !user.isEmailVerified) {
          _clearNotificationService();
          return EmailVerificationScreen(authController: authController);
        }

        if (user.isGuest) {
          _clearNotificationService();
        } else {
          _scheduleNotificationInitialization(user);
        }

        return RequiredNameGate(
          churchId: user.churchId,
          userId: user.id,
          existingDisplayName: user.displayName,
          authController: authController,
          child: ChurchSnapShell(authController: authController),
        );
      },
    );
  }

  void _scheduleNotificationInitialization(ChurchSnapUser user) {
    if (user.role == 'visitor') {
      _notificationUserId = null;
      return;
    }

    if (_notificationUserId == user.id) {
      return;
    }

    _clearNotificationService();

    final service = NotificationService(
      NotificationRepository(
        FirebaseFirestore.instance,
        churchId: user.churchId,
      ),
    );

    _notificationUserId = user.id;
    _notificationService = service;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || authController.currentUser?.id != user.id) {
        return;
      }

      try {
        await service.initializeMessaging(
          userId: user.id,
          churchId: user.churchId,
        );
      } catch (error) {
        debugPrint('Notification initialization failed: $error');
      }
    });
  }

  void _clearNotificationService() {
    _notificationService?.dispose();
    _notificationService = null;
    _notificationUserId = null;
  }
}
