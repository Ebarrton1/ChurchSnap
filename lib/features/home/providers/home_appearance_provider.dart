import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeAppearanceSettings {
  const HomeAppearanceSettings({
    this.backgroundImageUrl = '',
    this.storagePath = '',
    this.updatedAt,
  });

  final String backgroundImageUrl;
  final String storagePath;
  final DateTime? updatedAt;

  bool get usesDefaultImage => backgroundImageUrl.trim().isEmpty;

  factory HomeAppearanceSettings.fromMap(Map<String, dynamic>? map) {
    final data = map ?? const <String, dynamic>{};
    final rawUpdatedAt = data['updatedAt'];

    return HomeAppearanceSettings(
      backgroundImageUrl: (data['backgroundImageUrl'] as String? ?? '').trim(),
      storagePath: (data['storagePath'] as String? ?? '').trim(),
      updatedAt: rawUpdatedAt is Timestamp ? rawUpdatedAt.toDate() : null,
    );
  }
}

final homeAppearanceProvider =
    StreamProvider.family<HomeAppearanceSettings, String>((ref, churchId) {
      final normalizedChurchId = churchId.trim().isEmpty
          ? 'demo-church'
          : churchId.trim();

      return FirebaseFirestore.instance
          .collection('churches')
          .doc(normalizedChurchId)
          .collection('settings')
          .doc('homeAppearance')
          .snapshots()
          .map((snapshot) => HomeAppearanceSettings.fromMap(snapshot.data()));
    });
