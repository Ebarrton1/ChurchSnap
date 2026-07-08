import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    await _messaging.requestPermission();

    final token = await _messaging.getToken();

    if (token != null) {
      // TODO:
      // Save token to:
      // churches/demo-church/members/{uid}/fcmToken
      print('FCM Token: $token');
    }

    FirebaseMessaging.onMessage.listen((message) {
      print('Foreground notification: ${message.notification?.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Notification tapped');
    });
  }
}
