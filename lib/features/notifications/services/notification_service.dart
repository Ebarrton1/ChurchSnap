import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/app_notification.dart';
import '../repositories/notification_repository.dart';

class NotificationService {
  NotificationService(this._repository);

  final NotificationRepository _repository;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Stream<List<AppNotification>> watchNotifications() {
    return _repository.watchNotifications();
  }

  Future<void> sendNotification(AppNotification notification) {
    return _repository.addNotification(notification);
  }

  Future<void> deleteNotification(String id) {
    return _repository.deleteNotification(id);
  }

  Future<void> initializeMessaging() async {
    await _messaging.requestPermission();

    final token = await _messaging.getToken();

    if (token != null) {
      // TODO: Save token to current member profile.
    }

    FirebaseMessaging.onMessage.listen((message) {
      // TODO: Show in-app notification.
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // TODO: Navigate based on notification type.
    });
  }
}
