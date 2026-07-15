import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/upcoming_celebration.dart';

class MemberCelebrationRepository {
  MemberCelebrationRepository({
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

  Stream<List<MemberCelebrationProfile>> watchProfiles() {
    late StreamController<List<MemberCelebrationProfile>> controller;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? memberSubscription;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
    privateProfileSubscription;

    var members = <String, Map<String, dynamic>>{};
    var privateProfiles = <String, Map<String, dynamic>>{};
    var hasMembersSnapshot = false;
    var hasPrivateProfilesSnapshot = false;

    void emitProfiles() {
      if (controller.isClosed ||
          !hasMembersSnapshot ||
          !hasPrivateProfilesSnapshot) {
        return;
      }

      final profiles = members.entries
          .map(
            (entry) => MemberCelebrationProfile.fromRecords(
              memberId: entry.key,
              member: entry.value,
              privateProfile:
                  privateProfiles[entry.key] ?? const <String, dynamic>{},
            ),
          )
          .where((profile) => profile.isEligibleMember)
          .toList();

      profiles.sort(
        (left, right) => left.memberName.toLowerCase().compareTo(
          right.memberName.toLowerCase(),
        ),
      );

      controller.add(List<MemberCelebrationProfile>.unmodifiable(profiles));
    }

    controller = StreamController<List<MemberCelebrationProfile>>(
      onListen: () {
        memberSubscription = _members.snapshots().listen((snapshot) {
          members = <String, Map<String, dynamic>>{
            for (final document in snapshot.docs) document.id: document.data(),
          };
          hasMembersSnapshot = true;
          emitProfiles();
        }, onError: controller.addError);

        privateProfileSubscription = _privateProfiles.snapshots().listen((
          snapshot,
        ) {
          privateProfiles = <String, Map<String, dynamic>>{
            for (final document in snapshot.docs) document.id: document.data(),
          };
          hasPrivateProfilesSnapshot = true;
          emitProfiles();
        }, onError: controller.addError);
      },
      onCancel: () async {
        await memberSubscription?.cancel();
        await privateProfileSubscription?.cancel();
      },
    );

    return controller.stream;
  }

  Future<void> saveSettings(MemberCelebrationSettings settings) {
    final memberId = settings.memberId.trim();

    if (memberId.isEmpty) {
      throw ArgumentError.value(
        settings.memberId,
        'memberId',
        'A member ID is required.',
      );
    }

    return _privateProfiles.doc(memberId).set(<String, dynamic>{
      'weddingAnniversaryDate': settings.weddingAnniversaryDate == null
          ? null
          : Timestamp.fromDate(
              DateTime(
                settings.weddingAnniversaryDate!.year,
                settings.weddingAnniversaryDate!.month,
                settings.weddingAnniversaryDate!.day,
              ),
            ),
      'birthdayReminderEnabled': settings.birthdayReminderEnabled,
      'anniversaryReminderEnabled': settings.anniversaryReminderEnabled,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
