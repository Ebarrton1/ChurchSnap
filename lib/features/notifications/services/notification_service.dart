import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initialize() async {
    await _messaging.requestPermission();

    final token = await _messaging.getToken();
    await _saveToken(token);

    FirebaseMessaging.instance.onTokenRefresh.listen(_saveToken);

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

  Future<void> _saveToken(String? token) async {
    if (token == null) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      developer.log(
        'No signed-in user available for FCM token save.',
        name: 'ChurchSnap.Notifications',
      );
      return;
    }

    await _firestore
        .collection('churches')
        .doc('demo-church')
        .collection('members')
        .doc(user.uid)
        .set({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

    developer.log(
      'FCM token saved for user ${user.uid}',
      name: 'ChurchSnap.Notifications',
    );
  }
}
