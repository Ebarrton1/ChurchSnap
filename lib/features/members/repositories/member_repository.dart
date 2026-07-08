import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/church_member.dart';

class MemberRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _members => _firestore
      .collection('churches')
      .doc('demo-church')
      .collection('members');

  Stream<List<ChurchMember>> watchMembers() {
    return _members.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => ChurchMember.fromMap(doc.id, doc.data()))
          .toList(),
    );
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
