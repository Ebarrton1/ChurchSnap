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

    return _checkIns
        .where('memberId', isEqualTo: cleanMemberId)
        .snapshots()
        .asyncMap((canonicalSnapshot) async {
          final documentsById =
              <String, QueryDocumentSnapshot<Map<String, dynamic>>>{
                for (final document in canonicalSnapshot.docs)
                  document.id: document,
              };

          try {
            final legacySnapshot = await _checkIns
                .where('userId', isEqualTo: cleanMemberId)
                .get();

            for (final document in legacySnapshot.docs) {
              documentsById[document.id] = document;
            }
          } on FirebaseException {
            // Canonical memberId records remain available if legacy userId
            // queries are unavailable for this account or environment.
          }

          final records = await Future.wait<AttendanceRecord>(
            documentsById.values.map((document) async {
              final data = document.data();
              final eventId = (data['eventId'] as String?)?.trim() ?? '';
              var eventTitle = 'Church Event';

              if (eventId.isNotEmpty) {
                try {
                  final eventSnapshot = await _events.doc(eventId).get();
                  final storedTitle = eventSnapshot.data()?['title'] as String?;

                  if (storedTitle != null && storedTitle.trim().isNotEmpty) {
                    eventTitle = storedTitle.trim();
                  }
                } on FirebaseException {
                  // Keep the fallback event title when the event document
                  // is unavailable.
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

          return List<AttendanceRecord>.unmodifiable(records);
        });
  }
}
