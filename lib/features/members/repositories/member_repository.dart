import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/church_member.dart';

class MemberRepository {
  MemberRepository({
    FirebaseFirestore? firestore,
    this.churchId = 'demo-church',
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final String churchId;

  CollectionReference<Map<String, dynamic>> get _members =>
      _firestore.collection('churches').doc(churchId).collection('members');

  Stream<List<ChurchMember>> watchMembers() {
    return _members.snapshots().map((snapshot) {
      final members = snapshot.docs
          .map((document) => ChurchMember.fromMap(document.id, document.data()))
          .toList();

      members.sort(
        (first, second) => first.displayName.toLowerCase().compareTo(
          second.displayName.toLowerCase(),
        ),
      );

      return members;
    });
  }

  Future<void> addMember(ChurchMember member) {
    return _members.doc(member.id).set(member.toMap());
  }

  Future<void> updateMember(ChurchMember member) {
    return _members.doc(member.id).update(member.toMap());
  }

  Future<void> deleteMember(String memberId) {
    return _members.doc(memberId).delete();
  }
}
