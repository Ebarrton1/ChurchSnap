import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/small_group.dart';

class SmallGroupRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _groups => _firestore
      .collection('churches')
      .doc('demo-church')
      .collection('small_groups');

  Stream<List<SmallGroup>> watchGroups() {
    return _groups.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => SmallGroup.fromMap(doc.id, doc.data()))
          .toList(),
    );
  }

  Future<void> addGroup(SmallGroup group) {
    return _groups.add(group.toMap());
  }

  Future<void> updateGroup(SmallGroup group) {
    return _groups.doc(group.id).update(group.toMap());
  }

  Future<void> deleteGroup(String id) {
    return _groups.doc(id).delete();
  }
}
