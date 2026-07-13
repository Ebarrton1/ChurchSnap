import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/church_member.dart';
import '../models/member_profile_details.dart';

class MemberRepository {
  MemberRepository({
    FirebaseFirestore? firestore,
    this.churchId = 'demo-church',
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final String churchId;

  CollectionReference<Map<String, dynamic>> get _members =>
      _firestore.collection('churches').doc(churchId).collection('members');

  CollectionReference<Map<String, dynamic>> get _privateProfiles => _firestore
      .collection('churches')
      .doc(churchId)
      .collection('memberPrivateProfiles');

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

  Stream<MemberProfileDetails> watchPrivateProfile(String memberId) {
    final cleanMemberId = memberId.trim();

    if (cleanMemberId.isEmpty) {
      return Stream.value(const MemberProfileDetails());
    }

    return _privateProfiles.doc(cleanMemberId).snapshots().map((document) {
      final data = document.data();

      if (!document.exists || data == null) {
        return const MemberProfileDetails();
      }

      return MemberProfileDetails.fromMap(data);
    });
  }

  Future<void> addMember(ChurchMember member) {
    return _members.doc(member.id).set(member.toMap());
  }

  Future<void> updateMember(ChurchMember member) {
    return _members.doc(member.id).update(member.toMap());
  }

  Future<void> savePrivateProfile({
    required String memberId,
    required MemberProfileDetails details,
  }) {
    final cleanMemberId = memberId.trim();

    if (cleanMemberId.isEmpty) {
      throw ArgumentError('A member ID is required.');
    }

    return _privateProfiles.doc(cleanMemberId).set({
      ...details.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateMemberWithPrivateProfile({
    required ChurchMember member,
    required MemberProfileDetails details,
  }) async {
    final cleanMemberId = member.id.trim();

    if (cleanMemberId.isEmpty) {
      throw ArgumentError('A member ID is required.');
    }

    final batch = _firestore.batch();

    batch.update(_members.doc(cleanMemberId), member.toMap());

    batch.set(_privateProfiles.doc(cleanMemberId), {
      ...details.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await batch.commit();
  }

  Future<void> deleteMember(String memberId) async {
    final cleanMemberId = memberId.trim();

    if (cleanMemberId.isEmpty) {
      throw ArgumentError('A member ID is required.');
    }

    final batch = _firestore.batch();

    batch.delete(_members.doc(cleanMemberId));
    batch.delete(_privateProfiles.doc(cleanMemberId));

    await batch.commit();
  }
}
