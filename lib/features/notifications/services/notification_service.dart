import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    await _messaging.requestPermission();

    final token = await _messaging.getToken();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (token != null) {
      developer.log(
        'FCM token received: $token',
        name: 'ChurchSnap.Notifications',
      );
    }

    if (userId != null) {
      developer.log(
        'Signed-in user ready for FCM token save: $userId',
        name: 'ChurchSnap.Notifications',
      );
    }

    FirebaseMessaging.onMessage.listen((message) {
      developer.log(
        'Foreground notification: ${message.notification?.title}',
        name: 'ChurchSnap.Notifications',
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      developer.log('Notification tapped', name: 'ChurchSnap.Notifications');
    });
  }
}
