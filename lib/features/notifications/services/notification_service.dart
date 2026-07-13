import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../models/app_notification.dart';
import '../repositories/notification_repository.dart';

class NotificationService {
  NotificationService(this._repository);

  final NotificationRepository _repository;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;

  String? _userId;
  String? _churchId;

  Stream<List<AppNotification>> watchNotifications() {
    return _repository.watchNotifications();
  }

  Stream<List<AppNotification>> watchNotificationsForRole(String role) {
    return _repository.watchNotificationsForRole(role);
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
    final normalizedUserId = userId.trim();
    final normalizedChurchId = churchId.trim().isEmpty
        ? 'demo-church'
        : churchId.trim();

    if (normalizedUserId.isEmpty) {
      return;
    }

    _userId = normalizedUserId;
    _churchId = normalizedChurchId;

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return;
    }

    final token = await _messaging.getToken();

    if (token != null && token.isNotEmpty) {
      await _saveToken(token);
    }

    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen(
      (refreshedToken) async {
        try {
          await _saveToken(refreshedToken);
        } catch (error) {
          debugPrint('Unable to save refreshed FCM token: $error');
        }
      },
      onError: (Object error) {
        debugPrint('FCM token refresh failed: $error');
      },
    );

    await _foregroundSubscription?.cancel();
    _foregroundSubscription = FirebaseMessaging.onMessage.listen((message) {
      // The operating system displays background notification messages.
      // Foreground presentation will be added with the notification inbox.
    });

    await _openedSubscription?.cancel();
    _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen((
      message,
    ) {
      // Deep-link navigation will be added after permanent Android identity.
    });
  }

  void dispose() {
    _tokenRefreshSubscription?.cancel();
    _foregroundSubscription?.cancel();
    _openedSubscription?.cancel();

    _tokenRefreshSubscription = null;
    _foregroundSubscription = null;
    _openedSubscription = null;
    _userId = null;
    _churchId = null;
  }

  Future<void> _saveToken(String token) async {
    final userId = _userId;
    final churchId = _churchId;

    if (userId == null ||
        userId.isEmpty ||
        churchId == null ||
        churchId.isEmpty ||
        token.isEmpty) {
      return;
    }

    await FirebaseFirestore.instance
        .collection('churches')
        .doc(churchId)
        .collection('members')
        .doc(userId)
        .set({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }
}
