import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/member_baptism_record.dart';

class MemberBaptismRepository {
  MemberBaptismRepository({
    FirebaseFirestore? firestore,
    required this.churchId,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final String churchId;

  CollectionReference<Map<String, dynamic>> get _members =>
      _firestore.collection('churches').doc(churchId).collection('members');

  CollectionReference<Map<String, dynamic>> get _privateProfiles => _firestore
      .collection('churches')
      .doc(churchId)
      .collection('memberPrivateProfiles');

  Stream<List<MemberBaptismRecord>> watchRecords() {
    late StreamController<List<MemberBaptismRecord>> controller;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? memberSubscription;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
    privateProfileSubscription;

    var members = <String, Map<String, dynamic>>{};
    var privateProfiles = <String, Map<String, dynamic>>{};
    var hasMembersSnapshot = false;
    var hasPrivateProfilesSnapshot = false;

    void emitRecords() {
      if (controller.isClosed ||
          !hasMembersSnapshot ||
          !hasPrivateProfilesSnapshot) {
        return;
      }

      final records = members.entries
          .map(
            (entry) => MemberBaptismRecord.fromRecords(
              memberId: entry.key,
              member: entry.value,
              privateProfile:
                  privateProfiles[entry.key] ?? const <String, dynamic>{},
            ),
          )
          .where((record) => record.isEligibleMember)
          .toList();

      records.sort(
        (left, right) => left.memberName.toLowerCase().compareTo(
          right.memberName.toLowerCase(),
        ),
      );

      controller.add(List<MemberBaptismRecord>.unmodifiable(records));
    }

    void addError(Object error, StackTrace stackTrace) {
      if (!controller.isClosed) {
        controller.addError(error, stackTrace);
      }
    }

    controller = StreamController<List<MemberBaptismRecord>>(
      onListen: () {
        memberSubscription = _members.snapshots().listen((snapshot) {
          members = <String, Map<String, dynamic>>{
            for (final document in snapshot.docs) document.id: document.data(),
          };
          hasMembersSnapshot = true;
          emitRecords();
        }, onError: addError);

        privateProfileSubscription = _privateProfiles.snapshots().listen((
          snapshot,
        ) {
          privateProfiles = <String, Map<String, dynamic>>{
            for (final document in snapshot.docs) document.id: document.data(),
          };
          hasPrivateProfilesSnapshot = true;
          emitRecords();
        }, onError: addError);
      },
      onCancel: () async {
        await memberSubscription?.cancel();
        await privateProfileSubscription?.cancel();
      },
    );

    return controller.stream;
  }

  Future<void> saveBaptismDate({
    required String memberId,
    required DateTime? baptismDate,
  }) {
    final normalizedMemberId = memberId.trim();

    if (normalizedMemberId.isEmpty) {
      throw ArgumentError.value(
        memberId,
        'memberId',
        'A member ID is required.',
      );
    }

    return _privateProfiles.doc(normalizedMemberId).set(<String, dynamic>{
      'baptismDate': baptismDate == null
          ? null
          : Timestamp.fromDate(
              DateTime(baptismDate.year, baptismDate.month, baptismDate.day),
            ),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
