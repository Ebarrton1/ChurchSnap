import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ministry.dart';

class MinistryRepository {
  MinistryRepository({
    FirebaseFirestore? firestore,
    this.churchId = 'demo-church',
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final String churchId;

  CollectionReference<Map<String, dynamic>> get _ministries =>
      _firestore.collection('churches').doc(churchId).collection('ministries');

  Stream<List<Ministry>> watchMinistries() {
    return _ministries.snapshots().map((snapshot) {
      final ministries = snapshot.docs
          .map((document) => Ministry.fromMap(document.id, document.data()))
          .toList();

      ministries.sort(
        (first, second) =>
            first.name.toLowerCase().compareTo(second.name.toLowerCase()),
      );

      return ministries;
    });
  }

  Future<void> addMinistry(Ministry ministry) {
    return _ministries.add(ministry.toMap());
  }

  Future<void> updateMinistry(Ministry ministry) {
    return _ministries.doc(ministry.id).update(ministry.toMap());
  }

  Future<void> deleteMinistry(String ministryId) {
    return _ministries.doc(ministryId).delete();
  }
}
