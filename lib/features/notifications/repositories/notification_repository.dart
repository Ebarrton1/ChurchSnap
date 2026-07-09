import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_notification.dart';

class NotificationRepository {
  NotificationRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection => _firestore
      .collection('churches')
      .doc('demo-church')
      .collection('notifications');

  Stream<List<AppNotification>> watchNotifications() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AppNotification.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> addNotification(AppNotification notification) {
    return _collection.add(notification.toMap());
  }

  Future<void> deleteNotification(String id) {
    return _collection.doc(id).delete();
  }
}
