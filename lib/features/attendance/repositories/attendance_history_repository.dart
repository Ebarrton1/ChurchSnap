import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/attendance_record.dart';

class AttendanceHistoryRepository {
  AttendanceHistoryRepository({
    FirebaseFirestore? firestore,
    this.churchId = 'demo-church',
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final String churchId;

  CollectionReference<Map<String, dynamic>> get _checkIns => _firestore
      .collection('churches')
      .doc(churchId)
      .collection('eventCheckIns');

  CollectionReference<Map<String, dynamic>> get _events =>
      _firestore.collection('churches').doc(churchId).collection('events');

  Stream<List<AttendanceRecord>> watchMemberAttendance(String memberId) {
    final cleanMemberId = memberId.trim();

    if (cleanMemberId.isEmpty) {
      return Stream.value(const <AttendanceRecord>[]);
    }

    return _checkIns.snapshots().asyncMap((snapshot) async {
      final matchingDocuments = snapshot.docs.where((document) {
        final data = document.data();

        final canonicalMemberId = (data['memberId'] as String?)?.trim();

        final legacyUserId = (data['userId'] as String?)?.trim();

        return canonicalMemberId == cleanMemberId ||
            legacyUserId == cleanMemberId;
      }).toList();

      final records = await Future.wait<AttendanceRecord>(
        matchingDocuments.map((document) async {
          final data = document.data();

          final eventId = data['eventId'] as String? ?? '';

          var eventTitle = 'Church Event';

          if (eventId.isNotEmpty) {
            try {
              final eventSnapshot = await _events.doc(eventId).get();

              final eventData = eventSnapshot.data();

              final storedTitle = eventData?['title'] as String?;

              if (storedTitle != null && storedTitle.trim().isNotEmpty) {
                eventTitle = storedTitle.trim();
              }
            } on FirebaseException {
              // Keep the fallback event title when
              // the event document is unavailable.
            }
          }

          return AttendanceRecord.fromMap(
            document.id,
            data,
            eventTitle: eventTitle,
          );
        }),
      );

      records.sort((first, second) {
        final firstDate =
            first.checkedInAt ?? DateTime.fromMillisecondsSinceEpoch(0);

        final secondDate =
            second.checkedInAt ?? DateTime.fromMillisecondsSinceEpoch(0);

        return secondDate.compareTo(firstDate);
      });

      return records;
    });
  }
}
