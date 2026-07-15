import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/member_demographics_summary.dart';

class MemberDemographicsRepository {
  MemberDemographicsRepository({
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

  Stream<MemberDemographicsSummary> watchSummary() {
    late StreamController<MemberDemographicsSummary> controller;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? memberSubscription;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
    privateProfileSubscription;

    var members = <String, Map<String, dynamic>>{};
    var privateProfiles = <String, Map<String, dynamic>>{};
    var hasMembersSnapshot = false;
    var hasPrivateProfilesSnapshot = false;

    void emitSummary() {
      if (controller.isClosed ||
          !hasMembersSnapshot ||
          !hasPrivateProfilesSnapshot) {
        return;
      }

      controller.add(
        MemberDemographicsSummary.fromRecords(
          members: members,
          privateProfiles: privateProfiles,
        ),
      );
    }

    controller = StreamController<MemberDemographicsSummary>.broadcast(
      onListen: () {
        memberSubscription = _members.snapshots().listen((snapshot) {
          members = <String, Map<String, dynamic>>{
            for (final document in snapshot.docs) document.id: document.data(),
          };
          hasMembersSnapshot = true;
          emitSummary();
        }, onError: controller.addError);

        privateProfileSubscription = _privateProfiles.snapshots().listen((
          snapshot,
        ) {
          privateProfiles = <String, Map<String, dynamic>>{
            for (final document in snapshot.docs) document.id: document.data(),
          };
          hasPrivateProfilesSnapshot = true;
          emitSummary();
        }, onError: controller.addError);
      },
      onCancel: () async {
        await memberSubscription?.cancel();
        await privateProfileSubscription?.cancel();

        if (!controller.isClosed) {
          await controller.close();
        }
      },
    );

    return controller.stream;
  }
}
