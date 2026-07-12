import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> updateNotification({
    required String id,
    required String title,
    required String body,
    required String type,
    required String targetRole,
  }) {
    return _repository.updateNotification(
      id: id,
      title: title,
      body: body,
      type: type,
      targetRole: targetRole,
    );
  }

  Future<void> deleteNotification(String id) {
    return _repository.deleteNotification(id);
  }

  Future<void> initializeMessaging({
    required String userId,
    String churchId = 'demo-church',
  }) async {
    final normalizedChurchId = churchId.trim().isEmpty
        ? 'demo-church'
        : churchId.trim();

    await _messaging.requestPermission();

    final token = await _messaging.getToken();

    if (token != null && userId.trim().isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('churches')
          .doc(normalizedChurchId)
          .collection('members')
          .doc(userId.trim())
          .set({
            'fcmToken': token,
            'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    }

    FirebaseMessaging.onMessage.listen((message) {
      // Future: show an in-app notification.
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // Future: navigate based on notification type.
    });
  }
}
