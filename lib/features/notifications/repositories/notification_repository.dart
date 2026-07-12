import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_notification.dart';

class NotificationRepository {
  NotificationRepository(this._firestore, {String churchId = 'demo-church'})
    : churchId = churchId.trim().isEmpty ? 'demo-church' : churchId.trim();

  final FirebaseFirestore _firestore;
  final String churchId;

  CollectionReference<Map<String, dynamic>> get _collection => _firestore
      .collection('churches')
      .doc(churchId)
      .collection('notifications');

  Stream<List<AppNotification>> watchNotifications() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (document) =>
                    AppNotification.fromMap(document.id, document.data()),
              )
              .toList(),
        );
  }

  Future<void> addNotification(AppNotification notification) {
    return _collection.add(notification.toMap());
  }

  Future<void> updateNotification({
    required String id,
    required String title,
    required String body,
    required String type,
    required String targetRole,
  }) {
    final notificationId = id.trim();

    if (notificationId.isEmpty) {
      throw ArgumentError.value(id, 'id', 'Notification ID cannot be empty.');
    }

    return _collection.doc(notificationId).update({
      'title': title.trim(),
      'body': body.trim(),
      'type': type,
      'targetRole': targetRole,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteNotification(String id) {
    return _collection.doc(id).delete();
  }
}
