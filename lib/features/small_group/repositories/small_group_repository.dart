import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/small_group.dart';

class SmallGroupRepository {
  SmallGroupRepository({
    FirebaseFirestore? firestore,
    this.churchId = 'demo-church',
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final String churchId;

  CollectionReference<Map<String, dynamic>> get _groups => _firestore
      .collection('churches')
      .doc(churchId)
      .collection('small_groups');

  Stream<List<SmallGroup>> watchGroups() {
    return _groups.snapshots().map((snapshot) {
      final groups = snapshot.docs
          .map((document) => SmallGroup.fromMap(document.id, document.data()))
          .toList();

      groups.sort(
        (first, second) =>
            first.name.toLowerCase().compareTo(second.name.toLowerCase()),
      );

      return groups;
    });
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
