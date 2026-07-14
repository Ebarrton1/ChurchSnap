import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/worship_settings.dart';

class WorshipSettingsRepository {
  WorshipSettingsRepository({
    FirebaseFirestore? firestore,
    required String churchId,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       churchId = churchId.trim().isEmpty ? 'demo-church' : churchId.trim();

  final FirebaseFirestore _firestore;
  final String churchId;

  DocumentReference<Map<String, dynamic>> get _document {
    return _firestore
        .collection('churches')
        .doc(churchId)
        .collection('settings')
        .doc('worship');
  }

  Stream<WorshipSettings> watchSettings() {
    return _document.snapshots().map(
      (snapshot) => WorshipSettings.fromMap(snapshot.data()),
    );
  }

  Future<WorshipSettings> getSettings() async {
    final snapshot = await _document.get();
    return WorshipSettings.fromMap(snapshot.data());
  }

  Future<void> saveSettings(WorshipSettings settings) {
    return _document.set(settings.toMap(), SetOptions(merge: true));
  }
}
