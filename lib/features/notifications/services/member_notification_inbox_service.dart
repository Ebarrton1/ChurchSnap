import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/member_notification.dart';

class MemberNotificationInboxService {
  MemberNotificationInboxService({
    required this.churchId,
    required this.memberId,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final String churchId;
  final String memberId;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _inbox {
    return _firestore
        .collection('churches')
        .doc(churchId)
        .collection('members')
        .doc(memberId)
        .collection('notificationInbox');
  }

  Stream<List<MemberNotification>> watchInbox() {
    return _inbox
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(MemberNotification.fromDocument)
              .toList(growable: false),
        );
  }

  Future<void> markRead(String notificationId) {
    return _inbox.doc(notificationId).update({
      'read': true,
      'readAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markUnread(String notificationId) {
    return _inbox.doc(notificationId).update({
      'read': false,
      'readAt': FieldValue.delete(),
    });
  }

  Future<void> markAllRead(Iterable<MemberNotification> notifications) async {
    final unread = notifications.where((notification) => !notification.isRead);

    WriteBatch batch = _firestore.batch();
    var pendingWrites = 0;

    for (final notification in unread) {
      batch.update(_inbox.doc(notification.id), {
        'read': true,
        'readAt': FieldValue.serverTimestamp(),
      });
      pendingWrites += 1;

      if (pendingWrites == 450) {
        await batch.commit();
        batch = _firestore.batch();
        pendingWrites = 0;
      }
    }

    if (pendingWrites > 0) {
      await batch.commit();
    }
  }
}
