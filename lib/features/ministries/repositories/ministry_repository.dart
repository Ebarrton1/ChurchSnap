import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ministry.dart';

class MinistryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _ministries => _firestore
      .collection('churches')
      .doc('demo-church')
      .collection('ministries');

  Stream<List<Ministry>> watchMinistries() {
    return _ministries.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => Ministry.fromMap(doc.id, doc.data()))
          .toList(),
    );
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
