import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PastorAppearanceSettings {
  const PastorAppearanceSettings({
    this.imageUrl = '',
    this.storagePath = '',
    this.updatedAt,
  });

  final String imageUrl;
  final String storagePath;
  final DateTime? updatedAt;

  bool get usesDefaultImage => imageUrl.trim().isEmpty;

  factory PastorAppearanceSettings.fromMap(Map<String, dynamic>? map) {
    final data = map ?? const <String, dynamic>{};
    final rawUpdatedAt = data['updatedAt'];

    return PastorAppearanceSettings(
      imageUrl: (data['imageUrl'] as String? ?? '').trim(),
      storagePath: (data['storagePath'] as String? ?? '').trim(),
      updatedAt: rawUpdatedAt is Timestamp ? rawUpdatedAt.toDate() : null,
    );
  }
}

final pastorAppearanceProvider =
    StreamProvider.family<PastorAppearanceSettings, String>((ref, churchId) {
      final normalizedChurchId = churchId.trim().isEmpty
          ? 'demo-church'
          : churchId.trim();

      return FirebaseFirestore.instance
          .collection('churches')
          .doc(normalizedChurchId)
          .collection('settings')
          .doc('pastorAppearance')
          .snapshots()
          .map((snapshot) => PastorAppearanceSettings.fromMap(snapshot.data()));
    });
