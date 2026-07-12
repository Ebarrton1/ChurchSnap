import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/notification_repository.dart';
import '../services/notification_service.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(FirebaseFirestore.instance);
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref.read(notificationRepositoryProvider));
});

final notificationRepositoryByChurchProvider =
    Provider.family<NotificationRepository, String>((ref, churchId) {
      return NotificationRepository(
        FirebaseFirestore.instance,
        churchId: churchId,
      );
    });

final notificationServiceByChurchProvider =
    Provider.family<NotificationService, String>((ref, churchId) {
      return NotificationService(
        ref.read(notificationRepositoryByChurchProvider(churchId)),
      );
    });
